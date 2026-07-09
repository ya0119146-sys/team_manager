import 'package:dio/dio.dart';
import 'package:team_manager/core/helpers/cache_helper.dart';
import 'package:team_manager/core/helpers/dio_helper.dart';
import 'package:team_manager/core/helpers/secure_storage_helper.dart';
import 'login_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());
  static LoginCubit get(context) => BlocProvider.of(context);

  Future<void> login({required String email, required String password}) async {
    emit(LoginLoading());

    try {
      final response = await DioHelper.postData(
        url: "/api/v1/user/login",
        data: {"email": email, "password": password},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = response.data;

        final String? token = data['token'];
        final String? role = data['data']['role'];
        final String? username = data['data']['username'];

        if (token != null) {
          // Store token in encrypted secure storage
          await SecureStorageHelper.saveToken(token);
          // Bridge: sync flag for the router
          await CacheHelper.setBool(key: 'auth_active', value: true);
          await DioHelper.init();
        }

        if (role != null) {
          await CacheHelper.saveData(key: "role", value: role);
        }

        if (username != null) {
          await SecureStorageHelper.saveUsername(username);
        }

        emit(LoginSuccess(message: 'Login successfully'));
      }
    } on DioException catch (e) {
      emit(
        LoginError(
          e.response?.data['errors'][0]['msg'].toString() ?? 'Login error',
        ),
      );
    } catch (e) {
      emit(LoginError('Unexpected error'));
    }
  }
}
