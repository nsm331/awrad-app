/// App-wide constants used across the core, data, and domain layers.
library;

/// Database configuration constants.
abstract final class DatabaseConstants {
  /// The SQLite database file name on disk.
  static const String databaseName = 'awrad.db';

  /// Current schema version (Version 4: separated morning/evening dataset and unified card layout).
  static const int databaseVersion = 4;

  // ── Table names ────────────────────────────────────────────────────────────

  static const String parentCategoriesTable = 'parent_categories';
  static const String subCategoriesTable = 'sub_categories';
  static const String dhikrItemsTable = 'dhikr_items';
  static const String completionLogsTable = 'completion_logs';

  /// Legacy alias for [parentCategoriesTable].
  static const String categoriesTable = 'parent_categories';
}

/// SharedPreferences keys used across the app.
abstract final class PreferencesKeys {
  /// Boolean flag set to `true` after the first-launch database seed completes.
  static const String isDbSeeded = 'awrad_is_db_seeded';

  /// User-selected font family string (matches one of the declared font families
  /// in pubspec.yaml: "Amiri", "ScheherazadeNew", "Lateef").
  static const String selectedFontFamily = 'awrad_selected_font_family';

  /// User-selected text scale factor (double stored as string).
  static const String textScaleFactor = 'awrad_text_scale_factor';

  /// Whether the user has enabled Dhikr completion notifications.
  static const String notificationsEnabled = 'awrad_notifications_enabled';

  /// Whether morning Adhkar reminder is enabled.
  static const String morningNotificationEnabled = 'awrad_morning_notification_enabled';

  /// Morning reminder hour (0–23) in local time (default 6).
  static const String morningNotificationHour = 'awrad_morning_notification_hour';

  /// Morning reminder minute (0–59) in local time (default 0).
  static const String morningNotificationMinute = 'awrad_morning_notification_minute';

  /// Whether evening Adhkar reminder is enabled.
  static const String eveningNotificationEnabled = 'awrad_evening_notification_enabled';

  /// Evening reminder hour (0–23) in local time (default 16 / 4 PM).
  static const String eveningNotificationHour = 'awrad_evening_notification_hour';

  /// Evening reminder minute (0–59) in local time (default 30).
  static const String eveningNotificationMinute = 'awrad_evening_notification_minute';

  /// Whether default fixed slots (06:00 AM & 04:30 PM) are used vs custom time picker.
  static const String useDefaultNotificationSlots = 'awrad_use_default_notification_slots';

  /// Notification hour (0–23) in local time for legacy single reminder.
  static const String notificationHour = 'awrad_notification_hour';

  /// Selected theme mode string: "system", "light", or "dark".
  static const String themeMode = 'awrad_theme_mode';

  /// Whether sound effects (e.g. click on Tasbeeh) are enabled.
  static const String soundEnabled = 'awrad_sound_enabled';

  /// Whether haptic feedback (vibrations) is enabled.
  static const String hapticEnabled = 'awrad_haptic_enabled';
}

/// Asset path constants.
abstract final class AssetPaths {
  /// Path to the bundled Hisn al-Muslim JSON seed data.
  static const String hisnMuslimJson = 'assets/data/hisn_muslim.json';

  /// Path to the newly formatted Hisn al-Muslim JSON seed data.
  static const String hisnAlmuslimJson = 'assets/data/hisn_almuslim.json';

  /// Directory containing optional Dhikr audio files.
  static const String audioDirectory = 'assets/audio/';
}

/// Default user-preference values.
abstract final class DefaultValues {
  /// Default Arabic font family used for Dhikr text rendering.
  static const String fontFamily = 'Amiri';

  /// Default text scale factor for Dhikr content (1.0 = 100%).
  static const double textScaleFactor = 1.0;

  /// Default daily reminder time — 6:00 AM local time.
  static const int notificationHour = 6;
  static const int notificationMinute = 0;

  /// Default morning reminder time — 06:00 AM local time.
  static const bool morningNotificationEnabled = true;
  static const int morningNotificationHour = 6;
  static const int morningNotificationMinute = 0;

  /// Default evening reminder time — 04:30 PM (16:30) local time.
  static const bool eveningNotificationEnabled = true;
  static const int eveningNotificationHour = 16;
  static const int eveningNotificationMinute = 30;

  /// Default scheduling mode: true = fixed default slots, false = custom time picker.
  static const bool useDefaultNotificationSlots = true;

  /// Default sound effects state.
  static const bool soundEnabled = true;

  /// Default haptic feedback state.
  static const bool hapticEnabled = true;

  /// Default theme mode.
  static const String themeMode = 'system';
}
