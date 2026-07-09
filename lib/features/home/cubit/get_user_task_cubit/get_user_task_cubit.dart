import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_manager/core/helpers/dio_helper.dart';
import 'package:team_manager/features/home/cubit/get_user_task_cubit/get_user_task_state.dart';
import 'package:team_manager/features/home/models/task_model.dart';

class GetUserTaskCubit extends Cubit<GetUserTaskState> {
  GetUserTaskCubit() : super(GetUserTaskInitial());
  static GetUserTaskCubit get(context) => BlocProvider.of(context);
  Future<void> getUserTask() async {
    emit(GetUserTaskLoading());
    try {
      final response = await DioHelper.getData(url: '/api/v1/task/utask');

      final List list = response.data['data'];

      final tasks = list.map((e) => TaskModel.fromJson(e)).toList();

      emit(GetUserTaskSuccess(tasks: tasks));
    } on DioException catch (e) {
      emit(
        GetUserTaskError(error: e.response?.data['message'] ?? 'Server Error'),
      );
    } catch (e) {
      emit(GetUserTaskError(error: e.toString()));
    }
  }
}
