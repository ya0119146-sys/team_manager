import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_manager/features/notification/cubits/notification_socket_cubit/notification_socket_state.dart';
import 'package:team_manager/features/notification/models/notification_model.dart';
import 'package:team_manager/features/notification/services/notification_service.dart';

class NotificationSocketCubit extends Cubit<NotificationSocketState> {
  NotificationSocketCubit() : super(NotificationInitial());

  final List<NotificationModel> notifications = [];
  bool _notificationConnected = false;

  void getNotifications(
    String token, {
    List<NotificationModel> initialMessages = const [],
  }) {
    // Dynamically append REST history to our live list (preventing duplicates)
    if (initialMessages.isNotEmpty) {
      for (final msg in initialMessages) {
        if (!notifications.any((n) => n.id == msg.id)) {
          notifications.add(msg);
        }
      }
      // Sort with newest notifications first
      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      emit(NotificationLoaded(List.from(notifications)));
    }

    if (_notificationConnected) return; // prevent duplicate connection setups
    _notificationConnected = true;

    emit(NotificationLoading());
    try {
      // Connect to the socket server using the correct token handshake
      NotificationService().connect(token);

      NotificationService().listenNotifications((data) {
        try {
          final message = NotificationModel.fromJson(
            data is Map<String, dynamic>
                ? data
                : Map<String, dynamic>.from(data),
          );

          // Add only if not already in the list to prevent duplicates on manual refreshes
          if (!notifications.any((n) => n.id == message.id)) {
            notifications.insert(0, message); // insert live notifications at the top
            emit(NotificationLoaded(List.from(notifications)));
          }
        } catch (e) {
          emit(NotificationError('Failed to parse incoming notification: $e'));
        }
      });

      NotificationService().onError((error) {
        emit(NotificationError(error.toString()));
        emit(NotificationReconnecting());
      });

      NotificationService().onDisconnect(() {
        emit(NotificationDisconnected());
      });

      emit(NotificationLoaded(List.from(notifications)));
    } catch (e) {
      emit(NotificationError('Notification connection failed: $e'));
    }
  }

  void markAsReadLocally(String id) {
    final index = notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      notifications[index].isRead = true;
      emit(NotificationLoaded(List.from(notifications)));
    }
  }

  void markAllAsReadLocally() {
    for (final n in notifications) {
      n.isRead = true;
    }
    emit(NotificationLoaded(List.from(notifications)));
  }

  void disconnect() {
    NotificationService().disconnect();
    notifications.clear();
    _notificationConnected = false;
    emit(NotificationDisconnected());
  }
}
