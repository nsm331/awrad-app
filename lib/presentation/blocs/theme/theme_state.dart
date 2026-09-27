import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';

/// State representing user's appearance preferences.
class ThemeState extends Equatable {
  /// The active [ThemeMode]: system, light, or dark.
  final ThemeMode themeMode;

  /// Font family used for Arabic Dhikr and UI (e.g. 'Amiri', 'ScheherazadeNew', 'Lateef', 'System').
  final String fontFamily;

  /// Dynamic font-size scaling factor (between 0.8x and 1.4x).
  final double fontScale;

  const ThemeState({
    this.themeMode = ThemeMode.system,
    this.fontFamily = DefaultValues.fontFamily,
    this.fontScale = DefaultValues.textScaleFactor,
  });

  /// Alias for fontScale for backward compatibility.
  double get textScaleFactor => fontScale;

  /// Light [ThemeData] generated with current font and scale settings.
  ThemeData get lightTheme => AppTheme.light(
        fontFamily: fontFamily,
        fontScale: fontScale,
      );

  /// Dark [ThemeData] generated with current font and scale settings.
  ThemeData get darkTheme => AppTheme.dark(
        fontFamily: fontFamily,
        fontScale: fontScale,
      );

  ThemeState copyWith({
    ThemeMode? themeMode,
    String? fontFamily,
    double? fontScale,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      fontFamily: fontFamily ?? this.fontFamily,
      fontScale: fontScale ?? this.fontScale,
    );
  }

  @override
  List<Object?> get props => [themeMode, fontFamily, fontScale];
}
