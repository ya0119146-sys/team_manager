import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_manager/core/helpers/cache_helper.dart';
import 'package:team_manager/core/helpers/dio_helper.dart';
import 'package:team_manager/features/home/cubit/get_user_profile_cubit/get_user_profile_state.dart';
import 'package:team_manager/features/auth/model/profle_model.dart';

class GetUserProfileCubit extends Cubit<GetUserProfileState> {
  GetUserProfileCubit() : super(GetUserProfileInitial());
  static GetUserProfileCubit get(context) => BlocProvider.of(context);
  Future<void> getUserProfile() async {
    emit(GetUserProfileLoading());
    try {
      Response response = await DioHelper.getData(url: '/api/v1/profile');
      if (response.statusCode == 200 || response.statusCode == 201) {
        String username = response.data['data']['username'];
        CacheHelper.saveData(key: 'username', value: username);
        ProfileModel profileModel = ProfileModel.fromJson(
          response.data['data'],
        );

        emit(GetUserProfileSuccess(profileModel: profileModel));
      }
    } on DioException catch (e) {
      emit(
        GetUserProfileError(
          error: e.response?.data['errors'][0]['msg'] ?? 'Error',
        ),
      );
    } catch (e) {
      emit(GetUserProfileError(error: e.toString()));
    }
  }
}
