# دليل مواصفات وتنفيذ إدارة المشاريع والمهام (Projects & Tasks Feature Spec) لـ Flutter

هذا الملف يوفر مواصفات وتفاصيل برمجية كاملة للتعامل مع إنشاء وتعديل المشاريع والمهام (Projects & Tasks) في تطبيق Flutter، بما في ذلك كيفية **رفع الملفات (File Uploading)**، **حالات المهام (Task Statuses)**، و**معالجة الأخطاء (Error Handling)**. الملف مصمم ليكون مرجعاً مباشراً لأي مطور أو نموذج ذكاء اصطناعي (AI).

---

## 1. نظرة عامة والمسارات (Endpoints)

تعتمد إدارة المشاريع والمهام على الـ REST APIs التالية. **ملاحظة هامة:** جميع طلبات الإنشاء والتعديل التي تحتوي على ملفات يجب أن تُرسل كـ `multipart/form-data`.

### مسارات المشاريع (Projects):
* **إنشاء مشروع:** `POST /api/v1/project` (يتطلب `multipart/form-data`) - *فقط للمدير (admin)*
* **تعديل مشروع:** `PUT /api/v1/project/:id` (يتطلب `multipart/form-data`) - *فقط للمدير (admin)*
* **تعديل حالة مشروع:** `PATCH /api/v1/project/:id/status`

### مسارات المهام (Tasks):
* **إنشاء مهمة:** `POST /api/v1/project/:projectId/task` (يتطلب `multipart/form-data`) - *فقط للمدير (admin)*
* **تعديل مهمة:** `PUT /api/v1/project/:projectId/task/:taskId` (يتطلب `multipart/form-data`) - *فقط للمدير (admin)*
* **تحديث حالة المهمة / إضافة ملفات للمهمة:** `PATCH /api/v1/project/:projectId/task/:taskId` (يتطلب `multipart/form-data`) - *للمدير والعضو (admin & member)*

---

## 2. الاعتماديات المطلوبة (Dependencies - pubspec.yaml)

تأكد من وجود هذه الحزم للتعامل مع رفع الملفات والشبكة:

```yaml
dependencies:
  dio: ^5.4.0
  file_picker: ^8.0.0 # لاختيار الملفات من الجهاز
  path_provider: ^2.1.2
```

---

## 3. حالات المهام المسموح بها (Task Statuses)

حقل `status` في المهمة (Task) يقبل فقط القيَم التالية (Enum):
1. **`Pending`**: قيد الانتظار (الحالة الافتراضية عند الإنشاء).
2. **`In-progress`**: قيد التنفيذ (عندما يبدأ العضو في العمل).
3. **`Reviewing`**: قيد المراجعة (عندما ينهي العضو المهمة ويرفع ملفاتها).
4. **`Done`**: مكتملة مبدئياً.
5. **`Accepted`**: مقبولة (عندما يوافق المدير النهائي).

---

## 4. نماذج البيانات (Data Models) للمرفقات (Attachments)

تستخدم المشاريع والمهام نفس الهيكل للمرفقات المرفوعة.

```dart
class AttachmentModel {
  final String publicId;
  final String secureUrl; // الرابط المستخدم لعرض/تحميل الملف
  final String? resourceType;
  final String? format;
  final int? bytes;

  AttachmentModel({
    required this.publicId,
    required this.secureUrl,
    this.resourceType,
    this.format,
    this.bytes,
  });

  factory AttachmentModel.fromJson(Map<String, dynamic> json) {
    return AttachmentModel(
      publicId: json['public_id'] ?? '',
      secureUrl: json['secure_url'] ?? '',
      resourceType: json['resource_type'],
      format: json['format'],
      bytes: json['bytes'],
    );
  }
}
```

---

## 5. خدمة الـ API للرفع (API Service - Projects & Tasks)

لرفع الملفات مع البيانات (Text fields)، نستخدم `FormData` في مكتبة `Dio`.
حقل الملفات في الـ Backend اسمه **`files`**، ويقبل حتى **5 ملفات** في الطلب الواحد.

