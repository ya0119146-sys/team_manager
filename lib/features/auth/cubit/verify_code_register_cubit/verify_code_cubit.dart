import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_manager/core/constants/app_constants.dart';
import 'package:team_manager/core/helpers/cache_helper.dart';
import 'package:team_manager/features/auth/cubit/verify_code_register_cubit/verify_code_state.dart';

class VerifyCodeRegisterCubit extends Cubit<VerifyCodeState> {
  VerifyCodeRegisterCubit() : super(VerifyCodeInitialState());
  static VerifyCodeRegisterCubit get(context) => BlocProvider.of(context);

  final Dio dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      headers: {"Content-Type": "application/json"},
    ),
  );

  Future<void> verifyRegisterCode({required String verifyCode}) async {
    emit(VerifyCodeLoadingState());

    final String? tempToken = CacheHelper.getData(key: 'temp_token');
    if (tempToken == null) {
      emit(
        VerifyCodeErrorState(
          "No temporary token found. Please register first.",
        ),
      );
      return;
    }

    try {
      final response = await dio.post(
        "/api/v1/user/verify",
        data: {"verifyCode": verifyCode},
        options: Options(headers: {"Authorization": "Bearer $tempToken"}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(VerifyCodeSuccessState());
      }
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data['message'] ?? 'Something went wrong';
      emit(VerifyCodeErrorState(errorMessage));
    } catch (e) {
      emit(VerifyCodeErrorState("Unexpected error: $e"));
    }
  }
}
