abstract class CreateProjectState {}

class CreateProjectInitial extends CreateProjectState {}

class CreateProjectLoading extends CreateProjectState {}

class CreateProjectSuccess extends CreateProjectState {}

class CreateProjectError extends CreateProjectState {
  final String message;
  CreateProjectError({required this.message});
}
