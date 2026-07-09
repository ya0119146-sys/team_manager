import 'package:flutter/material.dart';
import 'package:team_manager/core/widgets/glass_panel.dart';
import 'package:team_manager/features/home/models/project_model.dart';
import 'package:team_manager/features/home/models/attachment_model.dart';
import 'package:easy_localization/easy_localization.dart';

class OverviewTab extends StatelessWidget {
  const OverviewTab({super.key, required this.project});
  final ProjectModel project;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTaskOverviewCard(context),
          if (project.attachments.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildAttachmentsCard(context),
          ],
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
            project.totalTasks.toString(),
            Icons.format_list_bulleted_rounded,
            Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildTaskStatRow(
            context,
            'Pending'.tr(),
            project.pendingTasks.toString(),
            Icons.schedule_rounded,
            Colors.orange,
          ),
          const SizedBox(height: 16),
          _buildTaskStatRow(
            context,
            'In Progress'.tr(),
            project.inProgressTasks.toString(),
            Icons.autorenew_rounded,
            Colors.purple,
          ),
          const SizedBox(height: 16),
          _buildTaskStatRow(
            context,
            'Reviewing'.tr(),
            project.reviewingTasks.toString(),
            Icons.preview_rounded,
            Colors.teal,
          ),
          const SizedBox(height: 16),
          _buildTaskStatRow(
            context,
            'Accepted'.tr(),
            project.acceptedTasks.toString(),
            Icons.thumb_up_alt_rounded,
            Colors.indigo,
          ),
          const SizedBox(height: 16),
          _buildTaskStatRow(
            context,
            'Done'.tr(),
            project.doneTasks.toString(),
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
                  '${project.attachments.length}',
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
            itemCount: project.attachments.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final attachment = project.attachments[index];
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
      onTap: () {
        // Placeholder for attachment tap logic
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening ${fileName}...'.tr()),
            duration: const Duration(seconds: 2),
          ),
        );
      },
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
            Icon(Icons.open_in_new_rounded, color: theme.hintColor, size: 20),
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
