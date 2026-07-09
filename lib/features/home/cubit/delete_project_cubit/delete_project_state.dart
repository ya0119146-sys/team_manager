abstract class DeleteProjectState {}

class DeleteProjectInitial extends DeleteProjectState {}

class DeleteProjectloading extends DeleteProjectState {}

class DeleteProjectSuccess extends DeleteProjectState {}

class DeleteProjectError extends DeleteProjectState {
  final String message;
  DeleteProjectError({required this.message});
}
