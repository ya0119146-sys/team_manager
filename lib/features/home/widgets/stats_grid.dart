import 'package:flutter/material.dart';
import 'package:team_manager/features/home/models/dashboard_model.dart';

class StatsGrid extends StatelessWidget {
  final DashboardStats stats;
  final bool isAdmin;

  const StatsGrid({
    super.key,
    required this.stats,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    final List<_StatCardData> cardData = isAdmin
        ? [
            _StatCardData(
              title: 'Managed Projects',
              value: stats.totalManagedProjects ?? 0,
              suffix: '',
              icon: Icons.folder_copy_rounded,
              gradientColors: [const Color(0xFF3B82F6), const Color(0xFF06B6D4)],
              glowColor: const Color(0xFF3B82F6),
              trend: '+2 this month',
              trendUp: true,
            ),
            _StatCardData(
              title: 'Team Members',
              value: stats.totalTeamMembers ?? 0,
              suffix: '',
              icon: Icons.people_alt_rounded,
              gradientColors: [const Color(0xFF8B5CF6), const Color(0xFFEC4899)],
              glowColor: const Color(0xFF8B5CF6),
              trend: 'Active team',
              trendUp: true,
            ),
            _StatCardData(
              title: 'Assigned Tasks',
              value: stats.totalAssignedTasks ?? 0,
              suffix: '',
              icon: Icons.task_alt_rounded,
              gradientColors: [const Color(0xFFF59E0B), const Color(0xFFEF4444)],
              glowColor: const Color(0xFFF59E0B),
              trend: 'Total assigned',
              trendUp: true,
            ),
            _StatCardData(
              title: 'Team Efficiency',
              value: (stats.teamCompletionRate ?? 0.0).round(),
              suffix: '%',
              icon: Icons.trending_up_rounded,
              gradientColors: [const Color(0xFF10B981), const Color(0xFF06B6D4)],
              glowColor: const Color(0xFF10B981),
              trend: 'Completion rate',
              trendUp: (stats.teamCompletionRate ?? 0) > 50,
            ),
          ]
        : [
            _StatCardData(
              title: 'Pending Tasks',
              value: stats.pendingTasks,
              suffix: '',
              icon: Icons.hourglass_empty_rounded,
              gradientColors: [const Color(0xFFF59E0B), const Color(0xFFEF4444)],
              glowColor: const Color(0xFFF59E0B),
              trend: 'Needs attention',
              trendUp: false,
            ),
            _StatCardData(
              title: 'In Progress',
              value: stats.inProgressTasks,
              suffix: '',
              icon: Icons.pending_actions_rounded,
              gradientColors: [const Color(0xFF3B82F6), const Color(0xFF06B6D4)],
              glowColor: const Color(0xFF3B82F6),
              trend: 'Currently active',
              trendUp: true,
            ),
            _StatCardData(
              title: 'Completed',
              value: stats.completedTasks,
              suffix: '',
              icon: Icons.check_circle_rounded,
              gradientColors: [const Color(0xFF10B981), const Color(0xFF34D399)],
              glowColor: const Color(0xFF10B981),
              trend: 'Great progress!',
              trendUp: true,
            ),
            _StatCardData(
              title: 'Personal Rate',
              value: stats.personalCompletionRate.round(),
              suffix: '%',
              icon: Icons.emoji_events_rounded,
              gradientColors: [const Color(0xFF8B5CF6), const Color(0xFFEC4899)],
              glowColor: const Color(0xFF8B5CF6),
              trend: 'Your efficiency',
              trendUp: stats.personalCompletionRate > 50,
            ),
          ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: cardData.length,
      itemBuilder: (context, index) {
        return _AnimatedStatCard(data: cardData[index], delay: index * 80);
      },
    );
  }
}

class _StatCardData {
  final String title;
  final int value;
  final String suffix;
  final IconData icon;
  final List<Color> gradientColors;
  final Color glowColor;
  final String trend;
  final bool trendUp;

  const _StatCardData({
    required this.title,
    required this.value,
    required this.suffix,
    required this.icon,
    required this.gradientColors,
    required this.glowColor,
    required this.trend,
    required this.trendUp,
  });
}

class _AnimatedStatCard extends StatefulWidget {
  final _StatCardData data;
  final int delay;

  const _AnimatedStatCard({required this.data, required this.delay});

  @override
  State<_AnimatedStatCard> createState() => _AnimatedStatCardState();
}

class _AnimatedStatCardState extends State<_AnimatedStatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideIn = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return FadeTransition(
      opacity: _fadeIn,
      child: SlideTransition(
        position: _slideIn,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      widget.data.glowColor.withValues(alpha: 0.12),
                      theme.colorScheme.surface.withValues(alpha: 0.8),
                    ]
                  : [
                      Colors.white,
                      widget.data.glowColor.withValues(alpha: 0.04),
                    ],
            ),
            border: Border.all(
              color: widget.data.glowColor.withValues(alpha: isDark ? 0.25 : 0.15),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.data.glowColor.withValues(alpha: isDark ? 0.2 : 0.1),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                splashColor: widget.data.glowColor.withValues(alpha: 0.08),
                highlightColor: widget.data.glowColor.withValues(alpha: 0.04),
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Icon + Title Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: widget.data.gradientColors,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.data.gradientColors.first
                                      .withValues(alpha: 0.4),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              widget.data.icon,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                      // Value + Label
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Animated count-up
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: widget.data.value.toDouble()),
                            duration: const Duration(milliseconds: 900),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, _) {
                              return Text(
                                '${value.toInt()}${widget.data.suffix}',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -1,
                                  foreground: Paint()
                                    ..shader = LinearGradient(
                                      colors: widget.data.gradientColors,
                                    ).createShader(
                                      const Rect.fromLTWH(0, 0, 80, 40),
                                    ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.data.title,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.hintColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          // Trend indicator
                          Row(
                            children: [
                              Icon(
                                widget.data.trendUp
                                    ? Icons.arrow_upward_rounded
                                    : Icons.arrow_downward_rounded,
                                size: 10,
                                color: widget.data.trendUp
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFEF4444),
                              ),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  widget.data.trend,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: widget.data.trendUp
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFFEF4444),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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
            ),
          ),
        ),
      ),
    );
  }
}
