import 'package:team_manager/features/home/models/task_model.dart';

abstract class GetProjectTasksState {}

class GetProjectTasksInitial extends GetProjectTasksState {}

class GetProjectTasksLoading extends GetProjectTasksState {}

class GetProjectTasksSuccess extends GetProjectTasksState {
  final List<TaskModel> tasks;
  GetProjectTasksSuccess({required this.tasks});
}

class GetProjectTasksError extends GetProjectTasksState {
  final String error;
  GetProjectTasksError({required this.error});
}
