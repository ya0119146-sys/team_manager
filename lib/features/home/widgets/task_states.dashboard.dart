import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:team_manager/core/widgets/glass_panel.dart';
import 'package:team_manager/core/widgets/custom_dropdown.dart';
import 'package:team_manager/features/home/models/dashboard_model.dart';

class TaskStatesDashboard extends StatefulWidget {
  final DashboardModel dashboardModel;

  const TaskStatesDashboard({
    super.key,
    required this.dashboardModel,
  });

  @override
  State<TaskStatesDashboard> createState() => _TaskStatesDashboardState();
}

class _TaskStatesDashboardState extends State<TaskStatesDashboard>
    with SingleTickerProviderStateMixin {
  String _selectedFilter = 'all';
  int? _touchedGroupIndex;
  late AnimationController _animController;
  late Animation<double> _animation;

  static const _statusColors = [
    Color(0xFFF59E0B), // Pending - amber
    Color(0xFF3B82F6), // In Progress - blue
    Color(0xFF8B5CF6), // Reviewing - purple
    Color(0xFF10B981), // Done - emerald
    Color(0xFF14B8A6), // Accepted - teal
  ];

  static const _statusLabels = [
    'Pending',
    'In Progress',
    'Review',
    'Done',
    'Accepted',
  ];



  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _animation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  int _getValue(Map<String, int> map, List<String> possibleKeys) {
    for (final key in possibleKeys) {
      if (map.containsKey(key)) return map[key]!;
      final lKey = key.toLowerCase();
      if (map.containsKey(lKey)) return map[lKey]!;
      final cleanKey = lKey.replaceAll('-', '').replaceAll(' ', '');
      for (final mk in map.keys) {
        if (mk.toLowerCase().replaceAll('-', '').replaceAll(' ', '') ==
            cleanKey) {
          return map[mk]!;
        }
      }
    }
    return 0;
  }

  void _setFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      _touchedGroupIndex = null;
    });
    _animController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final stats = widget.dashboardModel.stats;
    final projects = widget.dashboardModel.projects;

    int pending, inProgress, reviewing, done, accepted;

    if (_selectedFilter == 'all') {
      pending = stats.pendingTasks;
      inProgress = stats.inProgressTasks;
      reviewing = stats.reviewingTasks;
      done = stats.doneTasks;
      accepted = stats.acceptedTasks;
    } else {
      try {
        final proj = projects.firstWhere((e) => e.id == _selectedFilter);
        final b = proj.statusBreakdown;
        pending = _getValue(b, ['pending']);
        inProgress = _getValue(b, ['in-progress', 'inprogress', 'in progress']);
        reviewing = _getValue(b, ['reviewing', 'review']);
        done = _getValue(b, ['done', 'completed']);
        accepted = _getValue(b, ['accepted']);
      } catch (_) {
        pending = inProgress = reviewing = done = accepted = 0;
      }
    }

    final values = [pending, inProgress, reviewing, done, accepted];
    final int maxVal = values.fold(5, (prev, e) => e > prev ? e : prev);
    final double maxY = (maxVal + 2).roundToDouble();
    final int total = values.fold(0, (a, b) => a + b);

    return GlassPanel(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Task Distribution',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    total > 0 ? '$total total tasks' : 'No tasks yet',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              _buildDropdown(theme, isDark, projects),
            ],
          ),
          const SizedBox(height: 20),

          // Bar Chart
          SizedBox(
            height: 200,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, _) {
                return BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxY,
                    barTouchData: BarTouchData(
                      touchCallback: (event, response) {
                        setState(() {
                          if (response?.spot != null) {
                            _touchedGroupIndex =
                                response!.spot!.touchedBarGroupIndex;
                          } else {
                            _touchedGroupIndex = null;
                          }
                        });
                      },
                      touchTooltipData: BarTouchTooltipData(
                        tooltipBgColor: isDark
                            ? const Color(0xFF1E293B)
                            : Colors.white,
                        tooltipRoundedRadius: 10,
                        tooltipBorder: BorderSide(
                          color: theme.dividerColor.withValues(alpha: 0.3),
                          width: 1,
                        ),
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            '${rod.toY.toInt()} tasks\n',
                            TextStyle(
                              color: _statusColors[groupIndex],
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            children: [
                              TextSpan(
                                text: _statusLabels[groupIndex],
                                style: TextStyle(
                                  color: theme.hintColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 24,
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt();
                            if (idx < 0 || idx >= values.length) {
                              return const SizedBox();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                values[idx].toString(),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: _statusColors[idx],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          interval: (maxY / 4)
                              .clamp(1, double.infinity)
                              .roundToDouble(),
                          getTitlesWidget: (value, meta) {
                            if (value == 0) return const SizedBox();
                            return Text(
                              value.toInt().toString(),
                              style: TextStyle(
                                color: theme.hintColor.withValues(alpha: 0.6),
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.right,
                            );
                          },
                        ),
                      ),
                      bottomTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: theme.dividerColor.withValues(alpha: 0.12),
                        strokeWidth: 1,
                        dashArray: [4, 6],
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(5, (i) {
                      return _buildGroup(i, values[i].toDouble(), maxY);
                    }),
                  ),

                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Legend
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: List.generate(5, (i) {
              final isSelected = _touchedGroupIndex == i;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isSelected
                      ? _statusColors[i].withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? _statusColors[i].withValues(alpha: 0.4)
                        : Colors.transparent,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _statusColors[i],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _statusLabels[i],
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: isSelected
                            ? _statusColors[i]
                            : theme.hintColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${values[i]})',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: _statusColors[i].withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _buildGroup(int x, double y, double maxY) {
    final color = _statusColors[x];
    final isTouched = _touchedGroupIndex == x;

    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          width: isTouched ? 24 : 20,
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.5),
              color,
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: maxY,
            color: color.withValues(alpha: 0.04),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(
      ThemeData theme, bool isDark, List<DashboardProjectModel> projects) {
    return SizedBox(
      width: 140,
      child: CustomDropdown<String>(
        initialValue: _selectedFilter,
        items: [
          DropdownItem<String>(value: 'all', label: 'All Projects'),
          ...projects.map((proj) => DropdownItem<String>(
                value: proj.id,
                label: proj.name,
              )),
        ],
        onChanged: (String newValue) {
          _setFilter(newValue);
        },
        fontSize: 11,
        prefixIcon: Icons.filter_alt_outlined,
      ),
    );
  }
}
