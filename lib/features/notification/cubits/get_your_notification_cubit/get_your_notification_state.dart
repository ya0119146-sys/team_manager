import 'package:team_manager/features/notification/models/notification_model.dart';

abstract class GetYourNotificationState {}

class GetYourNotificationInitial extends GetYourNotificationState {}

class GetYourNotificationLoading extends GetYourNotificationState {}

class GetYourNotificationSuccess extends GetYourNotificationState {
  final List<NotificationModel> notifications;
  GetYourNotificationSuccess(this.notifications);
}

class GetYourNotificationError extends GetYourNotificationState {
  final String message;
  GetYourNotificationError(this.message);
}
