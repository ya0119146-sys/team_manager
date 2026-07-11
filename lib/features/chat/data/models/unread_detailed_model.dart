/// Decodes the detailed unread-counts map from:
/// GET /api/v1/chat/unread-detailed
///
/// Keys follow the pattern:
///   `dm:<receiverUsername>`        → count of unread DMs from that user
///   `group:<projectId>`            → count of unread group messages
///   `announcement:<projectId>`     → count of unread announcements
class UnreadDetailedModel {
  final Map<String, int> unreadMap;

  const UnreadDetailedModel({required this.unreadMap});

  factory UnreadDetailedModel.fromJson(Map<String, dynamic> json) {
    final Map<String, int> map = {};
    json.forEach((key, value) {
      if (value is int) map[key] = value;
    });
    return UnreadDetailedModel(unreadMap: map);
  }

  /// Returns the unread count for a specific conversation.
  ///
  /// [type] : 'dm' | 'group' | 'announcement'
  /// [id]   : username (for DM) or projectId (for group/announcement)
  int getCount(String type, String id) => unreadMap['$type:$id'] ?? 0;

  /// Total unread across ALL conversations
  int get totalUnread => unreadMap.values.fold(0, (a, b) => a + b);

  static const empty = UnreadDetailedModel(unreadMap: {});
}
