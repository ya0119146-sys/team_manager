import 'package:equatable/equatable.dart';

/// Represents a chat message returned from the backend REST API or Socket.io.
///
/// The [sender] field can arrive as a plain String (username) or as a nested
/// object `{ "_id": ..., "username": ..., "name": ... }`. We normalise both
/// to a plain String username in [fromJson].
class MessageModel extends Equatable {
  final String id;

  /// 'private' | 'group' | 'announcement'
  final String type;

  /// Sender's username (resolved from nested object if necessary)
  final String sender;

  /// Only present for private messages
  final String? receiver;

  /// Only present for group messages and announcements
  final String? projectId;

  final String content;

  /// Only present for announcements
  final String? title;

  /// Files attached to the announcement
  final List<Map<String, String>> files;

  /// Usernames that have read this message
  final List<String> readBy;

  final DateTime createdAt;

  const MessageModel({
    required this.id,
    required this.type,
    required this.sender,
    this.receiver,
    this.projectId,
    required this.content,
    this.title,
    this.files = const [],
    required this.readBy,
    required this.createdAt,
  });

  // ── Deserialization ────────────────────────────────────────────────────────

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    // The sender may be a plain username string OR a nested object.
    String resolveSender(dynamic raw) {
      if (raw == null) return 'Unknown';
      if (raw is String) return raw.isNotEmpty ? raw : 'Unknown';
      if (raw is Map) {
        return (raw['username'] ?? raw['name'] ?? raw['_id'])?.toString() ??
            'Unknown';
      }
      return raw.toString();
    }

    return MessageModel(
      id: (json['_id'] ?? json['id'])?.toString() ?? '',
      type: json['type']?.toString() ?? 'private',
      sender: resolveSender(json['sender']),
      receiver: json['receiver']?.toString(),
      projectId: json['projectId']?.toString(),
      content: json['content']?.toString() ?? '',
      title: json['title']?.toString(),
      files: (json['files'] as List?)?.map((e) => {
        'url': e['url']?.toString() ?? '',
        'public_id': e['public_id']?.toString() ?? '',
      }).toList() ?? [],
      readBy: List<String>.from(json['readBy'] ?? []),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String).toLocal()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'type': type,
        'sender': sender,
        if (receiver != null) 'receiver': receiver,
        if (projectId != null) 'projectId': projectId,
        'content': content,
        if (title != null) 'title': title,
        if (files.isNotEmpty) 'files': files,
        'readBy': readBy,
        'createdAt': createdAt.toUtc().toIso8601String(),
      };

  @override
  List<Object?> get props =>
      [id, type, sender, receiver, projectId, content, title, files, readBy, createdAt];
}
