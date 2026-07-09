import 'package:flutter/material.dart';
import 'package:team_manager/features/home/models/project_model.dart';
import 'package:team_manager/features/home/screens/home_project_details.dart';
import 'package:team_manager/core/widgets/glass_panel.dart';
import 'package:team_manager/features/home/widgets/delete_project_dialog.dart';
import 'package:team_manager/features/home/widgets/get_color.dart';
import 'package:team_manager/features/home/widgets/update_project_dialog.dart';
import 'package:easy_localization/easy_localization.dart';

class ProjectCard extends StatelessWidget {
  final ProjectModel project;
  final bool isAdmin;
  final int index;

  const ProjectCard({
    super.key,
    required this.project,
    required this.isAdmin,
    this.index = 0,
  });

  Color _progressColor(int percent) {
    if (percent >= 70) return const Color(0xFF10B981);
    if (percent >= 40) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  @override
  Widget build(BuildContext context) {
    final Color cardColor = getColor(project.color);
    final members = project.usernameMembers ?? [];
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Widget cardBody = GlassPanel(
      padding: const EdgeInsets.all(16),
      border: Border.all(
        color: cardColor.withValues(alpha: isDark ? 0.35 : 0.2),
        width: 1.5,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Color bar indicator at the top
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: cardColor.withValues(alpha: 0.4),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Header: Name and Popup Menu
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  project.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isAdmin)
                PopupMenuButton<String>(
                  color: theme.colorScheme.surface,
                  iconColor: theme.iconTheme.color,
                  offset: const Offset(0, 36),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (value) {
                    if (value == 'edit project') {
                      showDialog(
                        context: context,
                        builder: (_) => UpdateProjectDialog(project: project),
                      );
                    } else if (value == 'delete project') {
                      showDialog(
                        context: context,
                        builder: (_) =>
                            DeleteProjectDialog(projectID: project.id),
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit project',
                      height: 40,
                      child: Row(
                        children: [
                          const Icon(Icons.edit_outlined, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Edit Project'.tr(),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete project',
                      height: 40,
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline_rounded,
                            size: 16,
                            color: theme.colorScheme.error,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Delete Project'.tr(),
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),

          const SizedBox(height: 6),

          // Description
          Text(
            project.description.isEmpty
                ? 'No description provided.'.tr()
                : project.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.75),
              height: 1.3,
            ),
          ),

          const SizedBox(height: 16),

          // Progress text & stats
          Row(
            children: [
              Text(
                "Progress".tr(),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                "${project.percent}%",
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _progressColor(project.percent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Animated progress bar
          AnimatedProgressBar(
            value: project.percent / 100,
            color: _progressColor(project.percent),
            backgroundColor: _progressColor(
              project.percent,
            ).withValues(alpha: 0.12),
          ),

          const SizedBox(height: 14),

          // Footer info
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: cardColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(Icons.task_alt_rounded, size: 13, color: cardColor),
                    const SizedBox(width: 4),
                    Text(
                      '${project.totalTasks}${' Tasks'.tr()}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cardColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (members.isNotEmpty)
                SizedBox(
                  height: 28,
                  width: (members.length.clamp(0, 4) * 14) + 18,
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: List.generate(
                      members.length > 4 ? 5 : members.length,
                      (index) {
                        if (index == 4 && members.length > 4) {
                          return Positioned(
                            left: index * 14,
                            child: CircleAvatar(
                              radius: 9,
                              backgroundColor:
                                  theme.colorScheme.surfaceContainerHighest,
                              child: Text(
                                '+${members.length - 4}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }
                        final name = members[index];
                        return Positioned(
                          left: index * 14,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                    theme.cardTheme.color ??
                                    theme.colorScheme.surface,
                                width: 1.5,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 9,
                              backgroundColor:
                                  theme.colorScheme.primaryContainer,
                              child: Text(
                                name.isNotEmpty ? name[0].toUpperCase() : 'U',
                                style: TextStyle(
                                  color: theme.colorScheme.onPrimaryContainer,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  HomeProjectDetails(projectId: project.id, isAdmin: isAdmin),
            ),
          );
        },
        child: cardBody,
      ),
    );
  }
}

class AnimatedProgressBar extends StatelessWidget {
  final double value;
  final Color color;
  final Color backgroundColor;

  const AnimatedProgressBar({
    super.key,
    required this.value,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 700),
      tween: Tween<double>(begin: 0.0, end: value),
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 7,
            child: LinearProgressIndicator(
              value: animatedValue,
              color: color,
              backgroundColor: backgroundColor,
              minHeight: 7,
            ),
          ),
        );
      },
    );
  }
}
