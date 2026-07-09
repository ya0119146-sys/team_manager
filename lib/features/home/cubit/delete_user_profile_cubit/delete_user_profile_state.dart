abstract class DeleteUserProfileState {}

class DeleteUserProfileInitial extends DeleteUserProfileState {}

class DeleteUserProfileLoading extends DeleteUserProfileState {}

class DeleteUserProfileSuccess extends DeleteUserProfileState {}

class DeleteUserProfileError extends DeleteUserProfileState {
  final String error;
  DeleteUserProfileError({required this.error});
}
