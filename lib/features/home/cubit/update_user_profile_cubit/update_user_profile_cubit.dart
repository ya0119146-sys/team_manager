import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_manager/core/helpers/dio_helper.dart';
import 'package:team_manager/features/home/cubit/update_user_profile_cubit/update_user_profile_state.dart';

class UpdateUserProfileCubit extends Cubit<UpdateUserProfileState> {
  UpdateUserProfileCubit() : super(UpdateUserProfileInitial());
  static UpdateUserProfileCubit get(context) => BlocProvider.of(context);
  Future<void> updateUserProfile(String email) async {
    emit(UpdateUserProfileLoading());
    try {
      Response response = await DioHelper.putData(
        url: '/api/v1/profile',
        data: {'email': email},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(UpdateUserProfileSuccess());
      }
    } on DioException catch (e) {
      emit(
        UpdateUserProfileError(
          error: e.response?.data['errors'][0]['msg'] ?? 'Error',
        ),
      );
    } catch (e) {
      emit(UpdateUserProfileError(error: e.toString()));
    }
  }
}
