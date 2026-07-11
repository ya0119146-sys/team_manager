import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:team_manager/core/helpers/cache_helper.dart';
import 'package:team_manager/core/helpers/secure_storage_helper.dart';
import 'package:team_manager/core/widgets/glass_button.dart';
import 'package:team_manager/core/widgets/status_chip.dart';
import 'package:team_manager/core/widgets/custom_dropdown.dart';
import 'package:team_manager/features/home/cubit/get_admin_dashboard_cubit/get_admin_dashboard_cubit.dart';
import 'package:team_manager/features/home/cubit/get_user_task_cubit/get_user_task_cubit.dart';
import 'package:team_manager/features/home/cubit/update_task_status_cubit/update_task_status_cubit.dart';
import 'package:team_manager/features/home/cubit/update_task_status_cubit/update_task_status_state.dart';
import 'package:team_manager/features/home/models/attachment_model.dart';
import 'package:team_manager/features/home/models/task_model.dart';
import 'package:team_manager/features/home/cubit/delte_attachment_cubit/delete_attachment_cubit.dart';
import 'package:team_manager/features/home/cubit/delte_attachment_cubit/delete_attachment_state.dart';
import 'package:team_manager/features/home/widgets/file_selector_widget.dart';
import 'package:team_manager/features/home/widgets/get_color.dart';
import 'package:team_manager/features/auth/widgets/custom_scafold_messanger.dart';
import 'package:easy_localization/easy_localization.dart';

class TaskDetailsBottomSheet extends StatefulWidget {
  final TaskModel task;
  final VoidCallback onUpdated;
  const TaskDetailsBottomSheet({
    super.key,
    required this.task,
    required this.onUpdated,
  });

  @override
  State<TaskDetailsBottomSheet> createState() => _TaskDetailsBottomSheetState();
}

class _TaskDetailsBottomSheetState extends State<TaskDetailsBottomSheet> {
  late String _selectedStatus;
  List<PlatformFile> _pickedFiles = [];
  bool _canEditStatus = false;
  bool _isAdminUser = false;
  Dio dio = Dio();
  final _deleteAttachmentCubit = DeleteAttachmentCubit();

  @override
  void dispose() {
    _deleteAttachmentCubit.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.task.status;

    final String role =
        CacheHelper.getData(key: 'role')?.toString().toLowerCase() ?? 'member';
    _isAdminUser = (role == 'admin');

    // Default for admins. Members must be verified async.
    _canEditStatus = _isAdminUser;

    if (!_isAdminUser) {
      _verifyMemberOwnership();
    }
  }

  Future<void> _verifyMemberOwnership() async {
    final String? secureUsername = await SecureStorageHelper.getUsername();
    final String cacheUsername =
        CacheHelper.getData(key: 'username')?.toString() ?? '';

    final currentUsername = secureUsername?.isNotEmpty == true
        ? secureUsername
        : (cacheUsername.isNotEmpty ? cacheUsername : '');

    if (mounted && currentUsername != null && currentUsername.isNotEmpty) {
      setState(() {
        _canEditStatus =
            widget.task.usernameMember.trim().toLowerCase() ==
            currentUsername.trim().toLowerCase();
      });
    }
  }

