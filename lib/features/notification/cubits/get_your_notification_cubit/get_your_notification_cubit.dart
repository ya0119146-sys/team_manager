import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_manager/features/notification/cubits/get_your_notification_cubit/get_your_notification_state.dart';
import 'package:team_manager/features/notification/models/notification_model.dart';
import 'package:team_manager/features/notification/services/notification_service.dart';

class GetYourNotificationCubit extends Cubit<GetYourNotificationState> {
  GetYourNotificationCubit() : super(GetYourNotificationInitial());

  List<NotificationModel> notifications = [];
  void getNotifications() async {
    emit(GetYourNotificationLoading());
    try {
      final response = await NotificationService().getNotifications();
      if (response.statusCode == 200 || response.statusCode == 201) {
        // التعديل هنا: تحديد نوع الـ map بشكل صريح
        notifications = (response.data['data'] as List)
            .map<NotificationModel>((e) => NotificationModel.fromJson(e))
            .toList();
        print(' notifications.toString() : ${notifications.toString()}');

        emit(GetYourNotificationSuccess(notifications));
      }
    } catch (e) {
      emit(GetYourNotificationError(e.toString()));
    }
  }
}
