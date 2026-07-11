import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:team_manager/core/widgets/glass_panel.dart';
import 'package:team_manager/features/home/models/project_model.dart';
import 'package:team_manager/features/home/models/attachment_model.dart';
import 'package:team_manager/features/home/cubit/delte_attachment_cubit/delete_attachment_cubit.dart';
import 'package:team_manager/features/home/cubit/delte_attachment_cubit/delete_attachment_state.dart';
import 'package:team_manager/features/auth/widgets/custom_scafold_messanger.dart';
import 'package:easy_localization/easy_localization.dart';

class OverviewTab extends StatefulWidget {
  const OverviewTab({super.key, required this.project});
  final ProjectModel project;

  @override
  State<OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<OverviewTab> {
  final Dio dio = Dio();
  final _deleteAttachmentCubit = DeleteAttachmentCubit();

  @override
  void dispose() {
    _deleteAttachmentCubit.close();
    super.dispose();
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

        final response = await dio.get(
          url,
          options: Options(responseType: ResponseType.bytes),
        );

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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTaskOverviewCard(context),
          // if (widget.project.attachments.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildAttachmentsCard(context),
          //  ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTaskOverviewCard(BuildContext context) {
    final theme = Theme.of(context);

    return GlassPanel(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Task Overview'.tr(),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildTaskStatRow(
            context,
            'Total Tasks'.tr(),
            widget.project.totalTasks.toString(),
            Icons.format_list_bulleted_rounded,
            Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildTaskStatRow(
            context,
            'Pending'.tr(),
            widget.project.pendingTasks.toString(),
            Icons.schedule_rounded,
            Colors.orange,
          ),
          const SizedBox(height: 16),
          _buildTaskStatRow(
            context,
            'In Progress'.tr(),
            widget.project.inProgressTasks.toString(),
            Icons.autorenew_rounded,
            Colors.purple,
          ),
          const SizedBox(height: 16),
          _buildTaskStatRow(
            context,
            'Reviewing'.tr(),
            widget.project.reviewingTasks.toString(),
            Icons.preview_rounded,
            Colors.teal,
          ),
          const SizedBox(height: 16),
          _buildTaskStatRow(
            context,
            'Accepted'.tr(),
            widget.project.acceptedTasks.toString(),
            Icons.thumb_up_alt_rounded,
            Colors.indigo,
          ),
          const SizedBox(height: 16),
          _buildTaskStatRow(
            context,
            'Done'.tr(),
            widget.project.doneTasks.toString(),
            Icons.check_circle_outline_rounded,
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildTaskStatRow(
    BuildContext context,
    String label,
    String count,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: 0.5),
            ),
          ),
          child: Text(
            count,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentsCard(BuildContext context) {
    final theme = Theme.of(context);

    return GlassPanel(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.attach_file_rounded,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Attachments'.tr(),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${widget.project.attachments.length}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.project.attachments.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final attachment = widget.project.attachments[index];
              return _buildAttachmentItem(context, attachment);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentItem(
    BuildContext context,
    AttachmentModel attachment,
  ) {
    final theme = Theme.of(context);

    // Try to extract a clean file name
    String fileName = attachment.publicId.split('/').last;
    if (attachment.format != null &&
        !fileName.endsWith('.${attachment.format}')) {
      fileName += '.${attachment.format}';
    }

    final isImage =
        attachment.resourceType == 'image' ||
        [
          'jpg',
          'jpeg',
          'png',
          'gif',
          'webp',
        ].contains(attachment.format?.toLowerCase());

    return InkWell(
      onTap: () => _downloadFile(context, attachment.secureUrl, fileName),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (isImage ? Colors.blue : Colors.red).withValues(
                  alpha: 0.1,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isImage ? Icons.image_outlined : Icons.picture_as_pdf_outlined,
                color: isImage ? Colors.blue : Colors.red,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (attachment.bytes != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _formatBytes(attachment.bytes!),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                BlocConsumer<DeleteAttachmentCubit, DeleteAttachmentState>(
                  bloc: _deleteAttachmentCubit,
                  listenWhen: (previous, current) =>
                      current is DeleteAttachmentSuccess ||
                      current is DeleteAttachmentError,
                  listener: (context, state) {
                    if (state is DeleteAttachmentSuccess) {
                      customScafoldMessenger(
                        context,
                        "Attachment deleted successfully".tr(),
                        color: Colors.green,
                      );
                      setState(() {
                        widget.project.attachments.removeWhere(
                          (element) => element.publicId == attachment.publicId,
                        );
                      });
                    } else if (state is DeleteAttachmentError) {
                      customScafoldMessenger(
                        context,
                        state.message,
                        color: Colors.red,
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is DeleteAttachmentLoading) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.0),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
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
                          projectId: widget.project.id,
                          publicId: attachment.publicId,
                        );
                      },
                      tooltip: 'Delete file'.tr(),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.download_rounded, size: 18),
                  onPressed: () =>
                      _downloadFile(context, attachment.secureUrl, fileName),
                  tooltip: 'Download file'.tr(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
