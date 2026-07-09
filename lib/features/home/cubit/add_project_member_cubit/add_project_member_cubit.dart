import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_manager/core/helpers/dio_helper.dart';
import 'package:team_manager/features/home/cubit/add_project_member_cubit/add_project_member_state.dart';

class AddProjectMemberCubit extends Cubit<AddProjectMemberState> {
  AddProjectMemberCubit() : super(AddProjectMemberInitial());
  Future<void> addProjectMember({
    required String id,
    required String usernameMember,
  }) async {
    emit(AddProjectMemberInitial());
    try {
      final response = await DioHelper.postData(
        url: '/api/v1/project/$id/members',
        data: {"usernameMember": usernameMember},
      );
      emit(AddProjectMemberLoading());
      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(AddProjectMemberSuccess());
      }
    } on DioException catch (e) {
      print(e);
      emit(
        AddProjectMemberError(message: e.response?.data['errors'][0]['msg']),
      );
    } catch (e) {
      emit(AddProjectMemberError(message: e.toString()));
    }
  }
}
