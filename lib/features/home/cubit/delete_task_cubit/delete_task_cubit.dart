import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_manager/core/helpers/dio_helper.dart';
import 'package:team_manager/features/home/cubit/delete_task_cubit/delete_task_state.dart';

class DeleteTaskCubit extends Cubit<DeleteTaskState> {
  DeleteTaskCubit() : super(DeleteTaskInitial());
  static DeleteTaskCubit get(context) => BlocProvider.of(context);
  Future<void> deleteTask({required String id}) async {
    emit(DeleteTaskLoading());
    try {
      Response response = await DioHelper.deleteData(url: '/api/v1/task/$id');
      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(DeleteTaskSuccess());
      }
    } on DioException catch (e) {
      emit(DeleteTaskError(error: e.response?.data['message'] ?? 'Error'));
    } catch (e) {
      emit(DeleteTaskError(error: e.toString()));
    }
  }
}
