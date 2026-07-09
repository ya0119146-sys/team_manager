import 'package:flutter/material.dart';

class MembersSelector extends StatelessWidget {
  final List<String> members;
  final List<String> selectedMembers;
  final ValueChanged<String> onTap;

  const MembersSelector({
    super.key,
    required this.members,
    required this.selectedMembers,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (members.isEmpty) {
      return Text(
        'Select project first',
        style: TextStyle(color: theme.hintColor),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: members.map((member) {
        final isSelected = selectedMembers.contains(member);
        return GestureDetector(
          onTap: () => onTap(member),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected 
                  ? theme.colorScheme.primary 
                  : (isDark ? theme.colorScheme.surfaceContainerHigh : Colors.grey.shade200),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 10,
                  backgroundColor: theme.colorScheme.surface,
                  child: Text(
                    member[0].toUpperCase(),
                    style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  member,
                  style: TextStyle(
                    color: isSelected 
                        ? theme.colorScheme.onPrimary 
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
