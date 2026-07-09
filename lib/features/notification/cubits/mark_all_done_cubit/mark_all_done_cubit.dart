import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_manager/features/notification/cubits/mark_all_done_cubit/mark_all_done_state.dart';
import 'package:team_manager/features/notification/services/notification_service.dart';

class MarkAllDoneCubit extends Cubit<MarkAllDoneState> {
  MarkAllDoneCubit() : super(MarkAllDoneInitial());

  void markAllDone() async {
    emit(MarkAllDoneLoading());
    try {
      final response = await NotificationService().markAsRead();
      if (response.statusCode == 200) {
        emit(MarkAllDoneSuccess());
      }
    } catch (e) {
      emit(MarkAllDoneError(message: e.toString()));
    }
  }
}
