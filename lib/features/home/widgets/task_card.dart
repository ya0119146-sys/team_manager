import 'package:flutter/material.dart';
import 'package:team_manager/features/home/cubit/delete_task_cubit/delete_task_cubit.dart';
import 'package:team_manager/core/helpers/cache_helper.dart';
import 'package:team_manager/features/home/cubit/update_task_status_cubit/update_task_status_cubit.dart';
import 'package:team_manager/features/home/models/task_model.dart';
import 'package:team_manager/core/widgets/glass_panel.dart';
import 'package:team_manager/core/widgets/status_chip.dart';
import 'package:team_manager/features/home/widgets/delete_task_dialog.dart';
import 'package:team_manager/features/home/widgets/get_color.dart';
import 'package:team_manager/features/home/widgets/update_task_dialog.dart';
import 'package:team_manager/features/home/widgets/task_details_bottom_sheet.dart';
import 'package:team_manager/features/auth/widgets/custom_scafold_messanger.dart';
import 'package:easy_localization/easy_localization.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onActionDone;
  final int index;
  final bool projectDetails;
  const TaskCard({
    super.key,
    required this.task,
    required this.onActionDone,
    this.index = 0,
    this.projectDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    final deleteCubit = DeleteTaskCubit.get(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = getColor(task.color);
    final isOverdue = _safeParseDate(task.endDate).isBefore(DateTime.now());

    final Widget cardBody = GlassPanel(
      padding: const EdgeInsets.all(16),
      border: Border.all(
        color: cardColor.withValues(alpha: isDark ? 0.35 : 0.2),
        width: 1.5,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Title, User Initial, and Options (Admins only)
          Row(
            children: [
              Expanded(
                child: Text(
                  task.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),

              // Stylish gradient avatar for assigned member
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [cardColor, cardColor.withValues(alpha: 0.6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: cardColor.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(1.5),
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: theme.colorScheme.surface,
                  child: Text(
                    task.usernameMember.isNotEmpty
                        ? task.usernameMember
                              .substring(0, _min(2, task.usernameMember.length))
                              .toUpperCase()
                        : 'NA',
                    style: TextStyle(
                      color: cardColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 9,
                    ),
                  ),
                ),
              ),

              if (CacheHelper.getData(key: 'role')?.toString().toLowerCase() ==
                  'admin')
                PopupMenuButton<String>(
                  color: theme.colorScheme.surface,
                  iconColor: theme.iconTheme.color,
                  offset: const Offset(0, 36),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (value) {
                    if (value == 'edit Task') {
                      showDialog(
                        context: context,
                        builder: (_) => UpdateTaskDialog(
                          task: task,
                          projectDetails: projectDetails,
                        ),
                      );
                    } else if (value == 'delete Task') {
                      showDeleteTaskDialog(
                        context: context,
                        projectId: task.projectId!,
                        onConfirm: () async {
                          await deleteCubit.deleteTask(id: task.id);
                          onActionDone();
                        },
                      );
                    } else if (value == 'accept Task') {
                      UpdateTaskStatusCubit.get(context).updateTaskStatus(
                        id: task.id,
                        projectId: task.projectId ?? '',
                        status: 'Accepted',
                      );
                      customScafoldMessenger(
                        context,
                        'Accepting task...'.tr(),
                        color: Colors.green,
                      );
                      Future.delayed(
                        const Duration(milliseconds: 800),
                        onActionDone,
                      );
                    } else if (value == 'reject Task') {
                      UpdateTaskStatusCubit.get(context).updateTaskStatus(
                        id: task.id,
                        projectId: task.projectId ?? '',
                        status: 'In-progress',
                      );
                      customScafoldMessenger(
                        context,
                        'Rejecting task back to In-progress...'.tr(),
                        color: Colors.orange,
                      );
                      Future.delayed(
                        const Duration(milliseconds: 800),
                        onActionDone,
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit Task',
                      height: 40,
                      child: Row(
                        children: [
                          const Icon(Icons.edit_outlined, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Edit Task'.tr(),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete Task',
                      height: 40,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.delete_outline_rounded,
                            size: 16,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Delete Task'.tr(),
                            style: TextStyle(fontSize: 12, color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                    if (task.status.toLowerCase() == 'reviewing' ||
                        task.status.toLowerCase() == 'done') ...[
                      PopupMenuItem(
                        value: 'accept Task',
                        height: 40,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle_outline,
                              size: 16,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Accept Task'.tr(),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'reject Task',
                        height: 40,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.cancel_outlined,
                              size: 16,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Reject Task'.tr(),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
            ],
          ),

          const SizedBox(height: 6),

          // Task description
          Text(
            task.description.isEmpty
                ? 'No description provided.'.tr()
                : task.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.75),
              height: 1.3,
            ),
          ),

          const SizedBox(height: 14),

          // Project tag and status chip
          Row(
            children: [
              StatusChip(status: task.status),
              const SizedBox(width: 8),
              if (task.projectName != null && task.projectName!.isNotEmpty)
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: cardColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      task.projectName!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: cardColor,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Footer: End Date
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 13,
                color: isOverdue ? Colors.red : theme.hintColor,
              ),
              const SizedBox(width: 6),
              Text(
                task.endDate,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isOverdue ? Colors.red : theme.hintColor,
                  fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (isOverdue) ...[
                const Spacer(),
                Text(
                  'Overdue'.tr(),
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 60).clamp(0, 250)),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 24 * (1.0 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) =>
                TaskDetailsBottomSheet(task: task, onUpdated: onActionDone),
          );
        },
        child: cardBody,
      ),
    );
  }
}

DateTime _safeParseDate(String text) {
  try {
    final cleaned = text.replaceAll('/', '-');
    final parts = cleaned.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  } catch (e) {
    return DateTime.now();
  }
}

int _min(int a, int b) => a < b ? a : b;
