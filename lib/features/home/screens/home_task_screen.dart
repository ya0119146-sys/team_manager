import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_manager/features/home/cubit/get_all_project_cubit/project_cubit.dart';
import 'package:team_manager/features/home/cubit/get_all_project_cubit/project_state.dart';
import 'package:team_manager/features/home/cubit/get_project_tasks_cubit/get_project_tasks_cubit.dart';
import 'package:team_manager/features/home/cubit/get_project_tasks_cubit/get_project_tasks_state.dart';
import 'package:team_manager/features/home/cubit/get_user_task_cubit/get_user_task_cubit.dart';
import 'package:team_manager/features/home/cubit/get_user_task_cubit/get_user_task_state.dart';
import 'package:team_manager/features/home/models/project_model.dart';
import 'package:team_manager/features/home/models/task_model.dart';
import 'package:team_manager/features/home/widgets/create_new_task_dialog.dart';
import 'package:team_manager/features/home/widgets/status_drop_down.dart';
import 'package:team_manager/features/home/widgets/task_card.dart';
import 'package:team_manager/core/widgets/glass_button.dart';
import 'package:team_manager/core/widgets/glass_input_field.dart';
import 'package:team_manager/core/widgets/empty_state_widget.dart';
import 'package:easy_localization/easy_localization.dart';

class HomeTaskScreen extends StatefulWidget {
  const HomeTaskScreen({super.key, required this.isAdmin});
  final bool isAdmin;
  @override
  State<HomeTaskScreen> createState() => _HomeTaskScreenState();
}

class _HomeTaskScreenState extends State<HomeTaskScreen> {
  final TextEditingController searchController = TextEditingController();
  String selectedProject = 'All Projects';
  TaskFilter selectedFilter = TaskFilter.all;
  List<ProjectModel> projects = [];
  bool isAllProjects = true;

