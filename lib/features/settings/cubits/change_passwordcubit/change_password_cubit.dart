import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_manager/core/helpers/cache_helper.dart';
import 'package:team_manager/core/helpers/dio_helper.dart';
import 'package:team_manager/core/helpers/secure_storage_helper.dart';
import 'package:team_manager/features/settings/cubits/change_passwordcubit/change_password_state.dart';

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  ChangePasswordCubit() : super(ChangePasswordInitial());

  static ChangePasswordCubit get(context) => BlocProvider.of(context);

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    emit(ChangePasswordLoading());
    try {
      final response = await DioHelper.putData(
        url: '/api/v1/user/reset-password',
        data: {
          'oldPassword': oldPassword,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Clear all token and cache values
        await SecureStorageHelper.deleteToken();
        await SecureStorageHelper.deleteUsername();
        await CacheHelper.removeData(key: 'auth_active');
        await CacheHelper.removeData(key: 'role');
        await CacheHelper.removeData(key: 'email');
        await CacheHelper.removeData(key: 'username');

        emit(ChangePasswordSuccess());
      }
    } on DioException catch (e) {
      final errorMsg =
          e.response?.data['error']?[0]['msg']?.toString() ??
          'Failed to change password. Please verify current credentials.';
      emit(ChangePasswordError(error: errorMsg));
    } catch (e) {
      emit(ChangePasswordError(error: e.toString()));
    }
  }
}
