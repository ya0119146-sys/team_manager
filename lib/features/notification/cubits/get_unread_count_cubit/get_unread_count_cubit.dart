import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_manager/features/notification/cubits/get_unread_count_cubit/get_unread_count_state.dart';
import 'package:team_manager/features/notification/services/notification_service.dart';

class GetUnreadCountCubit extends Cubit<GetUnreadCountState> {
  GetUnreadCountCubit() : super(GetUnreadCountInitial());
  int unreadCount = 0;
  getUnreadCount() async {
    emit(GetUnreadCountLoading());
    try {
      final response = await NotificationService().getUnreadCount();
      if (response.statusCode == 200) {
        unreadCount = response.data['data']['count'];
        emit(GetUnreadCountSuccess(unreadCount: unreadCount));
      }
    } catch (e) {
      emit(GetUnreadCountError(message: e.toString()));
    }
  }
}
