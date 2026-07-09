import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:team_manager/features/home/cubit/get_all_project_cubit/project_cubit.dart';
import 'package:team_manager/features/home/cubit/get_all_project_cubit/project_state.dart';
import 'package:team_manager/features/home/models/project_model.dart';
import 'package:team_manager/features/home/models/task_model.dart';
import 'package:team_manager/features/home/widgets/announce_dialog.dart';
import 'package:team_manager/features/home/widgets/announcements_tab.dart';
import 'package:team_manager/features/home/widgets/delete_project_dialog.dart';
import 'package:team_manager/features/home/widgets/members_tab.dart';
import 'package:team_manager/features/home/widgets/overview_tab.dart';
import 'package:team_manager/features/home/widgets/tasks_tab.dart';
import 'package:team_manager/features/home/widgets/update_project_dialog.dart';
import 'package:team_manager/features/chat/widgets/chat_tab.dart';
import 'package:team_manager/features/settings/widgets/tab_item.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:team_manager/core/helpers/cache_helper.dart';

class HomeProjectDetails extends StatefulWidget {
  const HomeProjectDetails({
    super.key,
    required this.projectId,
    required this.isAdmin,
  });

  final String projectId;
  final bool isAdmin;

  @override
  State<HomeProjectDetails> createState() => _HomeProjectDetailsState();
}

