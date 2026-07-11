import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_manager/core/constants/app_constants.dart';
import 'package:team_manager/core/helpers/cache_helper.dart';
import 'package:team_manager/features/auth/cubit/register_cubit/register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit() : super(RegisterInitial());
  static RegisterCubit get(context) => BlocProvider.of(context);
  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    required String username,
    required String confirmPassword,
    required String role,
  }) async {
    final Dio dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        headers: {"Content-Type": "application/json"},
      ),
    );
    final String? tempToken = CacheHelper.getData(key: 'temp_token');

    emit(RegisterLoading());

    try {
      final response = await dio.post(
        "/api/v1/user/register",
        data: {
          "email": email,
          "password": password,
          "username": username,
          "confirmPassword": confirmPassword,
          "role": role,
          "fullName": fullName,
        },
        options: Options(headers: {"Authorization": "Bearer $tempToken"}),
      );

      final Map<String, dynamic> data = response.data;

      if (response.statusCode == 200 || response.statusCode == 201) {
        // ✅ خزّن التوكن مؤقت فقط
        if (data['token'] != null) {
          await CacheHelper.saveData(key: 'temp_token', value: data['token']);
        }

        emit(
          RegisterSuccess(
            message: data['message'] ?? 'Register success, verify your email',
          ),
        );
      }
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data?['errors'][0]['msg'] ?? 'Something went wrong';
      emit(RegisterError(errorMessage));
    } catch (e) {
      emit(RegisterError('Unexpected error occurred'));
    }
  }
}
