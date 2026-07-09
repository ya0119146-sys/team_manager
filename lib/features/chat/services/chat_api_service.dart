import 'package:dio/dio.dart';
import 'package:team_manager/core/helpers/dio_helper.dart';
import 'package:team_manager/features/chat/data/models/message_model.dart';

/// Handles all REST API calls for the chat feature.
///
/// Endpoints:
///   GET  /api/v1/chat/private/:username       → private history
///   GET  /api/v1/chat/group/:projectId         → group history
///   GET  /api/v1/chat/announcements/:projectId → announcement history
///   GET  /api/v1/chat/unread-detailed          → unread badge counts
///   PATCH /api/v1/chat/read                    → mark conversation as read
class ChatApiService {
  // ── Singleton ──────────────────────────────────────────────────────────────
  static final ChatApiService _instance = ChatApiService._internal();
  factory ChatApiService() => _instance;
  ChatApiService._internal();

  // ── History fetchers ───────────────────────────────────────────────────────

  Future<List<MessageModel>> getPrivateHistory(String receiverUsername) async {
    final response = await DioHelper.getData(
      url: '/api/v1/chat/private/$receiverUsername',
    );
    final List data = response.data['data'] ?? [];
    return data
        .map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<MessageModel>> getGroupHistory(String projectId) async {
    final response = await DioHelper.getData(
      url: '/api/v1/chat/group/$projectId',
    );
    final List data = response.data['data'] ?? [];
    return data
        .map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<MessageModel>> getAnnouncements(String projectId) async {
    final response = await DioHelper.getData(
      url: '/api/v1/chat/announcements/$projectId',
    );
    final List data = response.data['data'] ?? [];
    print('announcements from api $data');
    return data
        .map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Upload ─────────────────────────────────────────────────────────────────

  Future<List<Map<String, String>>> uploadAnnouncementFiles(
    List<String> filePaths,
  ) async {
    final formData = FormData();
    for (String path in filePaths) {
      formData.files.add(
        MapEntry(
          'files',
          await MultipartFile.fromFile(path, filename: path.split('/').last),
        ),
      );
    }

    // The guide says to use POST /api/v1/chat/upload
    final response = await DioHelper.dio.post(
      '/api/v1/chat/upload',
      data: formData,
    );

    final List data = response.data['data'] ?? [];
    return data
        .map(
          (item) => {
            'url': item['url'] as String,
            'public_id': item['public_id'] as String,
          },
        )
        .toList();
  }

  // ── Unread counts ──────────────────────────────────────────────────────────

  /// Returns a map like:
  ///   { "dm:alice": 3, "group:proj123": 5, "announcement:proj123": 1 }
  Future<Map<String, int>> getDetailedUnread() async {
    final response = await DioHelper.getData(
      url: '/api/v1/chat/unread-detailed',
    );
    final Map<String, dynamic> raw = response.data['data'] ?? {};
    return raw.map((k, v) => MapEntry(k, (v as num).toInt()));
  }

  // ── Read status ────────────────────────────────────────────────────────────

  /// [type] : 'dm' | 'group'
  /// [id]   : username (DM) or projectId (group)
  Future<void> markAsRead({required String type, required String id}) async {
    await DioHelper.patchData(
      url: '/api/v1/chat/read',
      data: {'type': type, 'id': id},
    );
  }
}
