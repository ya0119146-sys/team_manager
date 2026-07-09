import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:team_manager/core/helpers/dio_helper.dart';

part 'delete_member_state.dart';

class DeleteMemberCubit extends Cubit<DeleteMemberState> {
  DeleteMemberCubit() : super(DeleteMemberInitial());

  Future<void> deleteProjectMember({
    required String id,
    required String usernameMember,
  }) async {
    emit(DeleteMemberLoading());
    try {
      final response = await DioHelper.deleteData(
        url: '/api/v1/project/$id/member',
        data: {"usernameMember": usernameMember},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(DeleteMemberSuccess());
      }
    } on DioException catch (e) {
      String errMsg = 'An error occurred';
      if (e.response?.data != null &&
          e.response!.data['errors'] != null &&
          e.response!.data['errors'].isNotEmpty) {
        errMsg = e.response!.data['errors'][0]['msg'] ?? errMsg;
      }
      emit(DeleteMemberError(message: errMsg));
    } catch (e) {
      emit(DeleteMemberError(message: e.toString()));
    }
  }
}
