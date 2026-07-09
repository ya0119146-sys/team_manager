import 'package:flutter/material.dart';

String sendColor(Color color) {
  switch (color) {
    case Colors.blue:
      return 'blue';
    case Colors.purple:
      return 'purple';
    case Colors.green:
      return 'green';
    case Colors.orange:
      return 'orange';
    case Colors.red:
      return 'red';
    case Colors.cyan:
      return 'cyan';
    default:
      return 'blue';
  }
}
