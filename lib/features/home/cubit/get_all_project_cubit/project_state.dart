import 'package:team_manager/features/home/models/project_model.dart';
import 'package:team_manager/features/home/models/task_model.dart';

abstract class ProjectState {}

class ProjectInitialState extends ProjectState {}

class ProjectLoadingState extends ProjectState {}

class ProjectSuccessState extends ProjectState {
  final List<ProjectModel> projects;

  ProjectSuccessState({required this.projects});
}

class ProjectOneSuccessState extends ProjectState {
  final ProjectModel project;
  final List<TaskModel> tasks;

  ProjectOneSuccessState({required this.project, required this.tasks});
}

class ProjectErrorState extends ProjectState {
  final String message;

  ProjectErrorState({required this.message});
}
