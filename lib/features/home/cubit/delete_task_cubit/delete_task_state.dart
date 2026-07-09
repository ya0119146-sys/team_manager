abstract class DeleteTaskState {}

class DeleteTaskInitial extends DeleteTaskState {}

class DeleteTaskLoading extends DeleteTaskState {}

class DeleteTaskSuccess extends DeleteTaskState {}

class DeleteTaskError extends DeleteTaskState {
  final String error;
  DeleteTaskError({required this.error});
}
