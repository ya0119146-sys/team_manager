abstract class UpdateTaskState {}

class UpdateTaskInitial extends UpdateTaskState {}

class UpdateTaskLoading extends UpdateTaskState {}

class UpdateTaskSuccess extends UpdateTaskState {}

class UpdateTaskFailure extends UpdateTaskState {
  final String errorMessage;
  UpdateTaskFailure({required this.errorMessage});
}
