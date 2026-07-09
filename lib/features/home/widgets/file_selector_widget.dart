import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:team_manager/features/auth/widgets/custom_scafold_messanger.dart';

class FileSelectorWidget extends StatefulWidget {
  final List<PlatformFile> selectedFiles;
  final ValueChanged<List<PlatformFile>> onFilesChanged;
  final int maxFiles;
  final int maxSizeInBytes; // e.g. 10 * 1024 * 1024 for 10MB

  const FileSelectorWidget({
    super.key,
    required this.selectedFiles,
    required this.onFilesChanged,
    this.maxFiles = 5,
    this.maxSizeInBytes = 10485760, // 10MB
  });

  @override
  State<FileSelectorWidget> createState() => _FileSelectorWidgetState();
}

class _FileSelectorWidgetState extends State<FileSelectorWidget> {
  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );

      if (result != null && result.files.isNotEmpty) {
        final List<PlatformFile> updatedList = List.from(widget.selectedFiles);
        int rejectedCount = 0;
        int sizeRejectedCount = 0;

        for (final file in result.files) {
          if (updatedList.length >= widget.maxFiles) {
            rejectedCount++;
            continue;
          }

          // Validate file size (< 10MB)
          if (file.size > widget.maxSizeInBytes) {
            sizeRejectedCount++;
            continue;
          }

          // Prevent duplicates by name and size
          if (!updatedList.any((f) => f.name == file.name && f.size == file.size)) {
            updatedList.add(file);
          }
        }

        widget.onFilesChanged(updatedList);

        if (sizeRejectedCount > 0 || rejectedCount > 0) {
          String warning = '';
          if (sizeRejectedCount > 0) {
            warning += '$sizeRejectedCount files exceeded the 10MB limit. ';
          }
          if (rejectedCount > 0) {
            warning += 'Cannot upload more than ${widget.maxFiles} files.';
          }
          if (mounted) {
            customScafoldMessenger(
              context,
              warning,
              color: Colors.orange,
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        customScafoldMessenger(
          context,
          'Error picking files: $e',
          color: Colors.red,
        );
      }
    }
  }

  void _removeFile(int index) {
    final List<PlatformFile> updatedList = List.from(widget.selectedFiles);
    updatedList.removeAt(index);
    widget.onFilesChanged(updatedList);
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = 0;
    double dBytes = bytes.toDouble();
    while (dBytes >= 1024 && i < suffixes.length - 1) {
      dBytes /= 1024;
      i++;
    }
    return '${dBytes.toStringAsFixed(1)} ${suffixes[i]}';
  }

  IconData _getFileIcon(String extension) {
    final ext = extension.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext)) {
      return Icons.image_outlined;
    }
    if (ext == 'pdf') return Icons.picture_as_pdf_outlined;
    if (['doc', 'docx', 'txt', 'rtf'].contains(ext)) {
      return Icons.description_outlined;
    }
    if (['zip', 'rar', '7z', 'tar', 'gz'].contains(ext)) {
      return Icons.folder_zip_outlined;
    }
    if (['xls', 'xlsx', 'csv'].contains(ext)) return Icons.table_chart_outlined;
    return Icons.insert_drive_file_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pick Button & Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Attachments (${widget.selectedFiles.length}/${widget.maxFiles})',
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (widget.selectedFiles.length < widget.maxFiles)
              TextButton.icon(
                onPressed: _pickFiles,
                icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
                label: const Text('Add files', style: TextStyle(fontSize: 12)),
              ),
          ],
        ),
        const SizedBox(height: 6),

        // Files List
        widget.selectedFiles.isEmpty
            ? Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: isDark ? 0.2 : 0.4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.15),
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      color: theme.hintColor.withValues(alpha: 0.5),
                      size: 28,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'No files attached yet (Max 5 files, < 10MB)',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                    ),
                  ],
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  border: Border.all(color: theme.dividerColor.withValues(alpha: 0.15)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.selectedFiles.length,
                  separatorBuilder: (_, __) => Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.1)),
                  itemBuilder: (context, index) {
                    final file = widget.selectedFiles[index];
                    final ext = file.extension ?? '';

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Row(
                        children: [
                          Icon(
                            _getFileIcon(ext),
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  file.name,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _formatBytes(file.size),
                                  style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 18),
                            onPressed: () => _removeFile(index),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
      ],
    );
  }
}
