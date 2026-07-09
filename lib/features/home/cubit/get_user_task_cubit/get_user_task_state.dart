import 'package:team_manager/features/home/models/task_model.dart';

abstract class GetUserTaskState {}

class GetUserTaskInitial extends GetUserTaskState {}

class GetUserTaskLoading extends GetUserTaskState {}

class GetUserTaskSuccess extends GetUserTaskState {
  final List<TaskModel> tasks;
  GetUserTaskSuccess({required this.tasks});
}

class GetUserTaskError extends GetUserTaskState {
  final String error;
  GetUserTaskError({required this.error});
}
