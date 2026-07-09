import 'package:team_manager/features/auth/model/profle_model.dart';

abstract class GetUserProfileState {}

class GetUserProfileInitial extends GetUserProfileState {}

class GetUserProfileLoading extends GetUserProfileState {}

class GetUserProfileSuccess extends GetUserProfileState {
  final ProfileModel profileModel;
  GetUserProfileSuccess({required this.profileModel});
}

class GetUserProfileError extends GetUserProfileState {
  final String error;
  GetUserProfileError({required this.error});
}
