import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/notification_service.dart';
import 'settings_state.dart';

/// Cubit managing sound effects, haptic feedback, and offline notification user preferences.
class SettingsCubit extends Cubit<SettingsState> {
  final SharedPreferences _prefs;

  SettingsCubit(this._prefs) : super(_loadInitialState(_prefs));

  static SettingsState _loadInitialState(SharedPreferences prefs) {
    final sound = prefs.getBool(PreferencesKeys.soundEnabled) ??
        DefaultValues.soundEnabled;
    final haptic = prefs.getBool(PreferencesKeys.hapticEnabled) ??
        DefaultValues.hapticEnabled;
    final notifications = prefs.getBool(PreferencesKeys.notificationsEnabled) ??
        true;
    final defaultSlots =
        prefs.getBool(PreferencesKeys.useDefaultNotificationSlots) ??
            prefs.getBool('awrad_use_default_notification_slots') ??
            DefaultValues.useDefaultNotificationSlots;

    final morningEnabled =
        prefs.getBool(PreferencesKeys.morningNotificationEnabled) ??
            DefaultValues.morningNotificationEnabled;
    final morningHour =
        prefs.getInt(PreferencesKeys.morningNotificationHour) ??
            prefs.getInt(PreferencesKeys.notificationHour) ??
            DefaultValues.morningNotificationHour;
    final morningMinute =
        prefs.getInt(PreferencesKeys.morningNotificationMinute) ??
            prefs.getInt('awrad_notification_minute') ??
            DefaultValues.morningNotificationMinute;

    final eveningEnabled =
        prefs.getBool(PreferencesKeys.eveningNotificationEnabled) ??
            DefaultValues.eveningNotificationEnabled;
    final eveningHour =
        prefs.getInt(PreferencesKeys.eveningNotificationHour) ??
            DefaultValues.eveningNotificationHour;
    final eveningMinute =
        prefs.getInt(PreferencesKeys.eveningNotificationMinute) ??
            DefaultValues.eveningNotificationMinute;

    return SettingsState(
      soundEnabled: sound,
      hapticEnabled: haptic,
      notificationsEnabled: notifications,
      useDefaultSlots: defaultSlots,
      morningNotificationEnabled: morningEnabled,
      morningHour: morningHour,
      morningMinute: morningMinute,
      eveningNotificationEnabled: eveningEnabled,
      eveningHour: eveningHour,
      eveningMinute: eveningMinute,
    );
  }

  /// Sets sound effects state and persists it.
  Future<void> setSoundEnabled(bool enabled) async {
    await _prefs.setBool(PreferencesKeys.soundEnabled, enabled);
    emit(state.copyWith(soundEnabled: enabled));
  }

  /// Toggles sound effects state and persists it.
  Future<void> toggleSound() async {
    await setSoundEnabled(!state.soundEnabled);
  }

  /// Sets haptic feedback state and persists it.
  Future<void> setHapticEnabled(bool enabled) async {
    await _prefs.setBool(PreferencesKeys.hapticEnabled, enabled);
    emit(state.copyWith(hapticEnabled: enabled));
  }

  /// Toggles haptic feedback state and persists it.
  Future<void> toggleHaptic() async {
    await setHapticEnabled(!state.hapticEnabled);
  }

  /// Toggles the master daily offline notifications switch.
  Future<void> setNotificationsEnabled(bool enabled) async {
    if (enabled) {
      await NotificationService.instance.requestPermissions();
    }
    await _prefs.setBool(PreferencesKeys.notificationsEnabled, enabled);
    final newState = state.copyWith(notificationsEnabled: enabled);
    emit(newState);
    _syncNotifications(newState);
  }

