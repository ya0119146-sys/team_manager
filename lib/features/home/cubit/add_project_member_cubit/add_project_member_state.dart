class AddProjectMemberState {}

class AddProjectMemberInitial extends AddProjectMemberState {}

class AddProjectMemberLoading extends AddProjectMemberState {}

class AddProjectMemberSuccess extends AddProjectMemberState {}

class AddProjectMemberError extends AddProjectMemberState {
  final String message;
  AddProjectMemberError({required this.message});
}
