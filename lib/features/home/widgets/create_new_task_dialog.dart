import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:team_manager/features/home/cubit/create_new_task_cubit/create_new_task_cubit.dart';
import 'package:team_manager/features/home/cubit/create_new_task_cubit/create_new_task_state.dart';
import 'package:team_manager/features/home/cubit/get_admin_dashboard_cubit/get_admin_dashboard_cubit.dart';
import 'package:team_manager/features/home/cubit/get_all_project_cubit/project_cubit.dart';
import 'package:team_manager/features/home/cubit/get_all_project_cubit/project_state.dart';
import 'package:team_manager/features/home/cubit/get_project_tasks_cubit/get_project_tasks_cubit.dart';
import 'package:team_manager/features/home/cubit/get_project_tasks_cubit/get_project_tasks_state.dart';
import 'package:team_manager/features/home/cubit/get_user_task_cubit/get_user_task_cubit.dart';
import 'package:team_manager/features/home/models/project_model.dart';
import 'package:team_manager/features/home/models/task_model.dart';
import 'package:team_manager/features/home/widgets/get_color.dart';
import 'package:team_manager/features/home/widgets/status_drop_down_tasks.dart';
import 'package:team_manager/features/auth/widgets/custom_scafold_messanger.dart';
import 'package:team_manager/core/widgets/glass_input_field.dart';
import 'package:team_manager/core/widgets/glass_button.dart';
import 'package:team_manager/features/home/widgets/file_selector_widget.dart';
import 'package:easy_localization/easy_localization.dart';

/// Admin-only dialog for creating a new task.
/// Endpoint: POST /api/v1/project/:projectId/task (multipart/form-data)
/// Tasks always start with 'Pending' status per spec.
class CreateNewTaskDialog extends StatefulWidget {
  const CreateNewTaskDialog({super.key, this.projectModel});
  final ProjectModel? projectModel;
  @override
  State<CreateNewTaskDialog> createState() => _CreateNewTaskDialogState();
}

