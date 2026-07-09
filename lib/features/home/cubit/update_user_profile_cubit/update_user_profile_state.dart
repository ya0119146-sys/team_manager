abstract class UpdateUserProfileState {}

class UpdateUserProfileInitial extends UpdateUserProfileState {}

class UpdateUserProfileLoading extends UpdateUserProfileState {}

class UpdateUserProfileSuccess extends UpdateUserProfileState {}

class UpdateUserProfileError extends UpdateUserProfileState {
  final String error;
  UpdateUserProfileError({required this.error});
}
