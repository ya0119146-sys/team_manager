import 'package:team_manager/features/home/models/attachment_model.dart';

class TaskModel {
  final String id;
  final String name;
  final String description;
  final String status;
  final String startDate;
  final String endDate;
  final String color;
  final String usernameMember;
  final String usernameAdmin;
  final String duration;
  final String? projectId;
  final String? projectName;
  final List<String> projectMembers;
  final List<AttachmentModel> adminAttachment;
  final List<AttachmentModel> memberAttachment;

  TaskModel({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.duration,
    required this.color,
    required this.usernameMember,
    required this.usernameAdmin,
    this.projectId,
    this.projectName,
    required this.projectMembers,
    this.adminAttachment = const [],
    this.memberAttachment = const [],
  });

  factory TaskModel.fromJson(
    Map<String, dynamic> json, {
    String? projectIdOverride,
  }) {
    final project = json['project'];
    final rawMemberFiles = json['memberAttachment'] as List? ?? 
        json['memberAttatchment'] as List? ??
        json['files'] as List? ?? 
        json['attachments'] as List? ?? 
        [];
    final memberParsedAttachments = rawMemberFiles
        .map((x) => AttachmentModel.fromJson(x))
        .toList();

    final rawAdminFiles = json['adminAttachment'] as List? ?? 
        json['adminAttatchment'] as List? ?? 
        [];
    final adminParsedAttachments = rawAdminFiles
        .map((x) => AttachmentModel.fromJson(x))
        .toList();
    return TaskModel(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'No Name',
      description: json['description']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Pending',
      duration: json['duration']?.toString() ?? '',
      startDate:
          (json['startDate'] != null && json['startDate'].toString().isNotEmpty)
          ? (() {
              final date = DateTime.parse(json['startDate']).toLocal();
              return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
            })()
          : '',
      endDate:
          (json['endDate'] != null && json['endDate'].toString().isNotEmpty)
          ? (() {
              final date = DateTime.parse(json['endDate']).toLocal();
              return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
            })()
          : '',
      color: json['color']?.toString() ?? '',
      usernameMember: json['usernameMember']?.toString() ?? '',
      usernameAdmin: json['usernameAdmin']?.toString() ?? '',
      projectId:
          projectIdOverride ??
          (project != null ? project['_id']?.toString() : null),
      projectName: project != null ? project['name']?.toString() : null,
      projectMembers: project != null
          ? List<String>.from(project['usernameMember'] ?? [])
          : [],
      adminAttachment: adminParsedAttachments,
      memberAttachment: memberParsedAttachments,
    );
  }
}
