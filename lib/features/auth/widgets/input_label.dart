import 'package:flutter/material.dart';

class InputLabel extends StatelessWidget {
  final String text;
  const InputLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text, 
        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500),
      ),
    );
  }
}
