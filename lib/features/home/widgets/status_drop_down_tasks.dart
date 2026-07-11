import 'package:flutter/material.dart';
import 'package:team_manager/core/widgets/custom_dropdown.dart';

class StatusDropdownTasks extends StatelessWidget {
  final List<String> items;
  final String? value;
  final String hint;
  final bool enabled;
  final ValueChanged<String?> onChanged;
  final double fontSize;

  const StatusDropdownTasks({
    super.key,
    required this.items,
    required this.onChanged,
    this.value,
    this.hint = 'Select',
    this.enabled = true,
    this.fontSize = 13,
  });

  @override
  Widget build(BuildContext context) {
    return CustomDropdown<String>(
      initialValue: value,
      hint: hint,
      enabled: enabled,
      fontSize: fontSize,
      items: items.map((e) => DropdownItem(value: e, label: e)).toList(),
      onChanged: (v) {
        if (enabled) onChanged(v);
      },
      prefixIcon: Icons.arrow_drop_down_circle_outlined,
    );
  }
}
