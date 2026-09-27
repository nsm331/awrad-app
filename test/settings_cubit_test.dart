import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awrad_app/core/constants/app_constants.dart';
import 'package:awrad_app/presentation/blocs/settings/settings_cubit.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  group('SettingsCubit Notification Tests', () {
    test('Initial state loads default values correctly', () {
      final cubit = SettingsCubit(prefs);

      expect(cubit.state.notificationsEnabled, true);
      expect(cubit.state.useDefaultSlots, true);
      expect(cubit.state.morningNotificationEnabled, true);
      expect(cubit.state.morningHour, 6);
      expect(cubit.state.morningMinute, 0);
      expect(cubit.state.eveningNotificationEnabled, true);
      expect(cubit.state.eveningHour, 16);
      expect(cubit.state.eveningMinute, 30);
    });

    test('Master notifications toggle updates state and persists', () async {
      final cubit = SettingsCubit(prefs);

      await cubit.setNotificationsEnabled(false);
      expect(cubit.state.notificationsEnabled, false);
      expect(prefs.getBool(PreferencesKeys.notificationsEnabled), false);

      await cubit.setNotificationsEnabled(true);
      expect(cubit.state.notificationsEnabled, true);
      expect(prefs.getBool(PreferencesKeys.notificationsEnabled), true);
    });

    test('Independent morning toggle updates state and persists', () async {
      final cubit = SettingsCubit(prefs);

      await cubit.setMorningEnabled(false);
      expect(cubit.state.morningNotificationEnabled, false);
      expect(cubit.state.eveningNotificationEnabled, true);
      expect(prefs.getBool(PreferencesKeys.morningNotificationEnabled), false);

      await cubit.setMorningEnabled(true);
      expect(cubit.state.morningNotificationEnabled, true);
      expect(prefs.getBool(PreferencesKeys.morningNotificationEnabled), true);
    });

    test('Independent evening toggle updates state and persists', () async {
      final cubit = SettingsCubit(prefs);

      await cubit.setEveningEnabled(false);
      expect(cubit.state.eveningNotificationEnabled, false);
      expect(cubit.state.morningNotificationEnabled, true);
      expect(prefs.getBool(PreferencesKeys.eveningNotificationEnabled), false);

      await cubit.setEveningEnabled(true);
      expect(cubit.state.eveningNotificationEnabled, true);
      expect(prefs.getBool(PreferencesKeys.eveningNotificationEnabled), true);
    });

    test('Custom morning time sets custom mode and persists', () async {
      final cubit = SettingsCubit(prefs);

      await cubit.setMorningTime(7, 15);
      expect(cubit.state.morningHour, 7);
      expect(cubit.state.morningMinute, 15);
      expect(cubit.state.useDefaultSlots, false);

      expect(prefs.getInt(PreferencesKeys.morningNotificationHour), 7);
      expect(prefs.getInt(PreferencesKeys.morningNotificationMinute), 15);
      expect(prefs.getBool(PreferencesKeys.useDefaultNotificationSlots), false);
    });

    test('Custom evening time sets custom mode and persists', () async {
      final cubit = SettingsCubit(prefs);

      await cubit.setEveningTime(17, 45);
      expect(cubit.state.eveningHour, 17);
      expect(cubit.state.eveningMinute, 45);
      expect(cubit.state.useDefaultSlots, false);

      expect(prefs.getInt(PreferencesKeys.eveningNotificationHour), 17);
      expect(prefs.getInt(PreferencesKeys.eveningNotificationMinute), 45);
      expect(prefs.getBool(PreferencesKeys.useDefaultNotificationSlots), false);
    });

    test('Switching back to default slots resets hours/minutes to defaults', () async {
      final cubit = SettingsCubit(prefs);

      await cubit.setMorningTime(8, 0);
      await cubit.setEveningTime(19, 0);
      expect(cubit.state.useDefaultSlots, false);

      await cubit.setUseDefaultSlots(true);
      expect(cubit.state.useDefaultSlots, true);
      expect(cubit.state.morningHour, DefaultValues.morningNotificationHour);
      expect(cubit.state.morningMinute, DefaultValues.morningNotificationMinute);
      expect(cubit.state.eveningHour, DefaultValues.eveningNotificationHour);
      expect(cubit.state.eveningMinute, DefaultValues.eveningNotificationMinute);
      expect(prefs.getBool(PreferencesKeys.useDefaultNotificationSlots), true);
    });
  });
}
