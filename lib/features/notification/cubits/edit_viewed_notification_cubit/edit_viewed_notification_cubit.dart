import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_manager/features/notification/cubits/edit_viewed_notification_cubit/edit_viewed_notification_state.dart';
import 'package:team_manager/features/notification/services/notification_service.dart';

class EditViewedNotificationCubit extends Cubit<EditViewedNotificationState> {
  EditViewedNotificationCubit() : super(EditViewedNotificationInitial());

  void editViewedNotification(String id) async {
    emit(EditViewedNotificationLoading());
    try {
      final response = await NotificationService().editViewedNotification(
        id: id,
      );
      if (response.statusCode == 200) {
        emit(EditViewedNotificationSuccess());
      }
    } catch (e) {
      emit(EditViewedNotificationError(message: e.toString()));
    }
  }
}
