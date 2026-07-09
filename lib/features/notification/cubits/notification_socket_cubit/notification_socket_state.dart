import 'package:equatable/equatable.dart';
import '../../models/notification_model.dart';

abstract class NotificationSocketState extends Equatable {
  const NotificationSocketState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class NotificationInitial extends NotificationSocketState {}

/// While loading messages (first time only)
class NotificationLoading extends NotificationSocketState {}

/// If an error occurs in connection or sending
class NotificationError extends NotificationSocketState {
  final String message;

  const NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}

/// When messages are updated (either first load or a new message)
class NotificationLoaded extends NotificationSocketState {
  final List<NotificationModel> notifications;

  const NotificationLoaded(this.notifications);

  @override
  List<Object?> get props => [notifications];
}

/// Reconnecting state
class NotificationReconnecting extends NotificationSocketState {}

/// When the socket is closed
class NotificationDisconnected extends NotificationSocketState {}
