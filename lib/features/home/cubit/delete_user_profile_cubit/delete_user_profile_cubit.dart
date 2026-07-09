import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_manager/core/helpers/dio_helper.dart';
import 'package:team_manager/features/home/cubit/delete_user_profile_cubit/delete_user_profile_state.dart';

class DeleteUserProfileCubit extends Cubit<DeleteUserProfileState> {
  DeleteUserProfileCubit() : super(DeleteUserProfileInitial());
  static DeleteUserProfileCubit get(context) => BlocProvider.of(context);
  Future<void> deleteUserProfile() async {
    emit(DeleteUserProfileLoading());
    try {
      Response response = await DioHelper.deleteData(url: '/api/v1/profile');
      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(DeleteUserProfileSuccess());
      }
    } on DioException catch (e) {
      emit(
        DeleteUserProfileError(
          error: e.response?.data['errors'][0]['msg'] ?? 'Error',
        ),
      );
    } catch (e) {
      emit(DeleteUserProfileError(error: e.toString()));
    }
  }
}
