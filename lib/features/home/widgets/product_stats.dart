import 'package:flutter/material.dart';
import 'package:team_manager/core/widgets/glass_panel.dart';

class ProductStats extends StatelessWidget {
  const ProductStats({
    super.key,
    required this.icon,
    required this.title,
    required this.data,
    required this.color,
  });
  final IconData icon;
  final String title;
  final String data;
  final Color color;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GlassPanel(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, style: theme.textTheme.bodyMedium), 
              Text(
                data, 
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
              ),
            ],
          ),
        ],
      ),
    );
  }
}
