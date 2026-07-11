# Flutter Integration Guide: Task File Upload & Deletion

This guide provides the exact specifications, API endpoint details, and copy-pasteable Dart code (using the popular HTTP client `dio`) to successfully implement file uploading and attachment deletion in a Flutter application.

---

## 1. Authentication Requirements

All request examples below assume you are authenticated. The backend verifies the JSON Web Token (JWT) using the `Authorization` header:

```http
Authorization: Bearer <your_jwt_token>
```

---

## 2. Uploading Files to a Task

The backend handles task updates and file uploads using a `PATCH` request with a `multipart/form-data` content-type.

### Endpoint Details
*   **HTTP Method:** `PATCH`
*   **URL:** `/api/v1/project/:projectId/task/:taskId`
*   **Headers:**
    *   `Authorization: Bearer <JWT_TOKEN>`
    *   `Content-Type: multipart/form-data`
*   **Body Fields:**
    *   `status`: The next status for the task (e.g., `"Done"`, `"Reviewing"`, `"In-progress"`, etc.).
    *   `note`: An optional text note or comment (String).
    *   `files`: The list of files to upload.
        *   > [!IMPORTANT]
        *   The backend expects the file fields to be named exactly **`files`**. You can submit multiple files under this same key name.

### Flutter Implementation (Dio Package)

We recommend using the [`dio`](https://pub.dev/packages/dio) package because it provides native support for multi-part requests and file list uploads.

```dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

class TaskFileService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://your-api-domain.com', // Replace with your base URL
  ));

  /// Uploads files and updates the status of a specific task.
  Future<Response> uploadTaskFiles({
    required String token,
    required String projectId,
    required String taskId,
    required String status,
    String? note,
    required List<File> localFiles,
  }) async {
    final url = '/api/v1/project/$projectId/task/$taskId';

    // 1. Prepare files for the multipart request
    final multipartFiles = <MultipartFile>[];
    for (var file in localFiles) {
      final fileName = p.basename(file.path);
      multipartFiles.add(
        await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
      );
    }

    // 2. Build the FormData object
    // Note: The key MUST be 'files' for the backend uploadMiddleware to detect them.
    final formData = FormData.fromMap({
      'status': status,
      if (note != null && note.isNotEmpty) 'note': note,
      'files': multipartFiles, // Sends the list under the single key 'files'
    });

    // 3. Perform the PATCH request with auth headers
    try {
      final response = await _dio.patch(
        url,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
      return response;
    } on DioException catch (e) {
      print('Upload failed: ${e.response?.data ?? e.message}');
      rethrow;
    }
  }
}
```

---

## 3. Deleting an Attachment from a Task

To delete an attachment, the backend deletes the asset from Cloudinary and cleans up the document schema arrays. The deletion is matched using the attachment's Cloudinary `public_id`.

### Endpoint Details
*   **HTTP Method:** `DELETE`
*   **URL:** `/api/v1/project/:projectId/task/:taskId/att/:public_id`
*   **Headers:**
    *   `Authorization: Bearer <JWT_TOKEN>`
*   **Path Variables:**
    *   `:public_id`: The unique identifier string of the file (e.g. `"tasks/document_name"`).

> [!WARNING]
> Because Cloudinary `public_id`s contain directory slashes (`/`), you **MUST URL-encode** the `public_id` path variable on the client (so `/` becomes `%2F`) to prevent routers from matching nested subpaths and throwing a `404 Not Found`.

### Flutter Implementation (Dio Package)

```dart
import 'package:dio/dio.dart';

class TaskAttachmentService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://your-api-domain.com', // Replace with your base URL
  ));

  /// Deletes a specific task attachment using its Cloudinary public ID.
  Future<Response> deleteAttachment({
    required String token,
    required String projectId,
    required String taskId,
    required String publicId,
  }) async {
    // URL-encode the publicId to escape any slashes (e.g., 'tasks/file_name' -> 'tasks%2Ffile_name')
    final encodedPublicId = Uri.encodeComponent(publicId);
    final url = '/api/v1/project/$projectId/task/$taskId/att/$encodedPublicId';

    try {
      final response = await _dio.delete(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return response;
    } on DioException catch (e) {
      print('Deletion failed: ${e.response?.data ?? e.message}');
      rethrow;
    }
  }
}
```

---

## 4. Key Details & Troubleshooting

1.  **Multiple File Form Field Name:** The backend expects the files array to be named exactly `files` in the multipart request body. Sending files under any other parameter key name (e.g., `file`, `attachments`) will cause the server middleware to ignore the files.
2.  **Slashes in Public IDs:** Do not pass raw `public_id` paths (like `folder/file_id`) directly into the URL path string. Flutter's default string formatting does not URL-encode. Make sure to wrap it with `Uri.encodeComponent()`.
3.  **Member Upload Restrictions:** Tasks updated to the status `"Done"` by a **Member** *require* at least one file upload to succeed. If a member attempts to update the status to `"Done"` without a file, the API will respond with `400 Bad Request` (`"You must upload files when marking task as done"`).
