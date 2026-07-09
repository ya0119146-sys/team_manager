import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:team_manager/features/home/cubit/get_all_project_cubit/project_cubit.dart';
import 'package:team_manager/features/home/cubit/get_project_tasks_cubit/get_project_tasks_cubit.dart';
import 'package:team_manager/features/home/cubit/get_user_task_cubit/get_user_task_cubit.dart';
import 'package:team_manager/features/home/cubit/update_task_cubit/update_task_cubit.dart';
import 'package:team_manager/features/home/cubit/update_task_cubit/update_task_state.dart';
import 'package:team_manager/features/home/models/task_model.dart';
import 'package:team_manager/features/home/widgets/get_color.dart';
import 'package:team_manager/features/auth/widgets/custom_scafold_messanger.dart';
import 'package:team_manager/core/widgets/glass_input_field.dart';
import 'package:team_manager/core/widgets/glass_button.dart';
import 'package:team_manager/features/home/widgets/file_selector_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:team_manager/features/home/widgets/status_drop_down_tasks.dart';

/// Admin-only dialog for updating a task's full details.
/// Endpoint: PUT /api/v1/project/:projectId/task/:taskId (multipart/form-data)
class UpdateTaskDialog extends StatefulWidget {
  const UpdateTaskDialog({
    super.key,
    required this.task,
    this.projectDetails = false,
  });
  final TaskModel task;
  final bool projectDetails;
  @override
  State<UpdateTaskDialog> createState() => _UpdateTaskDialogState();
}

class _UpdateTaskDialogState extends State<UpdateTaskDialog> {
  final _taskTitleCtrl = TextEditingController();
  final _taskDescCtrl = TextEditingController();
  final _startDateCtrl = TextEditingController();
  final _endDateCtrl = TextEditingController();

  String _selectedMember = '';
  String _selectedColor = 'blue';
  List<PlatformFile> _attachedFiles = [];
  List<String> _usernameMembers = [];

  // Admin can set any status when editing the full task
  String _selectedStatus = 'Pending';
  static const _allStatuses = [
    'Pending',
    'In-progress',
    'Reviewing',
    'Done',
    'Accepted',
  ];

  static const _colors = ['blue', 'purple', 'green', 'orange', 'red', 'cyan'];

  @override
  void initState() {
    super.initState();
    _taskTitleCtrl.text = widget.task.name;
    _taskDescCtrl.text = widget.task.description;
    _startDateCtrl.text = widget.task.startDate;
    _endDateCtrl.text = widget.task.endDate;
    _selectedColor = widget.task.color.isNotEmpty ? widget.task.color : 'blue';
    _selectedStatus = _allStatuses.contains(widget.task.status)
        ? widget.task.status
        : 'Pending';
    _selectedMember = widget.task.usernameMember;
    _usernameMembers = List<String>.from(widget.task.projectMembers);
  }

