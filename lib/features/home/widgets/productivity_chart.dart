import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_manager/core/widgets/glass_panel.dart';
import 'package:team_manager/features/home/cubit/get_admin_dashboard_cubit/get_admin_dashboard_cubit.dart';
import 'package:team_manager/features/home/cubit/get_admin_dashboard_cubit/get_admin_dashboard_state.dart';
import 'package:team_manager/features/home/models/dashboard_model.dart';

class ProductivityChart extends StatefulWidget {
  final Map<String, List<DashboardTaskModel>> weeklyProductivity;

  const ProductivityChart({super.key, required this.weeklyProductivity});

  @override
  State<ProductivityChart> createState() => _ProductivityChartState();
}

class _ProductivityChartState extends State<ProductivityChart>
    with SingleTickerProviderStateMixin {
  String _activeTab = 'weekly';
  int? _touchedIndex;
  late AnimationController _animController;
  late Animation<double> _chartAnimation;

  static const List<String> _daysOrder = [
    'Saturday',
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
  ];

  static const List<String> _daysAbbr = [
    'Sat',
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _chartAnimation = CurvedAnimation(
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

  void _switchTab(String tab) {
    if (_activeTab == tab) return;
    setState(() {
      _activeTab = tab;
      _touchedIndex = null;
    });
    _animController.forward(from: 0);
    if (tab == 'trend') {
      context.read<GetAdminDashboardCubit>().getTrendHistory();
    }
  }

  int _getTaskCountForDay(String dayName) {
    final lowerDay = dayName.toLowerCase().trim();
    for (final entry in widget.weeklyProductivity.entries) {
      final key = entry.key.toLowerCase().trim();
      if (key == lowerDay ||
          key.startsWith(lowerDay.substring(0, 3)) ||
          lowerDay.startsWith(key)) {
        return entry.value.length;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    return BlocBuilder<GetAdminDashboardCubit, GetAdminDashboardState>(
      builder: (context, state) {
        List<TrendDataModel> trendData = [];
        bool isLoadingHistory = false;

        if (state is GetAdminDashboardSuccess) {
          trendData = state.trendHistory;
          isLoadingHistory = state.isHistoryLoading;
        }

        final List<FlSpot> spots = [];
        double maxX = 6;
        double maxY = 5;

        if (_activeTab == 'weekly') {
          for (int i = 0; i < _daysOrder.length; i++) {
            final taskCount = _getTaskCountForDay(_daysOrder[i]);
            spots.add(FlSpot(i.toDouble(), taskCount.toDouble()));
            if (taskCount > maxY) maxY = taskCount.toDouble();
          }
        } else {
          maxX = (trendData.length - 1).toDouble().clamp(0, double.infinity);
          for (int i = 0; i < trendData.length; i++) {
            final taskCount = trendData[i].tasks;
            spots.add(FlSpot(i.toDouble(), taskCount.toDouble()));
            if (taskCount > maxY) maxY = taskCount.toDouble();
          }
        }

        maxY = (maxY + 2).roundToDouble();

        // Find peak
        int peakIndex = 0;
        double peakValue = 0;
        for (int i = 0; i < spots.length; i++) {
          if (spots[i].y > peakValue) {
            peakValue = spots[i].y;
            peakIndex = i;
          }
        }

        return GlassPanel(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Productivity Trend',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _activeTab == 'weekly'
                              ? 'Tasks completed per day'
                              : 'Historical performance',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.hintColor,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildPillToggle(theme, isDark),
                ],
              ),
              const SizedBox(height: 8),

              // Peak badge
              if (spots.isNotEmpty && peakValue > 0)
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: primary.withValues(alpha: 0.25),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.trending_up_rounded,
                          size: 12,
                          color: primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Peak: ${peakValue.toInt()} tasks',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // Chart
              SizedBox(
                height: 210,
                child: _activeTab == 'trend' && isLoadingHistory
                    ? Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: primary,
                        ),
                      )
                    : spots.length < 2
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.bar_chart_rounded,
                              size: 40,
                              color: theme.hintColor.withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _activeTab == 'weekly'
                                  ? 'No weekly data yet'
                                  : 'No history available',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.hintColor,
                              ),
                            ),
                          ],
                        ),
                      )
                    : AnimatedBuilder(
                        animation: _chartAnimation,
                        builder: (context, _) {
                          return LineChart(
                            _getChartData(
                              theme,
                              spots,
                              maxX,
                              maxY,
                              trendData,
                              primary,
                              isDark,
                              peakIndex,
                            ),
                            duration: const Duration(milliseconds: 400),
                          );
                        },
                      ),
              ),

              // X-axis legend for weekly
              if (_activeTab == 'weekly' && spots.length >= 2) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(_daysAbbr.length, (i) {
                    final count = spots[i].y.toInt();
                    return _DayColumn(
                      day: _daysAbbr[i],
                      count: count,
                      isActive: count > 0,
                      isPeak: i == peakIndex && peakValue > 0,
                      color: primary,
                      theme: theme,
                    );
                  }),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildPillToggle(ThemeData theme, bool isDark) {
    return Container(
      height: 38,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.07)
            : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.07),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPillButton('Weekly', 'weekly', theme),
          _buildPillButton('Trend', 'trend', theme),
        ],
      ),
    );
  }

  Widget _buildPillButton(String label, String tab, ThemeData theme) {
    final isActive = _activeTab == tab;
    return GestureDetector(
      onTap: () => _switchTab(tab),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: isActive
              ? LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            fontSize: 12,
            color: isActive ? Colors.white : theme.hintColor,
          ),
        ),
      ),
    );
  }

  LineChartData _getChartData(
    ThemeData theme,
    List<FlSpot> spots,
    double maxX,
    double maxY,
    List<TrendDataModel> trendData,
    Color primary,
    bool isDark,
    int peakIndex,
  ) {
    return LineChartData(
      lineTouchData: LineTouchData(
        touchCallback: (event, response) {
          if (response?.lineBarSpots != null) {
            setState(() {
              _touchedIndex = response!.lineBarSpots!.first.spotIndex;
            });
          } else {
            setState(() => _touchedIndex = null);
          }
        },
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          tooltipRoundedRadius: 10,
          tooltipBorder: BorderSide(color: primary.withValues(alpha: 0.3), width: 1),
          getTooltipItems: (spots) {
            return spots.map((spot) {
              final label = _activeTab == 'weekly'
                  ? _daysOrder[spot.x.toInt()]
                  : (spot.x.toInt() < trendData.length
                        ? trendData[spot.x.toInt()].name
                        : '');
              return LineTooltipItem(
                '${spot.y.toInt()} tasks\n',
                TextStyle(
                  color: primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                children: [
                  TextSpan(
                    text: label,
                    style: TextStyle(
                      color: theme.hintColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                    ),
                  ),
                ],
              );
            }).toList();
          },
        ),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: (maxY / 4).clamp(1, double.infinity),
        getDrawingHorizontalLine: (value) => FlLine(
          color: theme.dividerColor.withValues(alpha: isDark ? 0.15 : 0.25),
          strokeWidth: 1,
          dashArray: [4, 6],
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 34,
            interval: (maxY / 4).clamp(1, double.infinity).roundToDouble(),
            getTitlesWidget: (value, meta) {
              if (value == 0) return const SizedBox();
              return Text(
                value.toInt().toString(),
                style: TextStyle(
                  color: theme.hintColor.withValues(alpha: 0.7),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.right,
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false, reservedSize: 0),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: maxX,
      minY: 0,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.35,
          color: primary,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              final isPeak = index == peakIndex;
              final isTouched = index == _touchedIndex;
              return FlDotCirclePainter(
                radius: isTouched ? 6 : (isPeak ? 5 : 3.5),
                color: isTouched || isPeak ? primary : Colors.transparent,
                strokeWidth: isTouched || isPeak ? 0 : 2,
                strokeColor: primary,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                primary.withValues(alpha: 0.3),
                primary.withValues(alpha: 0.08),
                primary.withValues(alpha: 0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          shadow: Shadow(color: primary.withValues(alpha: 0.25), blurRadius: 8),
        ),
      ],
    );
  }
}

class _DayColumn extends StatelessWidget {
  final String day;
  final int count;
  final bool isActive;
  final bool isPeak;
  final Color color;
  final ThemeData theme;

  const _DayColumn({
    required this.day,
    required this.count,
    required this.isActive,
    required this.isPeak,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isPeak)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text('🔥', style: const TextStyle(fontSize: 10)),
          )
        else
          const SizedBox(height: 16),
        Text(
          day,
          style: TextStyle(
            fontSize: 9,
            fontWeight: isPeak ? FontWeight.bold : FontWeight.w500,
            color: isPeak ? color : theme.hintColor.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
