import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_manager/core/helpers/dio_helper.dart';
import 'package:team_manager/features/home/cubit/create_project_cubit/create_project_state.dart';

class CreateProjectCubit extends Cubit<CreateProjectState> {
  CreateProjectCubit() : super(CreateProjectInitial());
  static CreateProjectCubit get(context) => BlocProvider.of(context);

  Future<void> createProject(
    String name,
    String description,
    String startDate,
    String endDate,
    String color,
    List<String> usernameMember,
    List<PlatformFile>? attachedFiles,
  ) async {
    emit(CreateProjectLoading());
    try {
      final Map<String, dynamic> dataMap = {
        "name": name,
        "description": description,
        "startDate": startDate,
        "endDate": endDate,
        "color": color,
      };

      // Add members as array elements for Multer to parse
      for (int i = 0; i < usernameMember.length; i++) {
        dataMap["usernameMember[$i]"] = usernameMember[i];
      }

      final formData = FormData.fromMap(dataMap);

      // Add project file attachments
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

      final response = await DioHelper.dio.post(
        '/api/v1/project',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(CreateProjectSuccess());
      } else {
        emit(CreateProjectError(message: 'Failed to create project'));
      }
    } on DioException catch (e) {
      final errorMsg = e.response?.data['errors']?[0]?['msg']?.toString() ??
          e.response?.data['error']?.toString() ??
          'Error creating project';
      emit(CreateProjectError(message: errorMsg));
    } catch (e) {
      emit(CreateProjectError(message: e.toString()));
    }
  }
}
