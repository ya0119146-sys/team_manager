import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_manager/core/helpers/dio_helper.dart';
import 'package:team_manager/features/home/cubit/update_task_status_cubit/update_task_status_state.dart';

class UpdateTaskStatusCubit extends Cubit<UpdateTaskStatusState> {
  UpdateTaskStatusCubit() : super(UpdateTaskStatusInitial());
  static UpdateTaskStatusCubit get(context) => BlocProvider.of(context);

  Future<void> updateTaskStatus({
    required String id,
    required String projectId,
    required String status,
    List<PlatformFile>? attachedFiles,
  }) async {
    emit(UpdateTaskStatusLoading());
    try {
      final formData = FormData.fromMap({'status': status});

      // Add file submissions if provided (e.g. deliverable files for Reviewing or Done status)
      if (attachedFiles != null && attachedFiles.isNotEmpty) {
        for (var file in attachedFiles) {
          if (file.path != null) {
            formData.files.add(
              MapEntry(
                'files',
                await MultipartFile.fromFile(file.path!, filename: file.name),
              ),
            );
          }
        }
      }

      final url = '/api/v1/project/$projectId/task/$id';

      Response response = await DioHelper.dio.patch(url, data: formData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(UpdateTaskStatusSuccess());
      } else {
        emit(UpdateTaskStatusError(error: 'Failed to update task status'));
      }
    } on DioException catch (e) {
      final errorMsg =
          e.response?.data['errors']?[0]?['msg']?.toString() ??
          e.response?.data['error']?.toString() ??
          e.response?.data['message']?.toString() ??
          'Error updating status';
      emit(UpdateTaskStatusError(error: errorMsg));
    } catch (e) {
      emit(UpdateTaskStatusError(error: e.toString()));
    }
  }
}
