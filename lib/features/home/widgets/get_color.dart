import 'package:flutter/material.dart';

Color getColor(String color) {
  switch (color) {
    case 'blue':
      return Colors.blue;
    case 'purple':
      return Colors.purple;
    case 'green':
      return Colors.green;
    case 'orange':
      return Colors.orange;
    case 'red':
      return Colors.red;
    case 'cyan':
      return Colors.cyan;
    default:
      return Colors.blue;
  }
}
