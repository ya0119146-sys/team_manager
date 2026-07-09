import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_manager/core/helpers/dio_helper.dart';
import 'package:team_manager/features/home/cubit/delte_attachment_cubit/delete_attachment_state.dart';

class DeleteAttachmentCubit extends Cubit<DeleteAttachmentState> {
  DeleteAttachmentCubit() : super(DeleteAttachmentInitial());

  Future<void> deleteAttachment({
    required String projectId,
    required String publicId,
  }) async {
    emit(DeleteAttachmentLoading());
    try {
      final response = await DioHelper.deleteData(
        url: '/api/v1/project/$projectId/att/$publicId',
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(DeleteAttachmentSuccess());
      } else {
        emit(DeleteAttachmentError(message: 'Failed to delete attachment'));
      }
    } on DioException catch (e) {
      emit(
        DeleteAttachmentError(
          message:
              e.response?.data['message'] ??
              e.response?.data['errors'][0]['msg'] ??
              e.message ??
              'An error occurred',
        ),
      );
    } catch (e) {
      emit(DeleteAttachmentError(message: e.toString()));
    }
  }
}
