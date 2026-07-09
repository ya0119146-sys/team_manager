import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_manager/core/helpers/dio_helper.dart';
import 'package:team_manager/features/home/cubit/create_new_task_cubit/create_new_task_state.dart';

class CreateNewTaskCubit extends Cubit<CreateNewTaskState> {
  CreateNewTaskCubit() : super(CreateNewTaskInitial());
  static CreateNewTaskCubit get(context) => BlocProvider.of(context);

  Future<void> newTask({
    required String projectId,
    required String startDate,
    required String endDate,
    required String color,
    required String username,
    required String name,
    required String description,
    required String status,
    String? parentTaskId,
    List<PlatformFile>? attachedFiles,
  }) async {
    emit(CreateNewTaskLoading());
    try {
      final formData = FormData.fromMap({
        "startDate": startDate,
        "endDate": endDate,
        "color": color,
        "username": username,
        "name": name,
        "description": description,
        "status": status,
        if (parentTaskId != null) "taskId": parentTaskId,
      });

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

      final response = await DioHelper.dio.post(
        '/api/v1/project/$projectId/task',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(CreateNewTaskSuccess());
      } else {
        emit(CreateNewTaskError(error: 'Failed to create task'));
      }
    } on DioException catch (e) {
      final errorMsg =
          e.response?.data['errors']?[0]?['msg']?.toString() ??
          e.response?.data['error']?.toString() ??
          'Error creating task';
      emit(CreateNewTaskError(error: errorMsg));
    } catch (e) {
      emit(CreateNewTaskError(error: e.toString()));
    }
  }
}
