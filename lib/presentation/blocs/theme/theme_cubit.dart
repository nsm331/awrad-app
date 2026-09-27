import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import 'theme_state.dart';

/// Cubit managing dynamic theme mode, Arabic typography family, and font-size scaling.
class ThemeCubit extends Cubit<ThemeState> {
  final SharedPreferences _prefs;

  ThemeCubit(this._prefs) : super(_loadInitialState(_prefs));

  static ThemeState _loadInitialState(SharedPreferences prefs) {
    // 1. ThemeMode
    final modeStr = prefs.getString(PreferencesKeys.themeMode) ?? DefaultValues.themeMode;
    final themeMode = switch (modeStr) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    // 2. FontFamily
    final fontFamily = prefs.getString(PreferencesKeys.selectedFontFamily) ?? DefaultValues.fontFamily;

    // 3. FontScale
    final scaleStr = prefs.getString(PreferencesKeys.textScaleFactor);
    final fontScale = scaleStr != null
        ? (double.tryParse(scaleStr) ?? DefaultValues.textScaleFactor)
        : (prefs.getDouble(PreferencesKeys.textScaleFactor) ?? DefaultValues.textScaleFactor);

    final clampedScale = fontScale.clamp(0.8, 1.4);

    return ThemeState(
      themeMode: themeMode,
      fontFamily: fontFamily,
      fontScale: clampedScale,
    );
  }

  /// Sets the active [ThemeMode] and persists it to [SharedPreferences].
  Future<void> setThemeMode(ThemeMode mode) async {
    final modeStr = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await _prefs.setString(PreferencesKeys.themeMode, modeStr);
    emit(state.copyWith(themeMode: mode));
  }

  /// Sets the font family for Arabic text and persists it.
  Future<void> setFontFamily(String family) async {
    await _prefs.setString(PreferencesKeys.selectedFontFamily, family);
    emit(state.copyWith(fontFamily: family));
  }

  /// Sets the text scaling factor (clamped between 0.8 and 1.4) and persists it.
  Future<void> setFontScale(double scale) async {
    final clamped = scale.clamp(0.8, 1.4);
    await _prefs.setString(PreferencesKeys.textScaleFactor, clamped.toStringAsFixed(2));
    emit(state.copyWith(fontScale: clamped));
  }
}