  Future<void> _downloadFile(
    BuildContext context,
    String url,
    String fileName,
  ) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Download File'.tr()),
          content: Text('${'Do you want to download '.tr()}$fileName?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'.tr()),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Download'.tr()),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        if (context.mounted) {
          customScafoldMessenger(
            context,
            'Downloading file...'.tr(),
            color: Colors.blue,
          );
        }

        // 1. Download file into memory
        final response = await dio.get(
          url,
          options: Options(responseType: ResponseType.bytes),
        );

        // 2. Use FilePicker to save bytes directly, bypassing dart:io permission issues
        final String? savePath = await FilePicker.platform.saveFile(
          dialogTitle: '${'Select folder to save '.tr()}$fileName',
          fileName: fileName,
          bytes: Uint8List.fromList(response.data as List<int>),
        );

        if (savePath != null) {
          if (context.mounted) {
            customScafoldMessenger(
              context,
              'File downloaded successfully!'.tr(),
              color: Colors.green,
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          print("E $e");
          customScafoldMessenger(
            context,
            '${'Error downloading file: '.tr()}$e',
            color: Colors.red,
          );
        }
      }
    }
  }

  /// Members must upload files when updating to in-progress or done
  bool get _requiresFiles =>
      !_isAdminUser &&
      (_selectedStatus.toLowerCase() == 'in-progress' ||
          _selectedStatus.toLowerCase() == 'done');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = getColor(widget.task.color);

    // Admin sees all statuses; Members see only member-accessible ones
    final availableStatuses = _isAdminUser
        ? const ['Pending', 'In-progress', 'Reviewing', 'Done', 'Accepted']
        : const ['Pending', 'In-progress', 'Done'];

    return BlocConsumer<UpdateTaskStatusCubit, UpdateTaskStatusState>(
      listener: (context, state) {
        if (state is UpdateTaskStatusSuccess) {
          customScafoldMessenger(
            context,
            'Task status updated successfully!'.tr(),
            color: Colors.green,
          );
          GetAdminDashboardCubit.get(context).getAdminDashboard();
          GetUserTaskCubit.get(context).getUserTask();
          widget.onUpdated();
          Navigator.pop(context);
        } else if (state is UpdateTaskStatusError) {
          customScafoldMessenger(context, state.error, color: Colors.red);
        }
      },
      builder: (context, state) {
        return ModalProgressHUD(
          inAsyncCall: state is UpdateTaskStatusLoading,
          child: Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 8,
              bottom: MediaQuery.of(context).viewInsets.bottom + 28,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 24,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Drag Handle ────────────────────────────────────────
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: theme.dividerColor.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // ── Color accent bar ───────────────────────────────────
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [cardColor, cardColor.withValues(alpha: 0.3)],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Header: Title + Status chip ────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.task.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      StatusChip(status: widget.task.status),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // ── Description ────────────────────────────────────────
                  if (widget.task.description.isNotEmpty)
                    Text(
                      widget.task.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withValues(
                          alpha: 0.75,
                        ),
                        height: 1.5,
                      ),
                    ),
                  const SizedBox(height: 20),

                  // ── Info cards row ─────────────────────────────────────
                  Row(
                    children: [
                      _InfoCard(
                        icon: Icons.calendar_today_rounded,
                        label: 'Start Date'.tr(),
                        value: widget.task.startDate.isNotEmpty
                            ? widget.task.startDate
                            : '—',
                        color: cardColor,
                        theme: theme,
                      ),
                      const SizedBox(width: 10),
                      _InfoCard(
                        icon: Icons.event_rounded,
                        label: 'End Date'.tr(),
                        value: widget.task.endDate.isNotEmpty
                            ? widget.task.endDate
                            : '—',
                        color: cardColor,
                        theme: theme,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      _InfoCard(
                        icon: Icons.person_rounded,
                        label: 'Assigned To'.tr(),
                        value: widget.task.usernameMember.isNotEmpty
                            ? widget.task.usernameMember
                            : '—',
                        color: cardColor,
                        theme: theme,
                      ),
                      const SizedBox(width: 10),
                      if (widget.task.projectName != null &&
                          widget.task.projectName!.isNotEmpty)
                        _InfoCard(
                          icon: Icons.folder_rounded,
                          label: 'Project'.tr(),
                          value: widget.task.projectName!,
                          color: cardColor,
                          theme: theme,
                        )
                      else
                        const Expanded(child: SizedBox()),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Attachments section ────────────────────────────────
                  if (widget.task.memberAttachment.isEmpty &&
                      widget.task.adminAttachment.isEmpty)
                    Column(
                      children: [
                        _SectionHeader(
                          icon: Icons.attach_file_rounded,
                          title: 'Deliverables & Attachments'.tr(),
                          theme: theme,
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 16,
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
                                Icons.cloud_upload_outlined,
                                color: theme.hintColor,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'No files uploaded yet.'.tr(),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.hintColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  else ...[
                    if (widget.task.memberAttachment.isNotEmpty)
                      _buildAttachmentsList(
                        widget.task.memberAttachment,
                        'Member Attachments'.tr(),
                        Icons.person_outline_rounded,
                        theme,
                        isDark,
                        cardColor,
                      ),
                    if (widget.task.adminAttachment.isNotEmpty)
                      _buildAttachmentsList(
                        widget.task.adminAttachment,
                        'Admin Attachments'.tr(),
                        Icons.admin_panel_settings_outlined,
                        theme,
                        isDark,
                        cardColor,
                      ),
                  ],
                  const SizedBox(height: 12),

                  // ── Status Update section ─────────────────────────────
                  if (_canEditStatus) ...[
                    Divider(
                      color: theme.dividerColor.withValues(alpha: 0.3),
                      height: 1,
                    ),
                    const SizedBox(height: 12),
                    _SectionHeader(
                      icon: Icons.autorenew_rounded,
                      title: 'Update Task Status'.tr(),
                      subtitle: _isAdminUser
                          ? 'Admin: manage all statuses'.tr()
                          : 'Submit your progress'.tr(),
                      theme: theme,
                    ),
                    const SizedBox(height: 14),

                    // Admin quick Accept/Reject shortcuts
                    if (_isAdminUser &&
                        (widget.task.status.toLowerCase() == 'reviewing' ||
                            widget.task.status.toLowerCase() == 'done')) ...[
                      Row(
                        children: [
                          Expanded(
                            child: _ActionButton(
                              label: 'Accept'.tr(),
                              icon: Icons.check_circle_rounded,
                              color: const Color(0xFF22C55E),
                              onPressed: () {
                                context
                                    .read<UpdateTaskStatusCubit>()
                                    .updateTaskStatus(
                                      id: widget.task.id,
                                      projectId: widget.task.projectId ?? '',
                                      status: 'Accepted',
                                    );
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _ActionButton(
                              label: 'Reject'.tr(),
                              icon: Icons.replay_rounded,
                              color: const Color(0xFFF97316),
                              onPressed: () {
                                context
                                    .read<UpdateTaskStatusCubit>()
                                    .updateTaskStatus(
                                      id: widget.task.id,
                                      projectId: widget.task.projectId ?? '',
                                      status: 'In-progress',
                                    );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Status Dropdown
                    CustomDropdown<String>(
                      initialValue: _selectedStatus,
                      items: availableStatuses
                          .map((s) => DropdownItem(value: s, label: s))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value;
                          if (!_requiresFiles) _pickedFiles = [];
                        });
                      },
                      prefixIcon: Icons.flag_outlined,
                    ),
                    const SizedBox(height: 16),

                    // Role badge hint
                    if (!_isAdminUser) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.blue.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              size: 15,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _selectedStatus.toLowerCase() ==
                                            'in-progress' ||
                                        _selectedStatus.toLowerCase() == 'done'
                                    ? 'Please upload your deliverable files to submit.'
                                          .tr()
                                    : 'When you start or finish your work, switch status and upload your files.'
                                          .tr(),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.blue.shade700,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // File picker shown when member selects In-progress or Done
                    if (_requiresFiles) ...[
                      FileSelectorWidget(
                        selectedFiles: _pickedFiles,
                        onFilesChanged: (files) {
                          setState(() {
                            _pickedFiles = files;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Submit button
                    GlassButton(
                      label: 'Submit Status Update'.tr(),
                      icon: Icons.send_rounded,
                      backgroundColor: theme.colorScheme.primary,
                      onPressed: () {
                        if (_requiresFiles) {
                          if (_pickedFiles.isEmpty) {
                            customScafoldMessenger(
                              context,
                              'Please upload at least one file to submit!'.tr(),
                              color: Colors.red,
                            );
                            return;
                          }
                          if (_pickedFiles.length >= 6) {
                            customScafoldMessenger(
                              context,
                              'You cannot upload more than 5 files!'.tr(),
                              color: Colors.red,
                            );
                            return;
                          }
                        }
                        context.read<UpdateTaskStatusCubit>().updateTaskStatus(
                          id: widget.task.id,
                          projectId: widget.task.projectId ?? '',
                          status: _selectedStatus,
                          attachedFiles: _pickedFiles.isNotEmpty
                              ? _pickedFiles
                              : null,
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAttachmentsList(
    List<AttachmentModel> attachments,
    String title,
    IconData icon,
    ThemeData theme,
    bool isDark,
    Color cardColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(icon: icon, title: title, theme: theme),
        const SizedBox(height: 10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: attachments.length,
          separatorBuilder: (_, __) => const SizedBox(height: 6),
          itemBuilder: (context, index) {
            final file = attachments[index];
            final format = file.format ?? 'file';
            final isImage =
                format.contains('image') ||
                format.contains('png') ||
                format.contains('jpg') ||
                format.contains('jpeg');

            return Container(
              decoration: BoxDecoration(
                color: isDark
                    ? theme.colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.4,
                      )
                    : theme.colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.6,
                      ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: 0.3),
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 4,
                ),
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: cardColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isImage
                        ? Icons.image_rounded
                        : Icons.insert_drive_file_rounded,
                    color: cardColor,
                    size: 20,
                  ),
                ),
                title: Text(
                  file.publicId.split('/').last,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  file.secureUrl,
                  style: TextStyle(fontSize: 10, color: theme.hintColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (CacheHelper.getData(
                          key: 'role',
                        )?.toString().toLowerCase() ==
                        'admin')
                      BlocConsumer<
                        DeleteAttachmentCubit,
                        DeleteAttachmentState
                      >(
                        bloc: _deleteAttachmentCubit,
                        listenWhen: (previous, current) {
                          if (current is DeleteAttachmentSuccess) {
                            return current.publicId == file.publicId;
                          } else if (current is DeleteAttachmentError) {
                            return current.publicId == file.publicId;
                          }
                          return false;
                        },
                        listener: (context, state) {
                          if (state is DeleteAttachmentSuccess) {
                            customScafoldMessenger(
                              context,
                              "Attachment deleted successfully".tr(),
                              color: Colors.green,
                            );

                            setState(() {
                              widget.task.adminAttachment
                                  .removeWhere((a) => a.publicId == state.publicId);
                              widget.task.memberAttachment
                                  .removeWhere((a) => a.publicId == state.publicId);
                            });

                            widget.onUpdated();
                          } else if (state is DeleteAttachmentError) {
                            customScafoldMessenger(
                              context,
                              state.message,
                              color: Colors.red,
                            );
                          }
                        },
                        builder: (context, state) {
                          if (state is DeleteAttachmentLoading && state.publicId == file.publicId) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.0),
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          }
                          return IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              _deleteAttachmentCubit.deleteAttachment(
                                projectId: widget.task.projectId ?? '',
                                publicId: file.publicId,
                                taskId: widget.task.id,
                              );
                            },
                            tooltip: 'Delete file'.tr(),
                          );
                        },
                      ),
                    IconButton(
                      icon: const Icon(Icons.download_rounded, size: 18),
                      onPressed: () => _downloadFile(
                        context,
                        file.secureUrl,
                        file.publicId.split('/').last,
                      ),
                      tooltip: 'Download file',
                    ),
                  ],
                ),
                onTap: () => _downloadFile(
                  context,
                  file.secureUrl,
                  file.publicId.split('/').last,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ── Reusable Sub-widgets ─────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final ThemeData theme;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isDark
              ? theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.35,
                )
              : theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.6,
                ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 13, color: color),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final ThemeData theme;

  const _SectionHeader({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor,
                  fontSize: 11,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.12),
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.4)),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      ),
    );
  }
}
