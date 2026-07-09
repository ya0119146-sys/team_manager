import 'package:flutter/material.dart';

class InputFormField extends StatelessWidget {
  final String hint;
  final bool obscure;
  final Icon? prifixicon;
  final Icon? suffixIcon;
  final TextEditingController controller;
  final int? maxLines;
  final void Function(String)? onChanged;
  final bool readOnly;
  const InputFormField({
    super.key,
    required this.hint,
    this.obscure = false,
    this.prifixicon,
    this.suffixIcon,
    this.maxLines,
    required this.controller,
    this.onChanged,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TextFormField(
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
      controller: controller,
      style: TextStyle(
        fontSize: 12,
        color: isDark ? Colors.white : Colors.black87,
      ),
      obscureText: suffixIcon != null ? obscure : false,
      maxLines: maxLines,
      readOnly: readOnly,
      decoration: InputDecoration(
        prefixIcon: prifixicon != null
            ? Icon(
                prifixicon!.icon,
                color: isDark ? Colors.white54 : Colors.black54,
              )
            : null,
        suffixIcon: suffixIcon != null
            ? Icon(
                suffixIcon!.icon,
                color: isDark ? Colors.white54 : Colors.black54,
              )
            : null,
        suffixIconConstraints: const BoxConstraints(
          maxHeight: 24,
          maxWidth: 24,
        ),
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 12,
          color: isDark ? Colors.white54 : Colors.black45,
        ),
        filled: true,
        fillColor: isDark
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
            : const Color(0xFFF1F3F6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
