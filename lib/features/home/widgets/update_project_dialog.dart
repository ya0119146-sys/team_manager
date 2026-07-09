import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:team_manager/features/home/cubit/get_all_project_cubit/project_cubit.dart';
import 'package:team_manager/features/home/cubit/update_project_cubit/update_project_cubit.dart';
import 'package:team_manager/features/home/cubit/update_project_cubit/update_project_state.dart';
import 'package:team_manager/features/home/models/project_model.dart';
import 'package:team_manager/features/home/widgets/get_color.dart';
import 'package:team_manager/core/widgets/glass_input_field.dart';
import 'package:team_manager/core/widgets/glass_button.dart';
import 'package:team_manager/features/home/widgets/file_selector_widget.dart';
import 'package:team_manager/features/auth/widgets/custom_scafold_messanger.dart';
import 'package:team_manager/features/home/cubit/get_user_profile_cubit/get_user_profile_cubit.dart';
import 'package:team_manager/features/home/cubit/get_user_profile_cubit/get_user_profile_state.dart';
import 'package:team_manager/features/home/widgets/status_drop_down_tasks.dart';
import 'package:easy_localization/easy_localization.dart';

class UpdateProjectDialog extends StatefulWidget {
  const UpdateProjectDialog({
    super.key,
    required this.project,
    this.projectDetails = false,
  });
  final ProjectModel project;
  final bool projectDetails;
  @override
  State<UpdateProjectDialog> createState() => _UpdateProjectDialogState();
}

class _UpdateProjectDialogState extends State<UpdateProjectDialog> {
  final nameController = TextEditingController();
  final descController = TextEditingController();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();
  final membersController = TextEditingController();
  String selectedColor = 'blue';
  List<PlatformFile> attachedFiles = [];

  final List<String> colors = [
    'blue',
    'purple',
    'green',
    'orange',
    'red',
    'cyan',
  ];

  @override
  void initState() {
    super.initState();
    GetUserProfileCubit.get(context).getUserProfile();
    nameController.text = widget.project.name;
    descController.text = widget.project.description;
    startDateController.text = widget.project.startDate;
    endDateController.text = widget.project.endDate;
    selectedColor = widget.project.color;
    if (widget.project.usernameMembers != null) {
      membersController.text = widget.project.usernameMembers!.join('\n');
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    descController.dispose();
    endDateController.dispose();
    membersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    UpdateProjectCubit updateProjectCubit = UpdateProjectCubit.get(context);
    return BlocConsumer<UpdateProjectCubit, UpdateProjectState>(
      listener: (context, state) {
        if (state is UpdateProjectSuccess) {
          widget.projectDetails
              ? BlocProvider.of<ProjectCubit>(
                  context,
                ).getOneProject(widget.project.id)
              : ProjectCubit.get(context).getProjects();

          customScafoldMessenger(
            context,
            'Project updated successfully!'.tr(),
            color: Colors.green,
          );

          Navigator.pop(context);
        } else if (state is UpdateProjectError) {
          customScafoldMessenger(
            context,
            'Error: ${state.message}',
            color: Colors.red,
          );
        }
      },
      builder: (context, state) {
        final theme = Theme.of(context);
        return ModalProgressHUD(
          inAsyncCall: state is UpdateProjectLoading,
          child: Dialog(
            backgroundColor: theme.colorScheme.surface,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 64,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
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
                          Icons.edit_document,
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
                              'Edit Project'.tr(),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Update project details and team members.'.tr(),
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

                  _dividerLabel(theme, 'Project Details'.tr()),
                  const SizedBox(height: 12),

                  // ── Project Name ──────────────────────────────────
                  _FieldLabel(label: 'Project Name *'.tr(), theme: theme),
                  const SizedBox(height: 6),
                  GlassInputField(
                    controller: nameController,
                    hint: 'Enter project name'.tr(),
                  ),
                  const SizedBox(height: 14),

                  // ── Description ────────────────────────────────────
                  _FieldLabel(label: 'Description'.tr(), theme: theme),
                  const SizedBox(height: 6),
                  GlassInputField(
                    controller: descController,
                    hint: 'Enter project description'.tr(),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),

                  _dividerLabel(theme, 'Schedule'.tr()),
                  const SizedBox(height: 12),
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
                              controller: startDateController,
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
                                  initialDate: DateTime.now(),
                                );
                                if (date != null) {
                                  setState(
                                    () => startDateController.text =
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
                            _FieldLabel(label: 'End Date *'.tr(), theme: theme),
                            const SizedBox(height: 6),
                            GlassInputField(
                              controller: endDateController,
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
                                  initialDate: DateTime.now(),
                                );
                                if (date != null) {
                                  setState(
                                    () => endDateController.text =
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
                  _FieldLabel(label: 'Project Color'.tr(), theme: theme),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: colors.map((color) {
                      final isSelected = selectedColor == color;
                      return GestureDetector(
                        onTap: () => setState(() => selectedColor = color),
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

                  _dividerLabel(theme, 'Team'.tr()),
                  const SizedBox(height: 12),

                  // ── Team Mates Dropdown ────────────────────────────────────────
                  BlocBuilder<GetUserProfileCubit, GetUserProfileState>(
                    builder: (context, profileState) {
                      List<String> teamMates = [];
                      if (profileState is GetUserProfileSuccess) {
                        teamMates = profileState.profileModel.teamMates;
                      }

                      if (teamMates.isEmpty) return const SizedBox.shrink();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FieldLabel(
                            label: 'Select from teammates'.tr(),
                            theme: theme,
                          ),
                          const SizedBox(height: 6),
                          StatusDropdownTasks(
                            items: teamMates,
                            hint: 'Select a teammate'.tr(),
                            value: null,
                            onChanged: (value) {
                              if (value != null && value.isNotEmpty) {
                                final currentText = membersController.text
                                    .trim();
                                if (!currentText.contains(value)) {
                                  membersController.text = currentText.isEmpty
                                      ? value
                                      : '$currentText\n$value';
                                }
                              }
                            },
                          ),
                          const SizedBox(height: 14),
                        ],
                      );
                    },
                  ),

                  // ── Members ────────────────────────────────────────
                  _FieldLabel(label: 'Team Members'.tr(), theme: theme),
                  const SizedBox(height: 6),
                  GlassInputField(
                    controller: membersController,
                    maxLines: 4,
                    hint: 'One member per line'.tr(),
                  ),
                  const SizedBox(height: 20),

                  _dividerLabel(theme, 'Attachments'.tr()),
                  const SizedBox(height: 12),

                  // ── File selector ──────────────────────────────────
                  FileSelectorWidget(
                    selectedFiles: attachedFiles,
                    onFilesChanged: (files) =>
                        setState(() => attachedFiles = files),
                  ),
                  const SizedBox(height: 28),

                  // ── Action buttons ─────────────────────────────────
                  GlassButton(
                    label: 'Update Project'.tr(),
                    icon: Icons.edit_rounded,
                    backgroundColor: theme.colorScheme.primary,
                    gradient: null,
                    onPressed: () {
                      final members = membersController.text
                          .split('\n')
                          .map((e) => e.trim())
                          .where((e) => e.isNotEmpty)
                          .toList();

                      updateProjectCubit.updateProject(
                        id: widget.project.id,
                        name: nameController.text,
                        description: descController.text,
                        endDate: endDateController.text,
                        color: selectedColor,
                        usernameMember: members,
                        attachedFiles: attachedFiles,
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