class _HomeProjectDetailsState extends State<HomeProjectDetails>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<TaskModel>? tasks;
  ProjectModel? project;

  // Tab indices
  static const int _tabOverview = 0;
  static const int _tabTasks = 1;
  static const int _tabMembers = 2;
  static const int _tabChat = 3;
  static const int _tabAnnouncements = 4;

  @override
  void initState() {
    super.initState();
    // 5 tabs: Overview, Tasks, Members, Chat, Announcements
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    BlocProvider.of<ProjectCubit>(context).getOneProject(widget.projectId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _navigateTo(int index) {
    _tabController.animateTo(index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: BlocBuilder<ProjectCubit, ProjectState>(
        builder: (context, state) {
          if (state is ProjectOneSuccessState) {
            project = state.project;
            tasks = state.tasks;
          }

          // ── Loading / error states ─────────────────────────────────────
          if (project == null || tasks == null) {
            if (state is ProjectErrorState) {
              return _buildErrorState(theme, state.message);
            }
            return _buildLoadingState(theme);
          }

          // ── Main layout (Column — no NestedScrollView overflow) ────────
          return SafeArea(
            child: Column(
              children: [
                // ── HEADER (non-scrolling) ─────────────────────────────
                _buildHeader(theme, isDark),

                // ── TAB BAR (non-scrolling) ────────────────────────────
                _buildTabBar(theme, isDark),

                // ── TAB CONTENT (fills remaining space) ───────────────
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      // 0 — Overview
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: OverviewTab(project: project!),
                      ),
                      // 1 — Tasks
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TasksTab(
                          project: project!,
                          countTasks: tasks!.length,
                          projectDetails: true,
                        ),
                      ),
                      // 2 — Members
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: MembersTab(
                            id: project!.id,
                            totalMembers: project!.totalMembers.toString(),
                            usernameMembers: project!.usernameMembers,
                            emails: project!.emails,
                            isAdmin: widget.isAdmin,
                          ),
                        ),
                      ),
                      // 3 — Chat (75% height enforced inside ChatTab)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ChatTab(projectId: project!.id),
                      ),
                      // 4 — Announcements
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: AnnouncementsTab(
                          isAdmin: widget.isAdmin,
                          projectId: project!.id,
                        ),
                        //  AnnouncementScreen(
                        //   projectName: project!.name,
                        //   adminUsername: project!.usernameAdmin,

                        //   projectId: project!.id,
                        // ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(ThemeData theme, bool isDark) {
    final percent = project!.percent.clamp(0, 100);

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [const Color(0xFFEFF6FF), const Color(0xFFF8FAFC)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: back button + project name + menu ───────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 6, 0, 0),
            child: Row(
              children: [
                // Back button
                IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    GoRouter.of(context).pop();
                    BlocProvider.of<ProjectCubit>(context).getProjects();
                  },
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary.withValues(
                      alpha: 0.1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(8),
                    minimumSize: const Size(28, 28),
                  ),
                ),
                const SizedBox(width: 10),

                // Project name + badge
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        project!.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (project!.description.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        _ProjectDescriptionWidget(
                          description: project!.description,
                          theme: theme,
                        ),
                      ],
                    ],
                  ),
                ),

                // Admin announce shortcut
                if (project!.usernameAdmin ==
                        CacheHelper.getData(key: 'username') ||
                    widget.isAdmin)
                  IconButton(
                    onPressed: () =>
                        showAnnounceDialog(context, widget.projectId),
                    icon: const Icon(
                      Icons.campaign_rounded,
                      color: Color(0xFF8B5CF6),
                      size: 20,
                    ),
                    tooltip: 'Announce',
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(
                        0xFF8B5CF6,
                      ).withValues(alpha: 0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(8),
                      minimumSize: const Size(36, 36),
                    ),
                  ),

                // 3-dot menu (admin only)
                if (widget.isAdmin)
                  PopupMenuButton<String>(
                    color: theme.colorScheme.surface,
                    iconColor: theme.iconTheme.color,
                    icon: const Icon(Icons.more_vert_rounded),
                    offset: const Offset(0, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    onSelected: (value) {
                      if (value == 'edit') {
                        showDialog(
                          context: context,
                          builder: (_) => UpdateProjectDialog(
                            project: project!,
                            projectDetails: true,
                          ),
                        );
                      } else if (value == 'delete') {
                        showDialog(
                          context: context,
                          builder: (_) => DeleteProjectDialog(
                            projectID: project!.id,
                            projectDetails: true,
                            onPressed: () {
                              GoRouter.of(context).pop();
                              BlocProvider.of<ProjectCubit>(
                                context,
                              ).getProjects();
                            },
                          ),
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        height: 42,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.edit_outlined,
                              size: 16,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Edit Project'.tr(),
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        height: 42,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.delete_outline_rounded,
                              size: 16,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Delete Project'.tr(),
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // ── Stats row ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: _StatChip(
                    icon: Icons.assignment_outlined,
                    value: '${tasks!.length}',
                    label: 'Tasks'.tr(),
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatChip(
                    icon: Icons.people_outline_rounded,
                    value: '${project!.totalMembers}',
                    label: 'Members'.tr(),
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatChip(
                    icon: Icons.done_all_rounded,
                    value: '$percent%',
                    label: 'Done'.tr(),
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatChip(
                    icon: Icons.schedule_rounded,
                    value: project!.duration,
                    label: 'Age'.tr(),
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),

          // ── Progress bar ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress'.tr(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.hintColor,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      '$percent%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _progressColor(percent),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: percent / 100),
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) {
                      return LinearProgressIndicator(
                        value: value,
                        minHeight: 8,
                        backgroundColor: _progressColor(
                          percent,
                        ).withValues(alpha: 0.12),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _progressColor(percent),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _progressColor(int percent) {
    if (percent >= 70) return const Color(0xFF10B981);
    if (percent >= 40) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  // ── Tab bar ────────────────────────────────────────────────────────────────

  Widget _buildTabBar(ThemeData theme, bool isDark) {
    final tabs = [
      (icon: Icons.bar_chart_rounded, label: 'Overview'.tr()),
      (icon: Icons.task_alt_rounded, label: 'Tasks'.tr()),
      (icon: Icons.people_outline_rounded, label: 'Members'.tr()),
      (icon: Icons.chat_bubble_outline_rounded, label: 'Chat'.tr()),
      (icon: Icons.campaign_rounded, label: 'Announce'.tr()),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: List.generate(tabs.length, (index) {
            // Announcements tab gets special purple color when selected
            final isAnnounce = index == _tabAnnouncements;
            return TabItem(
              text: tabs[index].label,
              icon: tabs[index].icon,
              index: index,
              isSelected: _tabController.index == index,
              onTap: () => _navigateTo(index),
            );
          }),
        ),
      ),
    );
  }

  // ── Error / loading states ─────────────────────────────────────────────────

  Widget _buildLoadingState(ThemeData theme) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skeleton header
            Container(
              margin: const EdgeInsets.all(16),
              height: 160,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const Expanded(
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, String message) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline_rounded,
                    size: 44,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load project'.tr(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => BlocProvider.of<ProjectCubit>(
                    context,
                  ).getOneProject(widget.projectId),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text('Retry'.tr()),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Stat chip ─────────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.1 : 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.2 : 0.12),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 9,
              color: theme.hintColor,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ProjectDescriptionWidget extends StatefulWidget {
  final String description;
  final ThemeData theme;

  const _ProjectDescriptionWidget({
    required this.description,
    required this.theme,
  });

  @override
  State<_ProjectDescriptionWidget> createState() =>
      _ProjectDescriptionWidgetState();
}

class _ProjectDescriptionWidgetState extends State<_ProjectDescriptionWidget> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final style = widget.theme.textTheme.bodySmall?.copyWith(
      color: widget.theme.hintColor,
      fontSize: 12,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final span = TextSpan(text: widget.description, style: style);
        final tp = TextPainter(
          text: span,
          maxLines: 3,
          textDirection: Directionality.of(context),
        );
        tp.layout(maxWidth: constraints.maxWidth);

        if (!tp.didExceedMaxLines) {
          return Text(widget.description, style: style);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isExpanded)
              Text(
                widget.description,
                style: style,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              )
            else
              Container(
                constraints: const BoxConstraints(maxHeight: 70),
                child: Scrollbar(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Text(widget.description, style: style),
                  ),
                ),
              ),
            GestureDetector(
              onTap: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  isExpanded ? 'Show less'.tr() : 'Show more'.tr(),
                  style: TextStyle(
                    color: widget.theme.primaryColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