  /// Chooses between Mode A (standard fixed slots: 06:00 AM & 04:30 PM)
  /// and Mode B (custom time picker).
  Future<void> setUseDefaultSlots(bool useDefault) async {
    await _prefs.setBool(
        PreferencesKeys.useDefaultNotificationSlots, useDefault);
    await _prefs.setBool('awrad_use_default_notification_slots', useDefault);

    SettingsState newState;
    if (useDefault) {
      // Revert times to standard recommended slots
      newState = state.copyWith(
        useDefaultSlots: true,
        morningHour: DefaultValues.morningNotificationHour,
        morningMinute: DefaultValues.morningNotificationMinute,
        eveningHour: DefaultValues.eveningNotificationHour,
        eveningMinute: DefaultValues.eveningNotificationMinute,
      );
    } else {
      newState = state.copyWith(useDefaultSlots: false);
    }

    emit(newState);
    _syncNotifications(newState);
  }

  /// Toggles the Morning Dhikr reminder individually.
  Future<void> setMorningEnabled(bool enabled) async {
    if (enabled && !state.notificationsEnabled) {
      await setNotificationsEnabled(true);
    } else if (enabled) {
      await NotificationService.instance.requestPermissions();
    }
    await _prefs.setBool(
        PreferencesKeys.morningNotificationEnabled, enabled);
    final newState = state.copyWith(morningNotificationEnabled: enabled);
    emit(newState);
    _syncNotifications(newState);
  }

  /// Sets custom Morning Dhikr reminder time (Mode B).
  Future<void> setMorningTime(int hour, int minute) async {
    await _prefs.setInt(PreferencesKeys.morningNotificationHour, hour);
    await _prefs.setInt(PreferencesKeys.morningNotificationMinute, minute);
    await _prefs.setBool(
        PreferencesKeys.useDefaultNotificationSlots, false);
    await _prefs.setBool('awrad_use_default_notification_slots', false);

    final newState = state.copyWith(
      morningHour: hour,
      morningMinute: minute,
      useDefaultSlots: false,
    );
    emit(newState);
    _syncNotifications(newState);
  }

  /// Toggles the Evening Dhikr reminder individually.
  Future<void> setEveningEnabled(bool enabled) async {
    if (enabled && !state.notificationsEnabled) {
      await setNotificationsEnabled(true);
    } else if (enabled) {
      await NotificationService.instance.requestPermissions();
    }
    await _prefs.setBool(
        PreferencesKeys.eveningNotificationEnabled, enabled);
    final newState = state.copyWith(eveningNotificationEnabled: enabled);
    emit(newState);
    _syncNotifications(newState);
  }

  /// Sets custom Evening Dhikr reminder time (Mode B).
  Future<void> setEveningTime(int hour, int minute) async {
    await _prefs.setInt(PreferencesKeys.eveningNotificationHour, hour);
    await _prefs.setInt(PreferencesKeys.eveningNotificationMinute, minute);
    await _prefs.setBool(
        PreferencesKeys.useDefaultNotificationSlots, false);
    await _prefs.setBool('awrad_use_default_notification_slots', false);

    final newState = state.copyWith(
      eveningHour: hour,
      eveningMinute: minute,
      useDefaultSlots: false,
    );
    emit(newState);
    _syncNotifications(newState);
  }

  /// Backwards compatibility for single custom time setter.
  Future<void> setCustomNotificationTime(int hour, int minute) async {
    await setMorningTime(hour, minute);
  }

  void _syncNotifications(SettingsState s) {
    final morningHour =
        s.useDefaultSlots ? DefaultValues.morningNotificationHour : s.morningHour;
    final morningMinute = s.useDefaultSlots
        ? DefaultValues.morningNotificationMinute
        : s.morningMinute;

    final eveningHour =
        s.useDefaultSlots ? DefaultValues.eveningNotificationHour : s.eveningHour;
    final eveningMinute = s.useDefaultSlots
        ? DefaultValues.eveningNotificationMinute
        : s.eveningMinute;

    NotificationService.instance.syncDailyReminders(
      masterEnabled: s.notificationsEnabled,
      morningEnabled: s.morningNotificationEnabled,
      morningHour: morningHour,
      morningMinute: morningMinute,
      eveningEnabled: s.eveningNotificationEnabled,
      eveningHour: eveningHour,
      eveningMinute: eveningMinute,
    );
  }
}
