import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_manager/core/helpers/dio_helper.dart';
import 'package:team_manager/features/home/cubit/update_project_cubit/update_project_state.dart';

class UpdateProjectCubit extends Cubit<UpdateProjectState> {
  UpdateProjectCubit() : super(UpdateProjectInitial());
  static UpdateProjectCubit get(context) => BlocProvider.of(context);

  Future<void> updateProject({
    required String id,
    String? name,
    String? description,
    String? startDate,
    String? endDate,
    String? color,
    List<String>? usernameMember,
    List<PlatformFile>? attachedFiles,
  }) async {
    emit(UpdateProjectLoading());
    try {
      final Map<String, dynamic> dataMap = {
        if (name != null) "name": name,
        if (description != null) "description": description,
        if (startDate != null) "startDate": startDate,
        if (endDate != null) "endDate": endDate,
        if (color != null) "color": color,
      };

      if (usernameMember != null) {
        for (int i = 0; i < usernameMember.length; i++) {
          dataMap["usernameMember[$i]"] = usernameMember[i];
        }
      }

      final formData = FormData.fromMap(dataMap);

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

      final response = await DioHelper.dio.put(
        '/api/v1/project/$id',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(UpdateProjectSuccess());
      } else {
        emit(UpdateProjectError(message: 'Failed to update project'));
      }
    } on DioException catch (e) {
      final errorMsg = e.response?.data['errors']?[0]?['msg']?.toString() ??
          e.response?.data['error']?.toString() ??
          'Error updating project';
      emit(UpdateProjectError(message: errorMsg));
    } catch (e) {
      emit(UpdateProjectError(message: e.toString()));
    }
  }
}
