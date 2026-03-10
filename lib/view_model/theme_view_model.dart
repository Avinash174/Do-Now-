import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _themeKey = 'theme_mode';

class ThemeModeNotifier extends AsyncNotifier<ThemeMode> {
  @override
  Future<ThemeMode> build() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_themeKey);
    switch (stored) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system; // Default: follow system
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    // Set loading state first
    state = const AsyncValue.loading();
    try {
      final prefs = await SharedPreferences.getInstance();
      switch (mode) {
        case ThemeMode.dark:
          await prefs.setString(_themeKey, 'dark');
          break;
        case ThemeMode.light:
          await prefs.setString(_themeKey, 'light');
          break;
        case ThemeMode.system:
          await prefs.remove(_themeKey);
          break;
      }
      // Update state with the new theme mode
      state = AsyncValue.data(mode);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> toggle() async {
    final current = state.value ?? ThemeMode.system;
    final next = current == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setMode(next);
  }
}

final themeModeProvider = AsyncNotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