class _CreateNewTaskDialogState extends State<CreateNewTaskDialog> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _startDateCtrl = TextEditingController();
  final _endDateCtrl = TextEditingController();

  ProjectModel? _selectedProject;
  List<String> _projectMembers = [];
  String _selectedMember = '';
  TaskModel? _selectedParentTask;
  List<PlatformFile> _attachedFiles = [];

  String _selectedColor = 'blue';
  static const _colors = ['blue', 'purple', 'green', 'orange', 'red', 'cyan'];

  @override
  void initState() {
    super.initState();
    _selectedProject = widget.projectModel;
    _projectMembers = widget.projectModel?.usernameMembers ?? [];
    ProjectCubit.get(context).getProjects();
    _titleCtrl.addListener(_rebuildIfNeeded);
    _descCtrl.addListener(_rebuildIfNeeded);
    _startDateCtrl.addListener(_rebuildIfNeeded);
    _endDateCtrl.addListener(_rebuildIfNeeded);
  }

  void _rebuildIfNeeded() => setState(() {});

  bool get _isFormValid =>
      _selectedProject != null &&
      _selectedMember.isNotEmpty &&
      _titleCtrl.text.isNotEmpty &&
      _descCtrl.text.isNotEmpty &&
      _startDateCtrl.text.isNotEmpty &&
      _endDateCtrl.text.isNotEmpty;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _startDateCtrl.dispose();
    _endDateCtrl.dispose();
    super.dispose();
  }

  DateTime _getFirstDate() {
    if (_selectedParentTask != null &&
        _selectedParentTask!.endDate.isNotEmpty) {
      try {
        return DateTime.parse(_selectedParentTask!.endDate);
      } catch (_) {}
    }
    return DateTime(2020);
  }

  DateTime _getInitialDate(DateTime firstDate) {
    final now = DateTime.now();
    return now.isBefore(firstDate) ? firstDate : now;
  }

  DateTime _getMinEndDate() {
    if (_startDateCtrl.text.isNotEmpty) {
      try {
        return DateTime.parse(_startDateCtrl.text);
      } catch (_) {}
    }
    return _getFirstDate();
  }

  @override
  Widget build(BuildContext context) {
    final createNewTaskCubit = CreateNewTaskCubit.get(context);

    return BlocBuilder<ProjectCubit, ProjectState>(
      builder: (context, projectState) {
        if (projectState is ProjectLoadingState) {
          return const Dialog(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (projectState is ProjectErrorState) {
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 40),
                  const SizedBox(height: 12),
                  Text(projectState.message),
                ],
              ),
            ),
          );
        }

        if (projectState is ProjectSuccessState) {
          final projects = projectState.projects;

          return BlocConsumer<CreateNewTaskCubit, CreateNewTaskState>(
            listener: (context, state) {
              if (state is CreateNewTaskSuccess) {
                customScafoldMessenger(
                  context,
                  'Task created successfully'.tr(),
                  color: Colors.green,
                );
                GoRouter.of(context).pop();

                if (widget.projectModel != null) {
                  context.read<ProjectCubit>().getOneProject(
                    widget.projectModel!.id,
                  );
                  context.read<GetProjectTasksCubit>().getProjectTasks(
                    projectId: widget.projectModel!.id,
                  );
                } else {
                  context.read<GetUserTaskCubit>().getUserTask();
                  context.read<GetAdminDashboardCubit>().getAdminDashboard();
                }
              } else if (state is CreateNewTaskError) {
                customScafoldMessenger(context, state.error, color: Colors.red);
              }
            },
            builder: (context, taskState) {
              final theme = Theme.of(context);
              final isDark = theme.brightness == Brightness.dark;

              return ModalProgressHUD(
                inAsyncCall: taskState is CreateNewTaskLoading,
                child: Dialog(
                  insetPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 48,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  backgroundColor: theme.colorScheme.surface,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Header ────────────────────────────────────────
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.add_task_rounded,
                                color: theme.colorScheme.primary,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Create New Task'.tr(),
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Admin — Starts as Pending'.tr(),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.hintColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded),
                              onPressed: () => GoRouter.of(context).pop(),
                              style: IconButton.styleFrom(
                                backgroundColor: theme
                                    .colorScheme
                                    .surfaceContainerHighest
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),

                        _dividerLabel(theme, 'Task Details'.tr()),
                        const SizedBox(height: 12),

                        // ── Title ──────────────────────────────────────────
                        _FieldLabel(label: 'Task Title *'.tr(), theme: theme),
                        const SizedBox(height: 6),
                        GlassInputField(
                          controller: _titleCtrl,
                          hint: 'Enter task title'.tr(),
                        ),
                        const SizedBox(height: 14),

                        // ── Description ────────────────────────────────────
                        _FieldLabel(label: 'Description *'.tr(), theme: theme),
                        const SizedBox(height: 6),
                        GlassInputField(
                          controller: _descCtrl,
                          hint: 'Enter task description'.tr(),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 20),

                        _dividerLabel(theme, 'Assignment'.tr()),
                        const SizedBox(height: 12),

                        // ── Project selector ───────────────────────────────
                        _FieldLabel(label: 'Project *'.tr(), theme: theme),
                        const SizedBox(height: 8),
                        StatusDropdownTasks(
                          hint: 'Select a project'.tr(),
                          items: projects.map((e) => e.name).toList(),
                          value: _selectedProject?.name,
                          onChanged: (value) {
                            final project = projects.firstWhere(
                              (p) => p.name == value,
                            );
                            setState(() {
                              _selectedProject = project;
                              _projectMembers = project.usernameMembers ?? [];
                              _selectedMember = '';
                              _selectedParentTask = null;
                              _startDateCtrl.clear();
                              _endDateCtrl.clear();
                            });
                            GetProjectTasksCubit.get(
                              context,
                            ).getProjectTasks(projectId: project.id);
                          },
                        ),
                        const SizedBox(height: 14),

                        // ── Assign to ──────────────────────────────────────
                        _FieldLabel(label: 'Assign To *'.tr(), theme: theme),
                        const SizedBox(height: 8),
                        if (_selectedProject == null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? theme.colorScheme.surfaceContainerHighest
                                        .withValues(alpha: 0.3)
                                  : theme.colorScheme.surfaceContainerHighest
                                        .withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  size: 16,
                                  color: theme.hintColor,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Select a project first'.tr(),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.hintColor,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          StatusDropdownTasks(
                            hint: 'Select member'.tr(),
                            value: _selectedMember.isNotEmpty
                                ? _selectedMember
                                : null,
                            items: _projectMembers,
                            onChanged: (value) =>
                                setState(() => _selectedMember = value ?? ''),
                          ),
                        const SizedBox(height: 20),

                        // ── Parent Task ──────────────────────────────────────
                        _FieldLabel(
                          label: 'Parent Task (Optional)'.tr(),
                          theme: theme,
                        ),
                        const SizedBox(height: 8),
                        if (_selectedProject == null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? theme.colorScheme.surfaceContainerHighest
                                        .withValues(alpha: 0.3)
                                  : theme.colorScheme.surfaceContainerHighest
                                        .withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  size: 16,
                                  color: theme.hintColor,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Select a project first'.tr(),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.hintColor,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          BlocBuilder<
                            GetProjectTasksCubit,
                            GetProjectTasksState
                          >(
                            builder: (context, tasksState) {
                              if (tasksState is GetProjectTasksLoading) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else if (tasksState is GetProjectTasksSuccess) {
                                final tasks = tasksState.tasks;
                                return StatusDropdownTasks(
                                  hint: 'Select parent task'.tr(),
                                  value:
                                      _selectedParentTask?.name ?? 'None'.tr(),
                                  items: [
                                    'None'.tr(),
                                    ...tasks.map((e) => e.name),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      if (value == 'None'.tr() ||
                                          value == null) {
                                        _selectedParentTask = null;
                                      } else {
                                        _selectedParentTask = tasks.firstWhere(
                                          (t) => t.name == value,
                                        );
                                        _startDateCtrl.clear();
                                        _endDateCtrl.clear();
                                      }
                                    });
                                  },
                                );
                              } else if (tasksState is GetProjectTasksError) {
                                return Text(
                                  tasksState.error,
                                  style: const TextStyle(color: Colors.red),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        const SizedBox(height: 20),

                        _dividerLabel(theme, 'Schedule'.tr()),
                        const SizedBox(height: 12),

                        // ── Dates ──────────────────────────────────────────
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _FieldLabel(
                                    label: 'Start Date *'.tr(),
                                    theme: theme,
                                  ),
                                  const SizedBox(height: 6),
                                  GlassInputField(
                                    controller: _startDateCtrl,
                                    readOnly: true,
                                    hint: 'yyyy-mm-dd'.tr(),
                                    suffixIcon: Icon(
                                      Icons.calendar_today_rounded,
                                      color: theme.iconTheme.color,
                                      size: 18,
                                    ),
                                    onTap: () async {
                                      final firstDate = _getFirstDate();
                                      final date = await showDatePicker(
                                        context: context,
                                        firstDate: firstDate,
                                        lastDate: DateTime(2035),
                                        initialDate: _getInitialDate(firstDate),
                                      );
                                      if (date != null) {
                                        setState(
                                          () => _startDateCtrl.text =
                                              '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _FieldLabel(
                                    label: 'End Date *'.tr(),
                                    theme: theme,
                                  ),
                                  const SizedBox(height: 6),
                                  GlassInputField(
                                    controller: _endDateCtrl,
                                    readOnly: true,
                                    hint: 'yyyy-mm-dd'.tr(),
                                    suffixIcon: Icon(
                                      Icons.event_rounded,
                                      color: theme.iconTheme.color,
                                      size: 18,
                                    ),
                                    onTap: () async {
                                      final firstDate = _getMinEndDate();
                                      final date = await showDatePicker(
                                        context: context,
                                        firstDate: firstDate,
                                        lastDate: DateTime(2035),
                                        initialDate: _getInitialDate(firstDate),
                                      );
                                      if (date != null) {
                                        setState(
                                          () => _endDateCtrl.text =
                                              '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        _dividerLabel(theme, 'Appearance'.tr()),
                        const SizedBox(height: 12),

                        // ── Color picker ───────────────────────────────────
                        _FieldLabel(label: 'Task Color'.tr(), theme: theme),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          children: _colors.map((color) {
                            final isSelected = _selectedColor == color;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedColor = color),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: getColor(color),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected
                                        ? theme.colorScheme.primary
                                        : Colors.transparent,
                                    width: 2.5,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: getColor(
                                              color,
                                            ).withValues(alpha: 0.5),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check_rounded,
                                        color: Colors.white,
                                        size: 18,
                                      )
                                    : null,
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),

                        _dividerLabel(theme, 'Attachments'.tr()),
                        const SizedBox(height: 12),

                        // ── File selector ──────────────────────────────────
                        FileSelectorWidget(
                          selectedFiles: _attachedFiles,
                          onFilesChanged: (files) =>
                              setState(() => _attachedFiles = files),
                        ),
                        const SizedBox(height: 28),

                        // ── Action buttons ─────────────────────────────────
                        GlassButton(
                          label: 'Create Task'.tr(),
                          icon: Icons.add_rounded,
                          backgroundColor: _isFormValid
                              ? theme.colorScheme.primary
                              : theme.disabledColor,
                          gradient: _isFormValid
                              ? null
                              : const LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    Colors.transparent,
                                  ],
                                ),
                          onPressed: _isFormValid
                              ? () {
                                  createNewTaskCubit.newTask(
                                    projectId: _selectedProject!.id,
                                    endDate: _endDateCtrl.text,
                                    startDate: _startDateCtrl.text,
                                    color: _selectedColor,
                                    username: _selectedMember,
                                    name: _titleCtrl.text,
                                    description: _descCtrl.text,
                                    status: 'Pending',
                                    attachedFiles: _attachedFiles,
                                    parentTaskId: _selectedParentTask?.id,
                                  );
                                }
                              : null,
                        ),
                        const SizedBox(height: 10),
                        GlassButton(
                          isOutlined: true,
                          label: 'Cancel'.tr(),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _dividerLabel(ThemeData theme, String label) {
    return Row(
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
            fontSize: 11,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Divider(
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
            height: 1,
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  final ThemeData theme;
  const _FieldLabel({required this.label, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: theme.textTheme.bodySmall?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 12,
        letterSpacing: 0.2,
      ),
    );
  }
}