  @override
  void initState() {
    super.initState();
    ProjectCubit.get(context).getProjects();
    GetUserTaskCubit.get(context).getUserTask();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  TaskStatus _mapStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return TaskStatus.pending;
      case 'in progress':
      case 'inprogress':
      case 'in_progress':
      case 'in-progress':
        return TaskStatus.inProgress;
      case 'reviewing':
        return TaskStatus.reviewing;
      case 'done':
      case 'completed':
        return TaskStatus.done;
      case 'accepted':
        return TaskStatus.accepted;
      default:
        return TaskStatus.pending;
    }
  }

  String _getFilterName(TaskFilter filter) {
    switch (filter) {
      case TaskFilter.pending:
        return 'Pending';
      case TaskFilter.inProgress:
        return 'In Progress';
      case TaskFilter.reviewing:
        return 'Reviewing';
      case TaskFilter.done:
        return 'Done';
      case TaskFilter.accepted:
        return 'Accepted';
      case TaskFilter.all:
        return 'All Status';
    }
  }

  TaskFilter _getFilterFromName(String name) {
    switch (name) {
      case 'Pending':
        return TaskFilter.pending;
      case 'In Progress':
        return TaskFilter.inProgress;
      case 'Reviewing':
        return TaskFilter.reviewing;
      case 'Done':
        return TaskFilter.done;
      case 'Accepted':
        return TaskFilter.accepted;
      case 'All Status':
      default:
        return TaskFilter.all;
    }
  }

  List<TaskModel> filterTasks(List<TaskModel> tasks) {
    final query = searchController.text.trim().toLowerCase();
    List<TaskModel> filteredByStatus;

    switch (selectedFilter) {
      case TaskFilter.pending:
        filteredByStatus = tasks
            .where((t) => _mapStatus(t.status) == TaskStatus.pending)
            .toList();
        break;

      case TaskFilter.inProgress:
        filteredByStatus = tasks
            .where((t) => _mapStatus(t.status) == TaskStatus.inProgress)
            .toList();
        break;

      case TaskFilter.reviewing:
        filteredByStatus = tasks
            .where((t) => _mapStatus(t.status) == TaskStatus.reviewing)
            .toList();
        break;

      case TaskFilter.done:
        filteredByStatus = tasks
            .where((t) => _mapStatus(t.status) == TaskStatus.done)
            .toList();
        break;

      case TaskFilter.accepted:
        filteredByStatus = tasks
            .where((t) => _mapStatus(t.status) == TaskStatus.accepted)
            .toList();
        break;

      case TaskFilter.all:
        filteredByStatus = tasks;
    }

    if (query.isEmpty) return filteredByStatus;

    return filteredByStatus.where((task) {
      return task.name.toLowerCase().contains(query) ||
          task.description.toLowerCase().contains(query) ||
          task.usernameMember.toLowerCase().contains(query) ||
          (task.projectName?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<ProjectCubit, ProjectState>(
      builder: (context, state) {
        if (state is ProjectLoadingState) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is ProjectErrorState) {
          return Center(child: Text(state.message));
        }
        if (state is ProjectSuccessState) {
          projects = state.projects;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ListView(
              padding: EdgeInsets.zero,
              physics: const BouncingScrollPhysics(),
              children: [
                Text(
                  'All Tasks'.tr(),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                BlocBuilder<GetUserTaskCubit, GetUserTaskState>(
                  builder: (context, state) {
                    if (state is GetUserTaskSuccess && isAllProjects) {
                      return Text(
                        '${state.tasks.length}${' tasks'.tr()}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.hintColor,
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
                const SizedBox(height: 16),
                //parent task is opional for task (is_opional)
                //teammate dropdown (is_teammate)
                if (widget.isAdmin) ...[
                  SizedBox(
                    child: GlassButton(
                      label: '+ New Task'.tr(),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => const CreateNewTaskDialog(),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                GlassInputField(
                  hint: 'Search tasks...'.tr(),
                  controller: searchController,
                  prefixIcon: Icons.search,
                  onChanged: (_) {
                    setState(() {});
                  },
                ),

                const SizedBox(height: 12),
                StatusDropdown(
                  initialValue: 'All Projects',
                  items: ['All Projects', ...projects.map((e) => e.name)],
                  onChanged: (value) {
                    setState(() {
                      selectedProject = value;
                      selectedFilter = TaskFilter.all;
                    });
                    if (value == 'All Projects') {
                      isAllProjects = true;
                      GetUserTaskCubit.get(context).getUserTask();
                    } else {
                      isAllProjects = false;
                      final project = projects.firstWhere(
                        (e) => e.name == value,
                      );
                      GetProjectTasksCubit.get(
                        context,
                      ).getProjectTasks(projectId: project.id);
                    }
                  },
                ),
                const SizedBox(height: 12),
                StatusDropdown(
                  key: ValueKey(selectedFilter),
                  initialValue: _getFilterName(selectedFilter).tr(),
                  items: [
                    'All Status'.tr(),
                    'Pending'.tr(),
                    'In Progress'.tr(),
                    'Reviewing'.tr(),
                    'Done'.tr(),
                    'Accepted'.tr(),
                  ],
                  onChanged: (value) {
                    // Find the original english key based on the translated value to keep logic working
                    String enValue = value;
                    if (value == 'All Status'.tr()) {
                      enValue = 'All Status';
                    } else if (value == 'Pending'.tr()) {
                      enValue = 'Pending';
                    } else if (value == 'In Progress'.tr()) {
                      enValue = 'In Progress';
                    } else if (value == 'Reviewing'.tr()) {
                      enValue = 'Reviewing';
                    } else if (value == 'Done'.tr()) {
                      enValue = 'Done';
                    } else if (value == 'Accepted'.tr()) {
                      enValue = 'Accepted';
                    }

                    setState(() {
                      selectedFilter = _getFilterFromName(enValue);
                    });
                  },
                ),
                const SizedBox(height: 16),

                buildTasksBloc(),
              ],
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget buildTasksBloc() {
    return BlocBuilder<GetUserTaskCubit, GetUserTaskState>(
      builder: (context, userState) {
        return BlocBuilder<GetProjectTasksCubit, GetProjectTasksState>(
          builder: (context, projectState) {
            List<TaskModel> tasks = [];
            if (isAllProjects) {
              if (userState is GetUserTaskLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              if (userState is GetUserTaskSuccess) {
                tasks = userState.tasks;
              }
            } else {
              if (projectState is GetProjectTasksLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              if (projectState is GetProjectTasksSuccess) {
                tasks = projectState.tasks;
              }
            }
            final filtered = filterTasks(tasks);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildFilterBar(tasks),
                const SizedBox(height: 16),
                if (filtered.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 80),
                    child: Center(
                      child: EmptyStateWidget(
                        icon: Icons.task_alt_outlined,
                        title: 'No tasks found'.tr(),
                        subtitle: 'Change filters or search term to see more'
                            .tr(),
                      ),
                    ),
                  )
                else
                  for (int i = 0; i < filtered.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TaskCard(
                        task: filtered[i],
                        index: i,
                        onActionDone: () {
                          if (isAllProjects) {
                            GetUserTaskCubit.get(context).getUserTask();
                          } else {
                            if (selectedProject != 'All Projects' &&
                                projects.isNotEmpty) {
                              final project = projects.firstWhere(
                                (e) => e.name == selectedProject,
                              );
                              GetProjectTasksCubit.get(
                                context,
                              ).getProjectTasks(projectId: project.id);
                            }
                          }
                        },
                      ),
                    ),
              ],
            );
          },
        );
      },
    );
  }

  Widget buildFilterBar(List<TaskModel> tasks) {
    int count(TaskFilter filter) => filterTasks(
      tasks.where((t) {
        if (filter == TaskFilter.all) return true;
        return _mapStatus(t.status).name == filter.name;
      }).toList(),
    ).length;

    Widget item(String text, TaskFilter filter) {
      final bool selected = selectedFilter == filter;
      return GestureDetector(
        onTap: () => setState(() => selectedFilter = filter),
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          item('${'All'.tr()} (${count(TaskFilter.all)})', TaskFilter.all),
          item(
            '${'Pending'.tr()} (${count(TaskFilter.pending)})',
            TaskFilter.pending,
          ),
          item(
            '${'In Progress'.tr()} (${count(TaskFilter.inProgress)})',
            TaskFilter.inProgress,
          ),
          item(
            '${'Reviewing'.tr()} (${count(TaskFilter.reviewing)})',
            TaskFilter.reviewing,
          ),
          item('${'Done'.tr()} (${count(TaskFilter.done)})', TaskFilter.done),
          item(
            '${'Accepted'.tr()} (${count(TaskFilter.accepted)})',
            TaskFilter.accepted,
          ),
        ],
      ),
    );
  }
}

enum TaskStatus { pending, inProgress, reviewing, done, accepted }

enum TaskFilter { all, pending, inProgress, reviewing, done, accepted }
