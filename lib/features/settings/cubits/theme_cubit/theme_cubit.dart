import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:team_manager/core/helpers/cache_helper.dart';
import 'package:team_manager/features/settings/cubits/theme_cubit/theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeInitial(_getSavedTheme()));

  static ThemeMode _getSavedTheme() {
    bool isDark = CacheHelper.getBool(key: 'isDark') ?? false;
    return isDark ? ThemeMode.dark : ThemeMode.light;
  }

  void toggleTheme() {
    if (state.themeMode == ThemeMode.light) {
      _emitNewTheme(ThemeMode.dark, true);
    } else {
      _emitNewTheme(ThemeMode.light, false);
    }
  }

  void _emitNewTheme(ThemeMode mode, bool isDark) {
    CacheHelper.setBool(key: 'isDark', value: isDark).then((_) {
      emit(ThemeChanged(mode));
    });
  }
}
