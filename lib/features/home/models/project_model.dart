import 'package:team_manager/features/home/models/attachment_model.dart';

class ProjectModel {
  final String id;
  final String name;
  final String startDate;
  final String endDate;
  final String color;
  final String usernameAdmin;
  final String description;
  final int totalTasks;
  final List<String>? usernameMembers;
  final int percent;
  final String duration;
  final List<AttachmentModel> attachments;

  // 👇 موجودة بس في Project Details
  final int pendingTasks;

  final int doneTasks;
  final int inProgressTasks;
  final int reviewingTasks;
  final int acceptedTasks;
  final int totalMembers;
  final List<String> emails;
  ProjectModel({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.color,
    required this.usernameAdmin,
    required this.description,
    required this.usernameMembers,
    required this.percent,
    required this.duration,
    this.totalTasks = 0,
    this.attachments = const [],
    this.pendingTasks = 0,
    this.doneTasks = 0,
    this.inProgressTasks = 0,
    this.reviewingTasks = 0,
    this.acceptedTasks = 0,
    this.totalMembers = 0,
    this.emails = const [],
  });

  /// 🟢 1️⃣ Get All Projects
  factory ProjectModel.fromProjectsJson(Map<String, dynamic> json) {
    final rawFiles =
        json['files'] as List? ?? 
        json['attachments'] as List? ?? 
        json['adminAttachment'] as List? ?? 
        json['adminAttatchment'] as List? ?? 
        [];
    final parsedAttachments = rawFiles
        .map((x) => AttachmentModel.fromJson(x))
        .toList();

    return ProjectModel(
      id: json['_id'],
      name: json['name'],
      startDate: json['startDate'] != null
          ? (() {
              final date = DateTime.parse(json['startDate']).toLocal();
              return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
            })()
          : '0',
      endDate: json['endDate'] != null
          ? (() {
              final date = DateTime.parse(json['endDate']).toLocal();
              return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
            })()
          : '0',
      color: json['color'],
      totalTasks: json['totalTasks'] ?? 0,
      usernameAdmin: json['usernameAdmin'],
      description: json['description'],
      usernameMembers: List<String>.from(json['usernameMember'] ?? []),
      percent: json['percent'] ?? 0,
      duration: json['duration'] ?? '0',
      attachments: parsedAttachments,
    );
  }

  /// 🟢 2️⃣ Get Project Details
  factory ProjectModel.fromProjectDetailsJson(Map<String, dynamic> json) {
    final projectData = json['data'] ?? {};
    final rawFiles =
        projectData['files'] as List? ??
        projectData['attachments'] as List? ??
        projectData['adminAttachment'] as List? ??
        projectData['adminAttatchment'] as List? ??
        [];
    final parsedAttachments = rawFiles
        .map((x) => AttachmentModel.fromJson(x))
        .toList();

    return ProjectModel(
      id: projectData['_id'],
      name: projectData['name'],
      startDate: projectData['startDate'] != null
          ? (() {
              final date = DateTime.parse(projectData['startDate']).toLocal();
              return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
            })()
          : '0',
      endDate: projectData['endDate'] != null
          ? (() {
              final date = DateTime.parse(projectData['endDate']).toLocal();
              return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
            })()
          : '0',
      color: projectData['color'],
      usernameAdmin: projectData['usernameAdmin'],
      description: projectData['description'],
      usernameMembers: List<String>.from(projectData['usernameMember'] ?? []),
      percent: json['percent'] ?? 0,
      totalMembers: json['member'] ?? 0,
      pendingTasks: json['pending'] ?? 0,
      doneTasks: json['Done'] ?? 0,
      inProgressTasks: json['Inprogress'] ?? 0,
      reviewingTasks: json['Reviewing'] ?? 0,
      acceptedTasks: json['Accepted'] ?? 0,
      totalTasks: projectData["totalTasks"],
      duration: projectData['duration'] ?? '0',
      attachments: parsedAttachments,
      emails: List<String>.from(json['emails'] ?? []),
    );
  }
}
