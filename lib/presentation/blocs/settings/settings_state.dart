import 'package:equatable/equatable.dart';

import '../../../core/constants/app_constants.dart';

/// State representing user's sound, haptics, and offline notification preferences.
class SettingsState extends Equatable {
  /// Whether sound effects (e.g. click sounds during Tasbeeh and reading) are enabled.
  final bool soundEnabled;

  /// Whether tactile vibration feedback is enabled.
  final bool hapticEnabled;

  /// Master switch: Whether daily offline reminders are enabled.
  final bool notificationsEnabled;

  /// Mode A (true): Fixed recommended slots (06:00 AM & 04:30 PM).
  /// Mode B (false): Custom time picker allows independent time adjustments.
  final bool useDefaultSlots;

  /// Whether the morning Adhkar reminder is enabled.
  final bool morningNotificationEnabled;

  /// Morning reminder hour (0–23) in local time.
  final int morningHour;

  /// Morning reminder minute (0–59) in local time.
  final int morningMinute;

  /// Whether the evening Adhkar reminder is enabled.
  final bool eveningNotificationEnabled;

  /// Evening reminder hour (0–23) in local time.
  final int eveningHour;

  /// Evening reminder minute (0–59) in local time.
  final int eveningMinute;

  const SettingsState({
    this.soundEnabled = DefaultValues.soundEnabled,
    this.hapticEnabled = DefaultValues.hapticEnabled,
    this.notificationsEnabled = true,
    this.useDefaultSlots = DefaultValues.useDefaultNotificationSlots,
    this.morningNotificationEnabled = DefaultValues.morningNotificationEnabled,
    this.morningHour = DefaultValues.morningNotificationHour,
    this.morningMinute = DefaultValues.morningNotificationMinute,
    this.eveningNotificationEnabled = DefaultValues.eveningNotificationEnabled,
    this.eveningHour = DefaultValues.eveningNotificationHour,
    this.eveningMinute = DefaultValues.eveningNotificationMinute,
  });

  /// Backwards compatibility accessors
  int get customHour => morningHour;
  int get customMinute => morningMinute;

  SettingsState copyWith({
    bool? soundEnabled,
    bool? hapticEnabled,
    bool? notificationsEnabled,
    bool? useDefaultSlots,
    bool? morningNotificationEnabled,
    int? morningHour,
    int? morningMinute,
    bool? eveningNotificationEnabled,
    int? eveningHour,
    int? eveningMinute,
    int? customHour,
    int? customMinute,
  }) {
    return SettingsState(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
      notificationsEnabled:
          notificationsEnabled ?? this.notificationsEnabled,
      useDefaultSlots: useDefaultSlots ?? this.useDefaultSlots,
      morningNotificationEnabled:
          morningNotificationEnabled ?? this.morningNotificationEnabled,
      morningHour: customHour ?? morningHour ?? this.morningHour,
      morningMinute: customMinute ?? morningMinute ?? this.morningMinute,
      eveningNotificationEnabled:
          eveningNotificationEnabled ?? this.eveningNotificationEnabled,
      eveningHour: eveningHour ?? this.eveningHour,
      eveningMinute: eveningMinute ?? this.eveningMinute,
    );
  }

  @override
  List<Object?> get props => [
        soundEnabled,
        hapticEnabled,
        notificationsEnabled,
        useDefaultSlots,
        morningNotificationEnabled,
        morningHour,
        morningMinute,
        eveningNotificationEnabled,
        eveningHour,
        eveningMinute,
      ];
}
