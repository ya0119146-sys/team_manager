import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:team_manager/core/helpers/dio_helper.dart';

class NotificationService {
  // ── Singleton ──────────────────────────────────────────────────────────────
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  IO.Socket? _socket;

  bool get isConnected => _socket?.connected ?? false;

  /// Connects to the Socket.IO server using the provided token.
  ///
  /// Passes the token in the auth handshake configuration for reconnect stability.
  void connect(String token) {
    if (_socket != null && _socket!.connected) return;

    _socket = IO.io(
      'https://teammanagent-production.up.railway.app',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionDelay(2000)
          .setReconnectionAttempts(10)
          .build(),
    );
    _socket!.connect();
  }

  /// Registers a listener for connection errors.
  void onError(void Function(dynamic error) onError) {
    _socket?.on('error_event', (error) => onError(error));
  }

  /// Registers a listener for disconnect events.
  void onDisconnect(void Function() onDisconnect) {
    _socket?.on('disconnect', (_) => onDisconnect());
  }

  /// Notifications listener
  void listenNotifications(Function(dynamic) callback) {
    _socket?.on("new_notification", callback);
  }

  /// Disconnects the socket.
  void disconnect() {
    _socket?.clearListeners();
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  // ── REST Endpoints ─────────────────────────────────────────────────────────

  dynamic getNotifications() {
    return DioHelper.getData(url: '/api/v1/notifications');
  }

  dynamic getUnreadCount() {
    return DioHelper.getData(url: '/api/v1/notifications/unread-count');
  }

  dynamic editViewedNotification({required String id}) {
    return DioHelper.patchData(url: '/api/v1/notifications/$id/read', data: {});
  }

  dynamic markAsRead() {
    return DioHelper.patchData(
      url: '/api/v1/notifications/mark-all-as-read',
      data: {},
    );
  }
}
