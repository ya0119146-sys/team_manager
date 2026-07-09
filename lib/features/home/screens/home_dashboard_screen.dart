import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_manager/features/home/cubit/get_admin_dashboard_cubit/get_admin_dashboard_cubit.dart';
import 'package:team_manager/features/home/cubit/get_admin_dashboard_cubit/get_admin_dashboard_state.dart';
import 'package:team_manager/features/home/models/dashboard_model.dart';
import 'package:team_manager/features/home/widgets/stats_grid.dart';
import 'package:team_manager/features/home/widgets/productivity_chart.dart';
import 'package:team_manager/features/home/widgets/task_states.dashboard.dart';
import 'package:team_manager/features/home/widgets/team_performance_table.dart';
import 'package:team_manager/features/home/widgets/ai_insights_card.dart';
import 'package:team_manager/features/home/widgets/get_color.dart';
import 'package:team_manager/core/theme/app_colors.dart';
import 'package:team_manager/core/widgets/empty_state_widget.dart';
import 'package:team_manager/features/home/cubit/get_user_task_cubit/get_user_task_cubit.dart';
import 'package:team_manager/features/home/cubit/get_user_task_cubit/get_user_task_state.dart';
import 'package:easy_localization/easy_localization.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({
    super.key,
    required this.onNavigate,
    required this.isAdmin,
  });

  final Function(int index) onNavigate;
  final bool isAdmin;

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _headerController;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _headerFade = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOut,
    );
    _headerSlide =
        Tween<Offset>(begin: const Offset(0, -0.15), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _headerController,
            curve: Curves.easeOutCubic,
          ),
        );

    _refreshData();
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  void _refreshData() {
    _headerController.forward(from: 0);
    GetAdminDashboardCubit.get(context).getAdminDashboard();
    if (!widget.isAdmin) {
      GetUserTaskCubit.get(context).getUserTask();
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _getGreetingEmoji() {
    final hour = DateTime.now().hour;
    if (hour < 12) return '☀️';
    if (hour < 17) return '🌤';
    return '🌙';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _refreshData(),
          color: AppColors.accentBlue,
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          displacement: 20,
          strokeWidth: 2.5,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child:
                    BlocBuilder<GetAdminDashboardCubit, GetAdminDashboardState>(
                      builder: (context, state) {
                        if (state is GetAdminDashboardLoading) {
                          return _buildShimmerLoading(theme, isDark);
                        }

                        if (state is GetAdminDashboardError) {
                          return _buildErrorState(theme, state.error);
                        }

                        if (state is GetAdminDashboardSuccess) {
                          final data = state.dashboardModel;
                          return _buildDashboardContent(
                            theme,
                            isDark,
                            data,
                            state,
                          );
                        }

                        return const SizedBox(height: 400);
                      },
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardContent(
    ThemeData theme,
    bool isDark,
    DashboardModel data,
    GetAdminDashboardSuccess state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Hero Header Banner ──
        _buildHeroHeader(theme, isDark, data),

        // ── Dashboard Body ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              if (widget.isAdmin) ...[
                // A. Admin Layout

                // 1. AI Insights
                AIInsightsCard(
                  insights: state.aiInsights ?? '',
                  isLoading: state.isAiInsightsLoading,
                ),
                const SizedBox(height: 24),

                // 2. Stats Overview
                _buildSectionLabel(theme, Icons.dashboard_rounded, 'Overview'),
                const SizedBox(height: 12),
                StatsGrid(stats: data.stats, isAdmin: true),
                const SizedBox(height: 24),

                // 3. Productivity Chart
                _buildSectionLabel(
                  theme,
                  Icons.show_chart_rounded,
                  'Analytics',
                ),
                const SizedBox(height: 12),
                ProductivityChart(weeklyProductivity: data.weeklyProductivity),
                const SizedBox(height: 16),
                TaskStatesDashboard(dashboardModel: data),
                const SizedBox(height: 24),

                // 4. Team Performance
                _buildSectionLabel(theme, Icons.people_alt_rounded, 'Team'),
                const SizedBox(height: 12),
                TeamPerformanceTable(performance: data.teamPerformance),
                const SizedBox(height: 24),

                // 5. Recent Tasks
                _buildTasksSection(
                  theme,
                  title: 'Recent Activities',
                  icon: Icons.history_rounded,
                  tasks: data.tasks,
                  isDark: isDark,
                ),
              ] else ...[
                // B. Member Layout

                // 1. Stats Grid
                _buildSectionLabel(theme, Icons.dashboard_rounded, 'Overview'),
                const SizedBox(height: 12),
                StatsGrid(stats: data.stats, isAdmin: false),
                const SizedBox(height: 24),

                // 2. Productivity Chart
                _buildSectionLabel(
                  theme,
                  Icons.show_chart_rounded,
                  'Analytics',
                ),
                const SizedBox(height: 12),
                ProductivityChart(weeklyProductivity: data.weeklyProductivity),
                const SizedBox(height: 16),
                TaskStatesDashboard(dashboardModel: data),
                const SizedBox(height: 24),

                // 3. Upcoming Tasks
                BlocBuilder<GetUserTaskCubit, GetUserTaskState>(
                  builder: (context, taskState) {
                    final List<DashboardTaskModel> displayTasks;
                    if (taskState is GetUserTaskSuccess &&
                        taskState.tasks.isNotEmpty) {
                      displayTasks = taskState.tasks
                          .map(
                            (e) => DashboardTaskModel(
                              id: e.id,
                              name: e.name,
                              status: e.status,
                              color: e.color,
                              projectName: e.projectName,
                              endDate:
                                  DateTime.tryParse(e.endDate) ??
                                  DateTime.now(),
                            ),
                          )
                          .toList();
                    } else {
                      displayTasks = data.tasks;
                    }

                    return _buildTasksSection(
                      theme,
                      title: 'Upcoming Tasks',
                      icon: Icons.upcoming_rounded,
                      tasks: displayTasks,
                      isDark: isDark,
                    );
                  },
                ),
              ],

              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeroHeader(ThemeData theme, bool isDark, DashboardModel data) {
    final greeting = _getGreeting();
    final emoji = _getGreetingEmoji();
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, MMM d').format(now);

    return FadeTransition(
      opacity: _headerFade,
      child: SlideTransition(
        position: _headerSlide,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [const Color(0xFF1E3A5F), const Color(0xFF0F172A)]
                  : [const Color(0xFF3B82F6), const Color(0xFF8B5CF6)],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentBlue.withValues(alpha: isDark ? 0.2 : 0.35),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background decorative circles
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              Positioned(
                right: 20,
                bottom: -30,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.04),
                  ),
                ),
              ),

              // Content
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting row
                  Row(
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text(
                        greeting,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Username
                  Text(
                    data.username,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Divider line
                  Container(
                    height: 1,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Bottom row: date + role badge
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 12,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        dateStr,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              widget.isAdmin
                                  ? Icons.admin_panel_settings_rounded
                                  : Icons.person_rounded,
                              size: 11,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.isAdmin ? 'Admin' : 'Member',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(ThemeData theme, IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.primary),
        const SizedBox(width: 6),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTasksSection(
    ThemeData theme, {
    required String title,
    required IconData icon,
    required List<DashboardTaskModel> tasks,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(theme, icon, title),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () => widget.onNavigate(2),
              icon: const Icon(Icons.arrow_forward_ios_rounded, size: 12),
              label: Text('View all'.tr()),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildRecentTasksList(theme, tasks, isDark),
      ],
    );
  }

  Widget _buildRecentTasksList(
    ThemeData theme,
    List<DashboardTaskModel> tasks,
    bool isDark,
  ) {
    if (tasks.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: EmptyStateWidget(
            icon: Icons.task_alt_rounded,
            title: 'No tasks listed'.tr(),
            subtitle: 'You have no active tasks currently.'.tr(),
          ),
        ),
      );
    }

    final displayTasks = tasks.length > 5 ? tasks.sublist(0, 5) : tasks;

    return Column(
      children: displayTasks.asMap().entries.map((entry) {
        final index = entry.key;
        final task = entry.value;
        final taskColor = getColor(task.color.toString());
        final statusColor = AppColors.statusColor(task.status);

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 400 + (index * 80)),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.06),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  splashColor: taskColor.withValues(alpha: 0.05),
                  onTap: () => widget.onNavigate(2),
                  child: Row(
                    children: [
                      // Left accent bar
                      Container(
                        width: 4,
                        height: 70,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [taskColor, taskColor.withValues(alpha: 0.4)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            bottomLeft: Radius.circular(16),
                          ),
                        ),
                      ),

                      // Content
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      task.name,
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 5),
                                    if (task.projectName != null &&
                                        task.projectName!.isNotEmpty) ...[
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.folder_rounded,
                                            size: 11,
                                            color: taskColor,
                                          ),
                                          const SizedBox(width: 4),
                                          Flexible(
                                            child: Text(
                                              task.projectName!,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: taskColor,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),

                              // Right column: date + status
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.calendar_month_rounded,
                                        size: 10,
                                        color: theme.hintColor,
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        _formatDateTime(task.endDate),
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: theme.hintColor,
                                              fontSize: 10,
                                            ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: statusColor.withValues(alpha: 0.25),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      task.status,
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: statusColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildShimmerLoading(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header shimmer
          _ShimmerBox(
            width: double.infinity,
            height: 120,
            radius: 24,
            isDark: isDark,
          ),
          const SizedBox(height: 24),

          // Stats grid shimmer
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemCount: 4,
            itemBuilder: (_, __) => _ShimmerBox(
              width: double.infinity,
              height: double.infinity,
              radius: 20,
              isDark: isDark,
            ),
          ),
          const SizedBox(height: 24),

          // Chart shimmer
          _ShimmerBox(
            width: double.infinity,
            height: 260,
            radius: 16,
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          _ShimmerBox(
            width: double.infinity,
            height: 280,
            radius: 16,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, String error) {
    return SizedBox(
      height: 400,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.errorColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cloud_off_rounded,
                  size: 40,
                  color: AppColors.errorColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load dashboard',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _refreshData,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text('Retry'.tr()),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accentBlue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

// ── Shimmer Loading Box ──────────────────────────────────────────────────────

class _ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double radius;
  final bool isDark;

  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.radius,
    required this.isDark,
  });

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _shimmer = Tween<double>(
      begin: -1.5,
      end: 1.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.black.withValues(alpha: 0.04);
    final shimmerColor = widget.isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.black.withValues(alpha: 0.08);

    return AnimatedBuilder(
      animation: _shimmer,
      builder: (context, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(_shimmer.value - 0.5, 0),
              end: Alignment(_shimmer.value + 0.5, 0),
              colors: [baseColor, shimmerColor, baseColor],
            ),
          ),
        );
      },
    );
  }
}