```dart
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';

class ProjectTaskApiService {
  final Dio _dio;
  final String baseUrl;

  ProjectTaskApiService(this._dio, {required this.baseUrl});

  // ==========================================
  // 1. إنشاء أو تعديل مشروع (Create / Update Project)
  // ==========================================
  Future<void> submitProject({
    String? projectId, // إذا كان موجوداً يعني العملية Update
    required String name,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    required String color,
    required List<String> usernameMembers,
    List<PlatformFile>? attachedFiles, // الملفات المختارة من الجهاز
  }) async {
    // تجهيز البيانات النصية
    Map<String, dynamic> data = {
      'name': name,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'color': color,
    };
    
    // إضافة الأعضاء (يجب إرسالهم كـ Array في FormData)
    for (int i = 0; i < usernameMembers.length; i++) {
      data['usernameMember[$i]'] = usernameMembers[i];
    }

    FormData formData = FormData.fromMap(data);

    // إضافة الملفات إذا وُجدت لحقل `files`
    if (attachedFiles != null && attachedFiles.isNotEmpty) {
      for (var file in attachedFiles) {
        if (file.path != null) {
          formData.files.add(MapEntry(
            'files', // اسم الحقل المطلوب في الـ Backend
            await MultipartFile.fromFile(file.path!, filename: file.name),
          ));
        }
      }
    }

    try {
      if (projectId == null) {
        // إنشاء
        await _dio.post('$baseUrl/api/v1/project', data: formData);
      } else {
        // تعديل
        await _dio.put('$baseUrl/api/v1/project/$projectId', data: formData);
      }
    } catch (e) {
      _handleError(e);
    }
  }

  // ==========================================
  // 2. إنشاء أو تعديل مهمة (Create / Update Task)
  // ==========================================
  Future<void> submitTask({
    required String projectId,
    String? taskId, // إذا كان موجوداً يعني العملية Update
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    required String username, // العضو الموكل بالمهمة
    String? color,
    String? parentTaskId, // اختياري في حالة كانت مهمة فرعية
    List<PlatformFile>? attachedFiles,
  }) async {
    FormData formData = FormData.fromMap({
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'username': username,
      if (color != null) 'color': color,
      if (parentTaskId != null) 'taskId': parentTaskId,
    });

    if (attachedFiles != null && attachedFiles.isNotEmpty) {
      for (var file in attachedFiles) {
        if (file.path != null) {
          formData.files.add(MapEntry(
            'files', 
            await MultipartFile.fromFile(file.path!, filename: file.name),
          ));
        }
      }
    }

    try {
      if (taskId == null) {
        // إنشاء
        await _dio.post('$baseUrl/api/v1/project/$projectId/task', data: formData);
      } else {
        // تعديل (كامل)
        await _dio.put('$baseUrl/api/v1/project/$projectId/task/$taskId', data: formData);
      }
    } catch (e) {
      _handleError(e);
    }
  }

  // ==========================================
  // 3. تحديث حالة المهمة / تسليم الملفات
  // ==========================================
  Future<void> updateTaskStatus({
    required String projectId,
    required String taskId,
    required String newStatus, // إحدى حالات المهام المسموحة
    List<PlatformFile>? filesToSubmit, // ملفات يرفعها العضو عند تسليم المهمة
  }) async {
    FormData formData = FormData.fromMap({
      'status': newStatus,
    });

    if (filesToSubmit != null && filesToSubmit.isNotEmpty) {
      for (var file in filesToSubmit) {
        if (file.path != null) {
          formData.files.add(MapEntry(
            'files', 
            await MultipartFile.fromFile(file.path!, filename: file.name),
          ));
        }
      }
    }

    try {
      await _dio.patch('$baseUrl/api/v1/project/$projectId/task/$taskId', data: formData);
    } catch (e) {
      _handleError(e);
    }
  }

  // معالجة الأخطاء الموحدة
  void _handleError(dynamic e) {
    if (e is DioException) {
      final responseData = e.response?.data;
      if (responseData != null && responseData['errors'] != null) {
        throw Exception(responseData['errors'].first['msg'] ?? 'Validation Error');
      } else if (responseData != null && responseData['error'] != null) {
        throw Exception(responseData['error']); // أخطاء رفع الملفات (MulterError)
      }
      throw Exception(e.message);
    }
    throw Exception(e.toString());
  }
}
```

---

## 6. الأخطاء المحتملة (Errors & Validations)

لقد تم إعداد الـ Backend للتحقق من المدخلات وإرسال أخطاء محددة (يجب أن يتم عرضها للمستخدم في الـ UI بـ SnackBar مثلاً).

### أخطاء رفع الملفات (Multer Errors)
تُرسل هذه الأخطاء من الـ Middleware بـ `status: 400` ويكون مفتاح الرسالة `error`:
* **`File is too large. Maximum size is 10MB.`**: حجم الملف تخطى 10 ميغابايت.
* **`Too many files uploaded at once.`**: تم رفع أكثر من 5 ملفات في الطلب الواحد.
* **`Unexpected field name in the form.`**: خطأ برمجي (تم استخدام اسم حقل غير `files`).

### أخطاء التحقق من البيانات (Validation Errors)
تُرسل هذه الأخطاء من `express-validator` بـ `status: 400` أو `404` داخل مصفوفة `errors` وتكون الرسالة في خاصية `msg`. من أهم الأخطاء:
* **"this Project Exits already"**: اسم المشروع موجود مسبقاً.
* **"Invalid date format. Use ISO format: YYYY-MM-DD"**: صيغة التاريخ غير صالحة.
* **"End date must be in the future" / "Task duration must be in the future"**: يجب أن يكون تاريخ الانتهاء في المستقبل.
* **"start Date must be less than end date" / "Start date must be before end-Date"**: يجب أن يكون تاريخ البداية قبل تاريخ الانتهاء.
* **"Duration field is not allowed, it will be calculated automatically based on the end date"**: لا تحاول إرسال حقل الـ `duration`، الخادم يحسبه تلقائياً.
* **"Task end date cannot be after project end date"**: تاريخ انتهاء المهمة لا يمكن أن يتخطى تاريخ انتهاء المشروع.
* **"Admin User cannot be added to the project as a member"**: لا يمكن إضافة مدير كعضو في المشروع/المهمة.

---

## 7. آلية اختيار الملفات في Flutter (الواجهة الأمامية)

هكذا يتم كتابة كود الـ UI للسماح للمستخدم باختيار الملفات وتمريرها للخدمة (Service):

```dart
import 'package:file_picker/file_picker.dart';

// دالة لاختيار الملفات داخل الـ Widget
Future<void> _pickFiles() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    allowMultiple: true, // السماح باختيار عدة ملفات
    type: FileType.any, // يمكن تقييدها بـ FileType.image أو FileType.custom
  );

  if (result != null) {
    List<PlatformFile> selectedFiles = result.files;
    
    // تأكد أن المستخدم لم يختر أكثر من 5 ملفات لأن الـ Backend سيرفض الطلب
    if (selectedFiles.length > 5) {
      // إظهار رسالة خطأ (SnackBar) للمستخدم
      print('لا يمكنك اختيار أكثر من 5 ملفات');
      return;
    }

    // هنا يتم تحديث حالة الشاشة أو الـ Bloc بالملفات المختارة
    // setState(() { files = selectedFiles; });
  }
}
```
