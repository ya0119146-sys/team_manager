import 'package:flutter/material.dart';
import 'package:team_manager/core/widgets/glass_panel.dart';
import 'package:team_manager/features/home/models/dashboard_model.dart';

class TeamPerformanceTable extends StatelessWidget {
  final List<DashboardTeamMemberModel> performance;

  const TeamPerformanceTable({
    super.key,
    required this.performance,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassPanel(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF06B6D4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.people_alt_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Team Performance',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${performance.length} members',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          performance.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.group_off_rounded,
                          size: 44,
                          color: theme.hintColor.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'No team members with assigned tasks yet.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.hintColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: performance.asMap().entries.map((entry) {
                    final index = entry.key;
                    final member = entry.value;
                    return _MemberCard(
                      member: member,
                      index: index,
                      theme: theme,
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }
}

class _MemberCard extends StatefulWidget {
  final DashboardTeamMemberModel member;
  final int index;
  final ThemeData theme;

  const _MemberCard({
    required this.member,
    required this.index,
    required this.theme,
  });

  @override
  State<_MemberCard> createState() => _MemberCardState();
}

class _MemberCardState extends State<_MemberCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _progressAnim;

  static const List<List<Color>> _avatarGradients = [
    [Color(0xFF3B82F6), Color(0xFF06B6D4)],
    [Color(0xFF8B5CF6), Color(0xFFEC4899)],
    [Color(0xFF10B981), Color(0xFF34D399)],
    [Color(0xFFF59E0B), Color(0xFFEF4444)],
    [Color(0xFF14B8A6), Color(0xFF3B82F6)],
  ];

  Color get _completionColor {
    final rate = widget.member.completionRate;
    if (rate >= 70) return const Color(0xFF10B981);
    if (rate >= 40) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _progressAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
    );
    Future.delayed(Duration(milliseconds: widget.index * 60), () {
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
    final isDark = widget.theme.brightness == Brightness.dark;
    final gradientColors =
        _avatarGradients[widget.index % _avatarGradients.length];
    final initial = widget.member.memberUsername.isNotEmpty
        ? widget.member.memberUsername[0].toUpperCase()
        : '?';

    return FadeTransition(
      opacity: _fadeIn,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.03)
              : Colors.black.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.07)
                : Colors.black.withValues(alpha: 0.06),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {},
              splashColor: gradientColors.first.withValues(alpha: 0.05),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: Avatar + Name + Rank badge
                    Row(
                      children: [
                        // Avatar with gradient
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: gradientColors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: gradientColors.first.withValues(alpha: 0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              initial,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Name + username
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.member.memberUsername,
                                style:
                                    widget.theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              _RatingStars(rating: widget.member.rating),
                            ],
                          ),
                        ),

                        // Rank badge
                        if (widget.index < 3)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: gradientColors,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              widget.index == 0
                                  ? '🥇 Top'
                                  : widget.index == 1
                                      ? '🥈 2nd'
                                      : '🥉 3rd',
                              style: const TextStyle(
                                fontSize: 9,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Progress row
                    Row(
                      children: [
                        Text(
                          'Completion',
                          style: widget.theme.textTheme.bodySmall?.copyWith(
                            color: widget.theme.hintColor,
                            fontSize: 11,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${widget.member.completionRate.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _completionColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Animated progress bar
                    AnimatedBuilder(
                      animation: _progressAnim,
                      builder: (context, _) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: (widget.member.completionRate / 100)
                                .clamp(0.0, 1.0)
                                * _progressAnim.value,
                            minHeight: 8,
                            backgroundColor: _completionColor.withValues(alpha: 0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _completionColor,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    // Task chips row
                    Row(
                      children: [
                        _TaskChip(
                          label: 'Total',
                          count: widget.member.totalTasks,
                          color: widget.theme.hintColor.withValues(alpha: 0.6),
                          theme: widget.theme,
                        ),
                        const SizedBox(width: 6),
                        _TaskChip(
                          label: 'Done',
                          count: widget.member.completedTasks,
                          color: const Color(0xFF10B981),
                          theme: widget.theme,
                        ),
                        const SizedBox(width: 6),
                        _TaskChip(
                          label: 'Accepted',
                          count: widget.member.acceptedTasks,
                          color: const Color(0xFF14B8A6),
                          theme: widget.theme,
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
    );
  }
}

class _TaskChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final ThemeData theme;

  const _TaskChip({
    required this.label,
    required this.count,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingStars extends StatelessWidget {
  final double rating;

  const _RatingStars({required this.rating});

  @override
  Widget build(BuildContext context) {
    final int fullStars = rating.floor();
    final bool hasHalf = (rating - fullStars) >= 0.5;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (index) {
          if (index < fullStars) {
            return const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 13);
          } else if (index == fullStars && hasHalf) {
            return const Icon(Icons.star_half_rounded, color: Color(0xFFF59E0B), size: 13);
          } else {
            return Icon(
              Icons.star_outline_rounded,
              color: Theme.of(context).hintColor.withValues(alpha: 0.25),
              size: 13,
            );
          }
        }),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Color(0xFFF59E0B),
          ),
        ),
      ],
    );
  }
}
