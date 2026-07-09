// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:team_manager/core/widgets/glass_panel.dart';
// import 'package:team_manager/features/home/models/admin_projects_dashboard.dart';

// class TasksByProjectChart extends StatelessWidget {
//   const TasksByProjectChart({
//     super.key,
//     required this.adminProjectsDashboardModel,
//   });
//   final List<AdminProjectsDashboardModel> adminProjectsDashboardModel;
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return GlassPanel(
//       padding: const EdgeInsets.all(12),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Tasks by Project',
//             style: theme.textTheme.titleMedium?.copyWith(
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 24),

//           SizedBox(
//             height: 200,
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: SizedBox(
//                 width: 300,
//                 child: BarChart(
//                   BarChartData(
//                     alignment: BarChartAlignment.spaceAround,

//                     barTouchData: BarTouchData(),
//                     barGroups: _barGroups(),
//                     titlesData: _titlesData(theme),
//                     gridData: FlGridData(show: false),
//                     borderData: FlBorderData(
//                       show: true,
//                       border: Border(
//                         bottom: BorderSide(color: theme.dividerColor),
//                         left: BorderSide(color: theme.dividerColor),
//                       ),
//                     ),
//                     // backgroundColor: Colors.transparent,
//                     minY: 0,
//                     //maxY: 3.5,
//                     groupsSpace: 20,
//                   ),
//                 ),
//               ),
//             ),
//           ),

//           const SizedBox(height: 16),
//           _legend(),
//         ],
//       ),
//     );
//   }

//   List<BarChartGroupData> _barGroups() {
//     return [
//       for (int i = 0; i < adminProjectsDashboardModel.length; i++)
//         _group(
//           i,
//           total: adminProjectsDashboardModel[i].taskCount,
//           completed: adminProjectsDashboardModel[i].completedTaskCount,
//         ),
//     ];
//   }

//   BarChartGroupData _group(
//     int x, {
//     required int total,
//     required int completed,
//   }) {
//     return BarChartGroupData(
//       x: x,
//       barRods: [
//         BarChartRodData(
//           toY: total.toDouble(),
//           width: 32,
//           color: Colors.blue,
//           borderRadius: BorderRadius.circular(0),
//         ),
//         BarChartRodData(
//           toY: completed.toDouble(),
//           width: 32,
//           color: Colors.green,
//           borderRadius: BorderRadius.circular(0),
//         ),
//       ],
//       barsSpace: 4,
//     );
//   }

//   FlTitlesData _titlesData(ThemeData theme) {
//     return FlTitlesData(
//       topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//       rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//       leftTitles: AxisTitles(
//         sideTitles: SideTitles(showTitles: true, reservedSize: 64, interval: 1),
//       ),
//       bottomTitles: AxisTitles(
//         sideTitles: SideTitles(
//           showTitles: true,
//           getTitlesWidget: (value, meta) {
//             final titles = [
//               for (int i = 0; i < adminProjectsDashboardModel.length; i++)
//                 adminProjectsDashboardModel[i].name,
//             ];
//             return Padding(
//               padding: const EdgeInsets.only(top: 2),
//               child: Text(
//                 titles[value.toInt()],
//                 style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
//                 overflow: TextOverflow.ellipsis,
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _legend() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: const [
//         _LegendItem(color: Colors.blue, text: 'Total Tasks'),
//         SizedBox(width: 16),
//         _LegendItem(color: Colors.green, text: 'Completed'),
//       ],
//     );
//   }
// }

// class _LegendItem extends StatelessWidget {
//   final Color color;
//   final String text;

//   const _LegendItem({required this.color, required this.text});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Container(width: 16, height: 16, color: color),
//         const SizedBox(width: 6),
//         Text(text, style: Theme.of(context).textTheme.bodySmall),
//       ],
//     );
//   }
// }
