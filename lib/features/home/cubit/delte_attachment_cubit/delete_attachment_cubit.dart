import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_manager/core/helpers/dio_helper.dart';
import 'package:team_manager/features/home/cubit/delte_attachment_cubit/delete_attachment_state.dart';

class DeleteAttachmentCubit extends Cubit<DeleteAttachmentState> {
  DeleteAttachmentCubit() : super(DeleteAttachmentInitial());

  Future<void> deleteAttachment({
    required String projectId,
    required String publicId,
    String? taskId,
  }) async {
    emit(DeleteAttachmentLoading(publicId: publicId));
    try {
      final encodedPublicId = Uri.encodeComponent(publicId);
      final url = taskId != null 
          ? '/api/v1/project/$projectId/task/$taskId/att/$encodedPublicId'
          : '/api/v1/project/$projectId/att/$encodedPublicId';

      final response = await DioHelper.deleteData(
        url: url,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(DeleteAttachmentSuccess(publicId: publicId));
      } else {
        emit(DeleteAttachmentError(message: 'Failed to delete attachment', publicId: publicId));
      }
    } on DioException catch (e) {
      print("delete attachment cubit error: ${e.response}");
      emit(
        DeleteAttachmentError(
          message:
              e.response?.data['message'] ??
              e.response?.data['errors'][0]['msg'] ??
              e.message ??
              'An error occurred',
          publicId: publicId,
        ),
      );
    } catch (e) {
      emit(DeleteAttachmentError(message: e.toString(), publicId: publicId));
    }
  }
}
