import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_manager/features/chat/cubit/chat_cubit/chat_bloc.dart';
import 'package:team_manager/features/chat/cubit/chat_cubit/chat_event.dart';
import 'package:team_manager/core/widgets/glass_input_field.dart';
import 'package:team_manager/core/widgets/glass_button.dart';

void showAnnounceDialog(BuildContext context, String projectId) {
  showDialog(
    context: context,
    builder: (context) {
      return AnnounceDialog(projectId: projectId);
    },
  );
}

class AnnounceDialog extends StatefulWidget {
  final String projectId;
  const AnnounceDialog({super.key, required this.projectId});

  @override
  State<AnnounceDialog> createState() => _AnnounceDialogState();
}

class _AnnounceDialogState extends State<AnnounceDialog> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  PlatformFile? selectedFile;
  bool isPinned = false;

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        selectedFile = result.files.first;
      });
    }
  }

  void _removeFile() {
    setState(() {
      selectedFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: theme.colorScheme.surface,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.campaign_outlined,
                      color: theme.colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Create Announcement',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.close, color: theme.iconTheme.color),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Share important updates and information with your team members.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 24),

            /// TITLE INPUT
            Text('Title *', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 8),
            GlassInputField(
              controller: titleController,
              hint: 'e.g., Project Kickoff Meeting',
            ),
            const SizedBox(height: 16),

            /// CONTENT INPUT
            Text('Content *', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 8),
            GlassInputField(
              controller: contentController,
              hint: 'Write your announcement message...',
              maxLines: 4,
            ),
            const SizedBox(height: 16),

            /// ATTACHMENT
            Text('Attachment (Optional)', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickFile,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.dividerColor),
                  borderRadius: BorderRadius.circular(12),
                  color: theme.colorScheme.surface,
                ),
                child: selectedFile == null
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.attach_file,
                            size: 20,
                            color: theme.iconTheme.color,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Attach File',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Icon(
                            Icons.description,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              selectedFile!.name,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              Icons.close,
                              size: 18,
                              color: theme.iconTheme.color,
                            ),
                            onPressed: _removeFile,
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),

            /// PIN TOGGLE
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.primaryContainer),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pin this announcement',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pinned announcements appear at the top and in the project chat',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: isPinned,
                    onChanged: (val) => setState(() => isPinned = val),
                    activeColor: theme.colorScheme.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            /// ACTION BUTTONS
            Row(
              children: [
                Expanded(
                  child: GlassButton(
                    isOutlined: true,
                    label: 'Cancel',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GlassButton(
                    label: 'Post',
                    icon: Icons.campaign,
                    onPressed: () {
                      final title = titleController.text.trim();
                      if (title.isEmpty) return;

                      context.read<ChatBloc>().add(
                        SendAnnouncementEvent(
                          projectId: widget.projectId,
                          title: title,
                          content: contentController.text.trim(),
                          filePaths: selectedFile != null && selectedFile!.path != null 
                              ? [selectedFile!.path!] 
                              : null,
                        ),
                      );
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
