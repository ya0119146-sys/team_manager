abstract class GetUnreadCountState {}

class GetUnreadCountInitial extends GetUnreadCountState {}

class GetUnreadCountLoading extends GetUnreadCountState {}

class GetUnreadCountSuccess extends GetUnreadCountState {
  final int unreadCount;

  GetUnreadCountSuccess({required this.unreadCount});
}

class GetUnreadCountError extends GetUnreadCountState {
  final String message;

  GetUnreadCountError({required this.message});
}
