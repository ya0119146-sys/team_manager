import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_manager/core/constants/app_constants.dart';
import 'package:team_manager/core/helpers/cache_helper.dart';
import 'forget_password_state.dart';

class ForgetPasswordCubit extends Cubit<ForgetPasswordState> {
  ForgetPasswordCubit() : super(ForgetPasswordInitial());
  static ForgetPasswordCubit get(context) => BlocProvider.of(context);
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      headers: {"Content-Type": "application/json"},
    ),
  );
  Future<void> resetCode({required String email}) async {
    emit(ForgetPasswordLoading());

    try {
      final response = await dio.post(
        "/api/v1/user/password-reset-code",
        data: {"email": email},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(ForgetPasswordSuccess());
        await CacheHelper.saveData(
          key: 'temp_token',
          value: response.data['token'],
        );
      } else {
        emit(
          ForgetPasswordError(
            message: response.data['message'] ?? 'Request failed',
          ),
        );
      }
    } on DioException catch (e) {
      emit(
        ForgetPasswordError(
          message: e.response?.data['message'] ?? 'Something went wrong',
        ),
      );
    } catch (e) {
      emit(ForgetPasswordError(message: e.toString()));
    }
  }

  Future<void> verifyResetCode({required String verifyCode}) async {
    final String? tempToken = CacheHelper.getData(key: 'temp_token');

    emit(ForgetPasswordLoading());
    if (tempToken == null) {
      emit(
        ForgetPasswordError(
          message: 'No temporary token found. Please reset code first.',
        ),
      );
      return;
    }
    try {
      final response = await dio.post(
        "/api/v1/user/verify-reset-code",
        data: {"verifyCode": verifyCode},
        options: Options(headers: {"Authorization": "Bearer $tempToken"}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(ForgetPasswordSuccess());
      } else {
        emit(
          ForgetPasswordError(
            message: response.data['message'] ?? 'Reset password failed',
          ),
        );
      }
    } on DioException catch (e) {
      emit(ForgetPasswordError(message: e.response?.data['message']));
    } catch (e) {
      emit(ForgetPasswordError(message: e.toString()));
    }
  }

  Future<void> changePassword({
    required String newPassword,
    required String confirmPassword,
  }) async {
    final String? tempToken = CacheHelper.getData(key: 'temp_token');
    if (tempToken == null) {
      emit(
        ForgetPasswordError(
          message: 'No temporary token found. Please reset code first.',
        ),
      );
      return;
    }
    emit(ForgetPasswordLoading());

    try {
      final response = await dio.post(
        "/api/v1/user/reset-password",
        data: {"password": newPassword, "confirmPassword": confirmPassword},
        options: Options(headers: {"Authorization": "Bearer $tempToken"}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(ForgetPasswordSuccess());
      } else {
        emit(
          ForgetPasswordError(
            message:
                response.data['errors'][0]['msg'] ?? 'Reset password failed',
          ),
        );
      }
    } on DioException catch (e) {
      final String errorMessage =
          e.response?.data['errors'][0]['msg'] ?? 'Something went wrong';
      emit(ForgetPasswordError(message: errorMessage));
    } catch (e) {
      emit(ForgetPasswordError(message: "Unexpected error: $e"));
    }
  }
}
