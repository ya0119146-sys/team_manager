abstract class UpdateProjectState {}

class UpdateProjectInitial extends UpdateProjectState {}

class UpdateProjectLoading extends UpdateProjectState {}

class UpdateProjectSuccess extends UpdateProjectState {}

class UpdateProjectError extends UpdateProjectState {
  final String message;
  UpdateProjectError({required this.message});
}
