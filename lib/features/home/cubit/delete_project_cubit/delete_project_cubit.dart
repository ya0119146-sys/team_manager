import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_manager/core/helpers/dio_helper.dart';
import 'package:team_manager/features/home/cubit/delete_project_cubit/delete_project_state.dart';

class DeleteProjectCubit extends Cubit<DeleteProjectState> {
  DeleteProjectCubit() : super(DeleteProjectInitial());
  static DeleteProjectCubit get(context) => BlocProvider.of(context);

  Future<void> deleteProject(String id) async {
    emit(DeleteProjectloading());
    try {
      final response = await DioHelper.deleteData(url: '/api/v1/project/$id');
      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(DeleteProjectSuccess());
      }
    } on DioException catch (e) {
      emit(DeleteProjectError(message: e.response?.data['errors'][0]['msg']));
    } catch (e) {
      emit(DeleteProjectError(message: e.toString()));
    }
  }
}
