abstract class UpdateTaskStatusState {}

class UpdateTaskStatusInitial extends UpdateTaskStatusState {}

class UpdateTaskStatusLoading extends UpdateTaskStatusState {}

class UpdateTaskStatusSuccess extends UpdateTaskStatusState {}

class UpdateTaskStatusError extends UpdateTaskStatusState {
  final String error;
  UpdateTaskStatusError({required this.error});
}
