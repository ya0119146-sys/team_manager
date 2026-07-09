abstract class CreateNewTaskState {}

class CreateNewTaskInitial extends CreateNewTaskState {}

class CreateNewTaskLoading extends CreateNewTaskState {}

class CreateNewTaskSuccess extends CreateNewTaskState {}

class CreateNewTaskError extends CreateNewTaskState {
  final String error;
  CreateNewTaskError({required this.error});
}
