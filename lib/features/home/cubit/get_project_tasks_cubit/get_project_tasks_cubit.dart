import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_manager/core/helpers/dio_helper.dart';
import 'package:team_manager/features/home/cubit/get_project_tasks_cubit/get_project_tasks_state.dart';
import 'package:team_manager/features/home/models/task_model.dart';

class GetProjectTasksCubit extends Cubit<GetProjectTasksState> {
  GetProjectTasksCubit() : super(GetProjectTasksInitial());
  static GetProjectTasksCubit get(context) => BlocProvider.of(context);
  Future<void> getProjectTasks({required String projectId}) async {
    emit(GetProjectTasksLoading());
    try {
      Response response = await DioHelper.getData(
        url: '/api/v1/project/$projectId/task',
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        List<TaskModel> tasks = [];
        for (var item in response.data['data']) {
          tasks.add(TaskModel.fromJson(item, projectIdOverride: projectId));
        }
        emit(GetProjectTasksSuccess(tasks: tasks));
      }
    } on DioException catch (e) {
      emit(
        GetProjectTasksError(
          error: e.response?.data['errors'][0]['msg'] ?? 'Error',
        ),
      );
    } catch (e) {
      emit(GetProjectTasksError(error: e.toString()));
    }
  }
}
