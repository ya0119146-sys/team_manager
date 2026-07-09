import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_manager/core/helpers/dio_helper.dart';
import 'package:team_manager/features/home/cubit/get_all_project_cubit/project_state.dart';
import 'package:team_manager/features/home/models/project_model.dart';
import 'package:team_manager/features/home/models/task_model.dart';

class ProjectCubit extends Cubit<ProjectState> {
  ProjectCubit() : super(ProjectInitialState());
  static ProjectCubit get(context) => BlocProvider.of(context);
  List<ProjectModel> projects = [];
  Future<void> getProjects() async {
    emit(ProjectLoadingState());
    try {
      final response = await DioHelper.getData(url: '/api/v1/project');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> projectsList = response.data['data'];
        print("projectsList $projectsList");
        projects = projectsList
            .map((e) => ProjectModel.fromProjectsJson(e))
            .toList();
        emit(ProjectSuccessState(projects: projects));
      }
    } on DioException catch (e) {
      emit(ProjectErrorState(message: e.response?.data['message'] ?? 'Error'));
    } catch (e) {
      emit(ProjectErrorState(message: e.toString()));
    }
  }

  Future<void> getOneProject(String id) async {
    List<TaskModel> tasks = [];
    emit(ProjectLoadingState());
    try {
      final response = await DioHelper.getData(url: '/api/v1/project/$id');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final ProjectModel project = ProjectModel.fromProjectDetailsJson(
          response.data,
        );
        print("dataList ${project.emails}");

        final List<dynamic> tasksList = response.data['tasks'];
        print("tasksList $tasksList");
        tasks = tasksList.map((e) => TaskModel.fromJson(e, projectIdOverride: id)).toList();
        emit(ProjectOneSuccessState(project: project, tasks: tasks));
      }
    } on DioException catch (e) {
      emit(
        ProjectErrorState(
          message: e.response?.data['errors'][0]['msg'] ?? 'Error',
        ),
      );
    } catch (e) {
      emit(ProjectErrorState(message: e.toString()));
    }
  }
}