  @override
  void dispose() {
    _taskTitleCtrl.dispose();
    _taskDescCtrl.dispose();
    _startDateCtrl.dispose();
    _endDateCtrl.dispose();
    super.dispose();
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'in-progress':
        return const Color(0xFF3B82F6);
      case 'reviewing':
        return const Color(0xFF8B5CF6);
      case 'done':
        return const Color(0xFF22C55E);
      case 'accepted':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    final updateTaskCubit = UpdateTaskCubit.get(context);

    return BlocConsumer<UpdateTaskCubit, UpdateTaskState>(
      listener: (context, state) {
        if (state is UpdateTaskSuccess) {
          customScafoldMessenger(
            context,
            'Task updated successfully'.tr(),
            color: Colors.green,
          );
          GoRouter.of(context).pop();

          widget.projectDetails == false
              ? GetUserTaskCubit.get(context).getUserTask()
              : BlocProvider.of<ProjectCubit>(
                  context,
                ).getOneProject(widget.task.projectId!);
          GetProjectTasksCubit.get(
            context,
          ).getProjectTasks(projectId: widget.task.projectId!);
        } else if (state is UpdateTaskFailure) {
          customScafoldMessenger(
            context,
            state.errorMessage,
            color: Colors.red,
          );
        }
      },
      builder: (context, state) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return ModalProgressHUD(
          inAsyncCall: state is UpdateTaskLoading,
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
                  // ── Header ──────────────────────────────────────────────
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
                          Icons.edit_rounded,
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
                              'Edit Task'.tr(),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Admin — Full task management'.tr(),
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

                  // ── Title ───────────────────────────────────────────────
                  _FieldLabel(label: 'Task Title *'.tr(), theme: theme),
                  const SizedBox(height: 6),
                  GlassInputField(
                    controller: _taskTitleCtrl,
                    hint: 'Enter task title'.tr(),
                  ),
                  const SizedBox(height: 14),

                  // ── Description ─────────────────────────────────────────
                  _FieldLabel(label: 'Description'.tr(), theme: theme),
                  const SizedBox(height: 6),
                  GlassInputField(
                    controller: _taskDescCtrl,
                    hint: 'Enter task description'.tr(),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),

                  _dividerLabel(theme, 'Assignment'.tr()),
                  const SizedBox(height: 12),

                  // ── Assign To ───────────────────────────────────────────
                  _FieldLabel(label: 'Assign To'.tr(), theme: theme),
                  const SizedBox(height: 8),
                  StatusDropdownTasks(
                    hint: 'Select member'.tr(),
                    value: _selectedMember.isNotEmpty ? _selectedMember : null,
                    items: _usernameMembers,
                    onChanged: (value) =>
                        setState(() => _selectedMember = value ?? ''),
                  ),
                  const SizedBox(height: 14),

                  // ── Status ──────────────────────────────────────────────
                  _FieldLabel(label: 'Status'.tr(), theme: theme),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.4)
                          : theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _statusColor(
                          _selectedStatus,
                        ).withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedStatus,
                        isExpanded: true,
                        dropdownColor: theme.colorScheme.surface,
                        style: theme.textTheme.bodyMedium,
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: _statusColor(_selectedStatus),
                        ),
                        selectedItemBuilder: (_) => _allStatuses
                            .map(
                              (s) => Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: _statusColor(s),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    s,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: _statusColor(s),
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _selectedStatus = v);
                        },
                        items: _allStatuses.map((status) {
                          final c = _statusColor(status);
                          return DropdownMenuItem<String>(
                            value: status,
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: c,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(status),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  _dividerLabel(theme, 'Schedule'.tr()),
                  const SizedBox(height: 12),

                  // ── Dates row ───────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _FieldLabel(label: 'Start Date'.tr(), theme: theme),
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
                                final date = await showDatePicker(
                                  context: context,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2035),
                                  initialDate: _safeParseDate(
                                    _startDateCtrl.text,
                                  ),
                                );
                                if (date != null) {
                                  _startDateCtrl.text =
                                      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                                  setState(() {});
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
                            _FieldLabel(label: 'End Date'.tr(), theme: theme),
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
                                final date = await showDatePicker(
                                  context: context,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2035),
                                  initialDate: _safeParseDate(
                                    _endDateCtrl.text,
                                  ),
                                );
                                if (date != null) {
                                  _endDateCtrl.text =
                                      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                                  setState(() {});
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

                  // ── Color picker ────────────────────────────────────────
                  _FieldLabel(label: 'Task Color'.tr(), theme: theme),
                  const SizedBox(height: 10),
                  _ColorPicker(
                    colors: _colors,
                    selectedColor: _selectedColor,
                    onSelected: (c) => setState(() => _selectedColor = c),
                  ),
                  const SizedBox(height: 20),

                  _dividerLabel(theme, 'Attachments'.tr()),
                  const SizedBox(height: 12),

                  // ── File Selector ───────────────────────────────────────
                  FileSelectorWidget(
                    selectedFiles: _attachedFiles,
                    onFilesChanged: (files) =>
                        setState(() => _attachedFiles = files),
                  ),
                  const SizedBox(height: 28),

                  // ── Action Buttons ──────────────────────────────────────
                  GlassButton(
                    label: 'Save Changes'.tr(),
                    icon: Icons.check_rounded,
                    backgroundColor: theme.colorScheme.primary,
                    onPressed: () {
                      updateTaskCubit.updateTask(
                        id: widget.task.id,
                        projectId: widget.task.projectId ?? '',
                        data: {
                          'name': _taskTitleCtrl.text,
                          'description': _taskDescCtrl.text,
                          'startDate': _startDateCtrl.text,
                          'endDate': _endDateCtrl.text,
                          'color': _selectedColor,
                          'username': _selectedMember,
                          'status': _selectedStatus,
                        },
                        attachedFiles: _attachedFiles,
                      );
                    },
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

class _ColorPicker extends StatelessWidget {
  final List<String> colors;
  final String selectedColor;
  final ValueChanged<String> onSelected;

  const _ColorPicker({
    required this.colors,
    required this.selectedColor,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 8,
      children: colors.map((color) {
        final isSelected = selectedColor == color;
        return GestureDetector(
          onTap: () => onSelected(color),
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
                        color: getColor(color).withValues(alpha: 0.5),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: isSelected
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                : null,
          ),
        );
      }).toList(),
    );
  }
}

DateTime _safeParseDate(String? value) {
  if (value == null) return DateTime.now();
  final cleaned = value.trim();
  if (cleaned.isEmpty || cleaned == '0') return DateTime.now();
  try {
    if (cleaned.contains('T')) return DateTime.parse(cleaned).toLocal();
    final normalized = cleaned.replaceAll('/', '-');
    final parts = normalized.split('-');
    if (parts.length != 3) return DateTime.now();
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  } catch (_) {
    return DateTime.now();
  }
}
