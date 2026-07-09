class NotificationModel {
  final String title;
  final String body;
  final String createdAt;

  NotificationModel({
    required this.title,
    required this.body,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      title: json['title'],
      body: json['body'],
      createdAt: json['createdAt'],
    );
  }
}
