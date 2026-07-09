# 📁 TeamManager: Flutter Integration Report

This document provides complete instructions for linking a Flutter mobile application with the existing **TeamManager** backend. It covers the architecture, authentication, core services, and real-time features.

---

## 1. Technical Stack Overview

- **Backend Architecture**: Node.js / Express (REST API)
- **Database**: MongoDB (Mongoose)
- **Real-time Engine**: Socket.io v4+
- **File Storage**: Cloudinary (via Multi-part upload)
- **Base URL**: `http://<your-server-ip>:5000/api/v1` (Update for production)

### Recommended Flutter Packages
```yaml
dependencies:
  dio: ^5.4.0              # For REST API calls
  socket_io_client: ^2.0.3 # For real-time chat
  flutter_secure_storage: ^9.0.0 # Encrypt JWT tokens
  intl: ^0.19.0            # Date formatting
```

---

## 2. Authentication & Security

The system uses **JWT (JSON Web Tokens)** for authentication. Tokens are passed in the `Authorization` header.

### Authorization Header
```dart
Options(headers: {
  'Authorization': 'Bearer $jwtToken',
});
```

### Auth Workflow
1.  **Registration**: `POST /user/register` (Requires username, email, password, role).
2.  **Verification**: `POST /user/verify` (Required after registration and before login).
3.  **Login**: `POST /user/login`. Returns a `token` and `user` object.
4.  **Password Reset**:
    - `POST /user/password-reset-code`: Sends code to email.
    - `POST /user/verify-reset-code`: Validates the code.
    - `POST /user/reset-password`: Updates the password using the code token.

---

## 3. Core API Services

### 🏗️ Project Management
- `GET /project`: Fetch all projects you are involved in.
- `POST /project`: Create a new project (**Admin Only**).
- `GET /project/:id`: Get full project details.
- `PUT /project/:id`: Update project info.
- `POST /project/:id/members`: Add members to a project.
- `PATCH /project/:id/status`: Change project status (`Active`, `Inactive`, `Done`).

### ✅ Task Workflow (Kanban Logic)
Tasks follow a strict status flow. Admins create tasks, members submit them, and admins accept or reject them.

**Statuses**: `Pending` → `In-progress` → `Done` → `Reviewing` → `Accepted`

-  **Create Task**: `POST /project/:projectId/task`
-  **Update Status**: `PATCH /task/:id`
    -  *Note*: Moving a task from `Reviewing` or `Accepted` back to `Done`, `In-progress`, or `Pending` triggers a **Rework Cycle** penalty.
-  **AI Review**: Admins can trigger an AI Productivity Audit via Gemini.

---

## 4. Dashboard & Performance Tracking

The dashboard provides critical metrics and performance scores.

### 5-Star Performance Rating Logic
The backend calculates a 5-star rating based on quality and timeliness:
> **Rating Formula**: `5.0 - (reworks * 0.1) - (lateDays * 0.3)`

- **Reworks**: Incremented every time a task is sent back for rework (`reviewCycles`).
- **Late Days**: Calculated based on the difference between the `endDate` and the first time the task was marked `Done`.

### Endpoints
- `GET /dashboard/admin`: Stats for admins (Team performance, project overview).
- `GET /dashboard/member`: Stats for members (Personal completion rate, upcoming tasks).
- `GET /dashboard/history`: Historical data for the "Productivity Graph".
- `GET /dashboard/ai-insights`: AI-generated suggestions based on team performance.

---

## 5. Real-time Chat (Socket.io)

The mobile app must connect via WebSocket for instant messaging.

### Connection Config
```dart
IO.Socket socket = IO.io('http://<ip>:5000', 
  IO.OptionBuilder()
    .setTransports(['websocket'])
    .setAuth({'token': jwtToken})
    .build());
```

### Events Table
| Event Name | Type | Payload (JSON) | Description |
| :--- | :--- | :--- | :--- |
| `join_project` | Emit | `String projectId` | Subscribe to a project's live chat |
| `send_private_message` | Emit | `{receiverUsername, content}` | Send DM to a teammate |
| `receive_private_message` | Listen | `{sender, content, createdAt}` | Receive a DM |
| `send_group_message` | Emit | `{projectId, content}` | Post to project public chat |
| `receive_group_message` | Listen | `{sender, role, content}` | Receive group message |
| `send_announcement` | Emit | `{projectId, title, content}` | **Admin Only** project-wide alert |
| `error_event` | Listen | `{message}` | Handles validation/auth errors |

---

## 6. Data Models (Dart)

### Task Model
```dart
class Task {
  final String id;
  final String name;
  final String status; // Pending, In-progress, Done, Reviewing, Accepted
  final DateTime endDate;
  final int reviewCycles;
  final String? aiReview;
  final List<Attachment>? attachments;

  Task({
    required this.id,
    required this.name,
    required this.status,
    required this.endDate,
    this.reviewCycles = 0,
    this.aiReview,
    this.attachments,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['_id'],
      name: json['name'],
      status: json['status'],
      endDate: DateTime.parse(json['endDate']),
      reviewCycles: json['reviewCycles'] ?? 0,
      aiReview: json['aiReview'],
      attachments: (json['attachments'] as List?)
          ?.map((a) => Attachment.fromJson(a))
          .toList(),
    );
  }
}
```

---

## 7. File Uploads (Attachments)

Uploading files requires a `multipart/form-data` request.

- **Field Name**: `files` (The backend expects an array even for single files).
- **Max Size**: 10MB per file.
- **Allowed Types**: Images, PDF, DOC, DOCX, Video (MP4).

```dart
var formData = FormData.fromMap({
  'files': [
    await MultipartFile.fromFile('./image.jpg', filename: 'upload.jpg')
  ],
});
dio.patch('/task/:id', data: formData);
```

---

> [!TIP]
> **Admin vs Member UX**: Always check the `user.role` after login. Admins should see the "Add Project" and "AI Audit" buttons, while Members focus on their specific Assigned Tasks.
