import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';
import '../constants/db_constants.dart';
import 'database_provider.dart';

/// Notifier that reads/writes theme mode from the [Settings] table.
class ThemeModeNotifier extends AsyncNotifier<ThemeMode> {
  @override
  Future<ThemeMode> build() async {
    return ThemeMode.light;
  }

  Future<void> setThemeMode(ThemeMode mode) async {}

  void toggleTheme() {}
}

final themeModeProvider =
    AsyncNotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
