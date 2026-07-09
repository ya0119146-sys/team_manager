class NotificationModel {
  final String id;
  final String type;
  final String message;
  final String createdAt; // أو استخدم DateTime
  // final NotificationProjectModel? project; // إضافة بيانات المشروع
  bool isRead;

  NotificationModel({
    required this.id,
    required this.type,
    required this.message,
    required this.createdAt,
    // this.project,
    this.isRead = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt']?.toString() ?? '',
      // تحويل بيانات المشروع إذا كانت موجودة
      // project: json['project'] != null
      //     ? NotificationProjectModel.fromJson(json['project'])
      //     : null,
    );
  }

  // إذا كنت تريد تحويل التاريخ لشكل مقروء (مثلاً: منذ ساعتين)
  String get formattedDate {
    if (createdAt.isEmpty) return '';
    DateTime date = DateTime.parse(createdAt);
    // يمكنك هنا استخدام package:intl لتنسيق التاريخ
    return "${date.day}/${date.month}/${date.year}";
  }
}
