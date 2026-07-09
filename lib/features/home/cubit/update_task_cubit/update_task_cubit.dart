import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_manager/core/helpers/dio_helper.dart';
import 'package:team_manager/features/home/cubit/update_task_cubit/update_task_state.dart';

class UpdateTaskCubit extends Cubit<UpdateTaskState> {
  UpdateTaskCubit() : super(UpdateTaskInitial());
  static UpdateTaskCubit get(context) => BlocProvider.of(context);

  Future<void> updateTask({
    required String id,
    required String projectId,
    required Map<String, dynamic> data,
    List<PlatformFile>? attachedFiles,
  }) async {
    emit(UpdateTaskLoading());
    try {
      final formData = FormData.fromMap(data);

      if (attachedFiles != null && attachedFiles.isNotEmpty) {
        for (var file in attachedFiles) {
          if (file.path != null) {
            formData.files.add(MapEntry(
              'files',
              await MultipartFile.fromFile(file.path!, filename: file.name),
            ));
          }
        }
      }

      // Spec: PUT /api/v1/project/:projectId/task/:taskId (Admin-only, multipart/form-data)
      final url = '/api/v1/project/$projectId/task/$id';

      Response response = await DioHelper.dio.put(
        url,
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(UpdateTaskSuccess());
      } else {
        emit(UpdateTaskFailure(errorMessage: 'Failed to update task'));
      }
    } on DioException catch (e) {
      final errorMsg = e.response?.data['errors']?[0]?['msg']?.toString() ??
          e.response?.data['error']?.toString() ??
          'Error updating task';
      emit(UpdateTaskFailure(errorMessage: errorMsg));
    } catch (e) {
      emit(UpdateTaskFailure(errorMessage: e.toString()));
    }
  }
}
