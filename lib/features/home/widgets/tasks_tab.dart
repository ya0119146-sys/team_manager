import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_manager/features/home/cubit/get_all_project_cubit/project_cubit.dart';
import 'package:team_manager/features/home/cubit/get_all_project_cubit/project_state.dart';
import 'package:team_manager/features/home/cubit/get_project_tasks_cubit/get_project_tasks_cubit.dart';
import 'package:team_manager/features/home/cubit/get_project_tasks_cubit/get_project_tasks_state.dart';
import 'package:team_manager/features/home/cubit/get_user_task_cubit/get_user_task_cubit.dart';
import 'package:team_manager/features/home/models/project_model.dart';
import 'package:team_manager/features/home/widgets/create_new_task_dialog.dart';
import 'package:team_manager/features/home/widgets/task_card.dart';
import 'package:team_manager/core/widgets/glass_button.dart';
import 'package:team_manager/core/widgets/empty_state_widget.dart';

class TasksTab extends StatefulWidget {
  final ProjectModel project;
  final int countTasks;
  final bool projectDetails;
  const TasksTab({
    super.key,
    required this.project,
    required this.countTasks,
    this.projectDetails = false,
  });

  @override
  State<TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends State<TasksTab> {
  void _reload() {
    BlocProvider.of<ProjectCubit>(context).getOneProject(widget.project.id);
    GetUserTaskCubit.get(context).getUserTask();
  }

  @override
  void initState() {
    super.initState();
    context.read<GetProjectTasksCubit>().getProjectTasks(
      projectId: widget.project.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<GetProjectTasksCubit, GetProjectTasksState>(
      builder: (context, state) {
        if (state is GetProjectTasksLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 80.0),
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (state is GetProjectTasksError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 60.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.error, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  GlassButton(
                    label: 'reload',
                    onPressed: () {
                      context.read<GetProjectTasksCubit>().getProjectTasks(
                        projectId: widget.project.id,
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        } else if (state is GetProjectTasksSuccess) {
          if (state.tasks.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 60),
              child: Column(
                children: [
                  _buildHeader(context, 0),
                  const SizedBox(height: 20),
                  const EmptyStateWidget(
                    icon: Icons.task_alt_outlined,
                    title: 'No tasks added yet',
                    subtitle: 'Add a new task to this project to get started.',
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              _buildHeader(context, widget.countTasks),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: state.tasks.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final task = state.tasks[index];
                    return TaskCard(
                      task: task,
                      index: index,
                      onActionDone: () => _reload(),
                      projectDetails: widget.projectDetails,
                    );
                  },
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildHeader(BuildContext context, int count) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        BlocBuilder<ProjectCubit, ProjectState>(
          builder: (context, state) {
            return Text(
              'Tasks ($count)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
        ElevatedButton.icon(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) =>
                  CreateNewTaskDialog(projectModel: widget.project),
            );
          },
          icon: const Icon(Icons.check_box_outlined, size: 16),
          label: const Text('Add Task', style: TextStyle(fontSize: 12)),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}
