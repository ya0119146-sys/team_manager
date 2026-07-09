import 'package:flutter/material.dart';

abstract class ThemeState {
  final ThemeMode themeMode;
  const ThemeState(this.themeMode);
}

// الحالة الابتدائية عند فتح التطبيق
class ThemeInitial extends ThemeState {
  const ThemeInitial(super.themeMode);
}

// الحالة عند تغيير الثيم
class ThemeChanged extends ThemeState {
  const ThemeChanged(super.themeMode);
}
