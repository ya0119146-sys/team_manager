abstract class EditViewedNotificationState {}

class EditViewedNotificationInitial extends EditViewedNotificationState {}

class EditViewedNotificationLoading extends EditViewedNotificationState {}

class EditViewedNotificationSuccess extends EditViewedNotificationState {}

class EditViewedNotificationError extends EditViewedNotificationState {
  final String message;

  EditViewedNotificationError({required this.message});
}
