import 'dart:developer';
import 'package:socket_io_client/socket_io_client.dart' as IO;

/// Manages the Socket.io connection lifecycle.
///
/// Key fix: the backend validates the JWT via the Socket.io [auth] field,
/// NOT via HTTP headers. Using [setExtraHeaders] caused the server to accept
/// the initial handshake but reject subsequent pings → disconnect after ~60 s.
/// Using [setAuth] sends the token on every reconnect attempt as well.
class ChatSocketService {
  // ── Singleton ──────────────────────────────────────────────────────────────
  static final ChatSocketService _instance = ChatSocketService._internal();
  factory ChatSocketService() => _instance;
  ChatSocketService._internal();

  IO.Socket? _socket;

  bool get isConnected => _socket?.connected ?? false;

  // ── Connection ─────────────────────────────────────────────────────────────

  /// Establishes (or re-uses) the socket connection.
  ///
  /// [onMessage] is called for every incoming chat message across ALL types
  /// (private, group, announcement).
  /// [onError] is called when the server emits an `error_event`.
  void connect({
    required String token,
    required void Function(Map<String, dynamic> data) onMessage,
    required void Function(String error) onError,
    required void Function() onConnect,
    required void Function() onDisconnect,
  }) {
    if (_socket != null && _socket!.connected) return;

    _socket = IO.io(
      'https://teammanagent-production.up.railway.app',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          // ✅ Correct: backend reads token from socket.handshake.auth.token
          .setAuth({'token': token})
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionDelay(2000)
          .setReconnectionAttempts(10)
          .build(),
    );

    // ── Lifecycle events ───────────────────────────────────────────────────
    _socket!.onConnect((_) {
      log('⚡ Socket connected');
      onConnect();
    });

    _socket!.onDisconnect((reason) {
      log('🔌 Socket disconnected. Reason: $reason');
      onDisconnect();
    });

    _socket!.onConnectError((err) => log('❌ Connect error: $err'));
    _socket!.onError((err) => log('❌ Socket error: $err'));

    // ── Message listeners ──────────────────────────────────────────────────
    _socket!.on('receive_private_message', (data) {
      if (data is Map<String, dynamic>) onMessage(data);
    });

    _socket!.on('receive_group_message', (data) {
      if (data is Map<String, dynamic>) onMessage(data);
    });

    _socket!.on('receive_announcement', (data) {
      if (data is Map<String, dynamic>) onMessage(data);
    });

    // ── Server-side error events ───────────────────────────────────────────
    _socket!.on('error_event', (data) {
      final msg =
          (data is Map ? data['message'] : data)?.toString() ??
          'Unknown socket error';
      onError(msg);
    });

    _socket!.connect();
  }

  // ── Room management ────────────────────────────────────────────────────────

  void joinProject(String projectId) {
    if (isConnected) {
      _socket!.emit('join_project', projectId);
      log('📁 Joined project room: $projectId');
    }
  }

  void leaveProject(String projectId) {
    if (isConnected) _socket!.emit('leave_project', projectId);
  }

  // ── Sending ────────────────────────────────────────────────────────────────

  void sendPrivateMessage({
    required String receiverUsername,
    required String content,
  }) {
    _assertConnected();
    _socket!.emit('send_private_message', {
      'receiverUsername': receiverUsername,
      'content': content,
    });
  }

  void sendGroupMessage({required String projectId, required String content}) {
    _assertConnected();
    _socket!.emit('send_group_message', {
      'projectId': projectId,
      'content': content,
    });
  }

  void sendAnnouncement({
    required String projectId,
    required String title,
    required String content,
    List<Map<String, String>>? files,
  }) {
    _assertConnected();
    _socket!.emit('send_announcement', {
      'projectId': projectId,
      'title': title,
      'content': content,
      if (files != null && files.isNotEmpty) 'files': files,
    });
  }

  // ── Notifications (shared connection) ─────────────────────────────────────

  void listenNotifications(void Function(dynamic) callback) {
    _socket?.on('new_notification', callback);
  }

  // ── Teardown ───────────────────────────────────────────────────────────────

  /// Full disconnect — call only on user logout.
  void disconnect() {
    _socket?.clearListeners();
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    log('🔌 Socket terminated manually.');
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  void _assertConnected() {
    if (!isConnected) {
      throw StateError('Socket is not connected. Cannot send message.');
    }
  }
}
