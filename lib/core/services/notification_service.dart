/// Offline local notifications and reminders engine for Awrad (أَوْرَاد).
///
/// Strictly offline; schedules daily repeating local alarms for morning (06:00 AM)
/// and evening (04:30 PM) Adhkar, or at user-customized times.
///
/// Deep-links into the reader for "أذكار الصباح" (ID 2) and "أذكار المساء" (ID 3).
library;

import 'dart:developer' as developer;

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Handler callback invoked when a notification is clicked by the user.
typedef NotificationTapCallback = void Function(String payload);

/// Service managing offline local notification scheduling and dispatch.
class NotificationService {
  NotificationService._internal();

  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Optional payload from a notification that launched the app from terminated state.
  String? _initialPayload;

  /// Callback registered to handle notification taps while app is running.
  NotificationTapCallback? _onNotificationTap;

  /// Notification IDs for distinct reminder slots
  static const int morningNotificationId = 1001;
  static const int eveningNotificationId = 1002;

  /// Channel ID and Name for Daily Awrad reminders (High Importance)
  static const String dailyChannelId = 'awrad_daily_reminders';
  static const String dailyChannelName = 'أذكار اليوم والليلة';
  static const String dailyChannelDescription =
      'تنبيهات يومية بمواعيد أذكار الصباح والمساء المباركة';

  /// Sub-category IDs corresponding to the separated morning & evening dataset
  static const String morningSubCategoryId = '2';
  static const String eveningSubCategoryId = '3';

  /// Default notification titles and bodies
  static const String morningTitle = 'أَوْرَاد - أذكار الصباح';
  static const String morningBody =
      'أصبحنا وأصبح الملك لله.. حان وقت ورد الصباح المبارك.';

  static const String eveningTitle = 'أَوْرَاد - أذكار المساء';
  static const String eveningBody =
      'أمسينا وأمسى الملك لله.. حان وقت ورد المساء المبارك.';

  /// Retrieves any initial payload that launched the app from terminated state,
  /// clearing it once consumed.
  String? consumeInitialPayload() {
    final payload = _initialPayload;
    _initialPayload = null;
    return payload;
  }

  /// Sets or updates the tap callback handler.
  void setOnNotificationTap(NotificationTapCallback callback) {
    _onNotificationTap = callback;
    // If there is an unprocessed initial payload, deliver it now.
    if (_initialPayload != null) {
      final p = _initialPayload!;
      _initialPayload = null;
      callback(p);
    }
  }

  /// Synchronizes local timezone offline from the device's current UTC offset.
  void _configureOfflineLocalTimezone() {
    tz.initializeTimeZones();
    final currentOffset = DateTime.now().timeZoneOffset;

    tz.Location? matchedLocation;
    for (final loc in tz.timeZoneDatabase.locations.values) {
      if (loc.currentTimeZone.offset == currentOffset.inMilliseconds) {
        matchedLocation = loc;
        break;
      }
    }

    if (matchedLocation != null) {
      tz.setLocalLocation(matchedLocation);
      developer.log(
        'Offline timezone matched: ${matchedLocation.name} (offset: ${currentOffset.inHours}h)',
        name: 'NotificationService',
      );
    } else {
      developer.log(
        'Could not match specific timezone by offset; utilizing default local timezone.',
        name: 'NotificationService',
      );
    }
  }

  /// Initializes the local notification plugin with Android and iOS settings,
  /// registers the high-importance notification channel, and inspects launch details.
  Future<void> initialize({NotificationTapCallback? onNotificationTap}) async {
    if (onNotificationTap != null) {
      _onNotificationTap = onNotificationTap;
    }

    if (_isInitialized) return;

    _configureOfflineLocalTimezone();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    try {
      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          final payload = response.payload;
          if (payload != null && payload.isNotEmpty) {
            developer.log(
              'Notification tapped with payload: $payload',
              name: 'NotificationService',
            );
            if (_onNotificationTap != null) {
              _onNotificationTap!(payload);
            } else {
              _initialPayload = payload;
            }
          }
        },
      );

      // Check if the app was launched by tapping a notification
      final launchDetails =
          await _notificationsPlugin.getNotificationAppLaunchDetails();
      if (launchDetails != null && launchDetails.didNotificationLaunchApp) {
        final payload = launchDetails.notificationResponse?.payload;
        if (payload != null && payload.isNotEmpty) {
          _initialPayload = payload;
          developer.log(
            'App launched from notification with payload: $payload',
            name: 'NotificationService',
          );
        }
      }

      // Configure Android High Importance Notification Channel
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        const channel = AndroidNotificationChannel(
          dailyChannelId,
          dailyChannelName,
          description: dailyChannelDescription,
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        );
        await androidPlugin.createNotificationChannel(channel);
      }

      _isInitialized = true;
      developer.log(
        'NotificationService initialized successfully with high-importance channel.',
        name: 'NotificationService',
      );
    } catch (e, st) {
      developer.log(
        'NotificationService initialization error: $e',
        name: 'NotificationService',
        error: e,
        stackTrace: st,
      );
    }
  }

  /// Requests notification and alarm permissions on Android 13+ and iOS.
  Future<bool> requestPermissions() async {
    try {
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final notifGranted =
            await androidPlugin.requestNotificationsPermission();
        try {
          await androidPlugin.requestExactAlarmsPermission();
        } catch (_) {
          // Gracefully continue if exact alarm permission dialog is not supported
        }
        return notifGranted ?? false;
      }

      final iosPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      if (iosPlugin != null) {
        final granted = await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    } catch (e, st) {
      developer.log(
        'requestPermissions error: $e',
        name: 'NotificationService',
        error: e,
        stackTrace: st,
      );
    }
    return false;
  }

  /// Computes the next occurrence of [hour]:[minute] in the local timezone.
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  /// Common NotificationDetails for daily reminders.
  NotificationDetails _buildNotificationDetails() {
    const androidDetails = AndroidNotificationDetails(
      dailyChannelId,
      dailyChannelName,
      channelDescription: dailyChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    return const NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
  }

  /// Schedules or cancels the distinct Morning Dhikr reminder.
  ///
  /// Default time: 06:00 AM.
  /// Payload: Sub-category ID for "أذكار الصباح" (ID 2).
  Future<void> scheduleMorningReminder({
    required bool enabled,
    int hour = 6,
    int minute = 0,
    String payload = morningSubCategoryId,
  }) async {
    if (!_isInitialized) await initialize();

    await cancelReminder(morningNotificationId);

    if (!enabled) {
      developer.log('Morning reminder cancelled.', name: 'NotificationService');
      return;
    }

    final scheduledDate = _nextInstanceOfTime(hour, minute);
    final details = _buildNotificationDetails();

    try {
      await _notificationsPlugin.zonedSchedule(
        morningNotificationId,
        morningTitle,
        morningBody,
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
      );
      developer.log(
        'Morning reminder scheduled for $hour:${minute.toString().padLeft(2, '0')} (exact alarm). Next: $scheduledDate',
        name: 'NotificationService',
      );
    } on PlatformException catch (e) {
      developer.log(
        'Exact alarm unavailable, falling back to inexact for morning reminder: $e',
        name: 'NotificationService',
      );
      await _notificationsPlugin.zonedSchedule(
        morningNotificationId,
        morningTitle,
        morningBody,
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
      );
    } catch (e, st) {
      developer.log(
        'Error scheduling morning reminder: $e',
        name: 'NotificationService',
        error: e,
        stackTrace: st,
      );
    }
  }

  /// Schedules or cancels the distinct Evening Dhikr reminder.
  ///
  /// Default time: 04:30 PM (16:30).
  /// Payload: Sub-category ID for "أذكار المساء" (ID 3).
  Future<void> scheduleEveningReminder({
    required bool enabled,
    int hour = 16,
    int minute = 30,
    String payload = eveningSubCategoryId,
  }) async {
    if (!_isInitialized) await initialize();

    await cancelReminder(eveningNotificationId);

    if (!enabled) {
      developer.log('Evening reminder cancelled.', name: 'NotificationService');
      return;
    }

    final scheduledDate = _nextInstanceOfTime(hour, minute);
    final details = _buildNotificationDetails();

    try {
      await _notificationsPlugin.zonedSchedule(
        eveningNotificationId,
        eveningTitle,
        eveningBody,
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
      );
      developer.log(
        'Evening reminder scheduled for $hour:${minute.toString().padLeft(2, '0')} (exact alarm). Next: $scheduledDate',
        name: 'NotificationService',
      );
    } on PlatformException catch (e) {
      developer.log(
        'Exact alarm unavailable, falling back to inexact for evening reminder: $e',
        name: 'NotificationService',
      );
      await _notificationsPlugin.zonedSchedule(
        eveningNotificationId,
        eveningTitle,
        eveningBody,
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
      );
    } catch (e, st) {
      developer.log(
        'Error scheduling evening reminder: $e',
        name: 'NotificationService',
        error: e,
        stackTrace: st,
      );
    }
  }

  /// Synchronizes both morning and evening reminders according to configuration.
  Future<void> syncDailyReminders({
    required bool masterEnabled,
    required bool morningEnabled,
    required int morningHour,
    required int morningMinute,
    required bool eveningEnabled,
    required int eveningHour,
    required int eveningMinute,
  }) async {
    if (!masterEnabled) {
      await cancelAll();
      developer.log(
        'All daily reminders cancelled (master toggle off).',
        name: 'NotificationService',
      );
      return;
    }

    await scheduleMorningReminder(
      enabled: morningEnabled,
      hour: morningHour,
      minute: morningMinute,
    );

    await scheduleEveningReminder(
      enabled: eveningEnabled,
      hour: eveningHour,
      minute: eveningMinute,
    );
  }

  /// Legacy helper for backwards compatibility.
  Future<void> scheduleDailyReminders({
    required bool enabled,
    int morningHour = 6,
    int morningMinute = 0,
    int eveningHour = 16,
    int eveningMinute = 30,
  }) async {
    await syncDailyReminders(
      masterEnabled: enabled,
      morningEnabled: enabled,
      morningHour: morningHour,
      morningMinute: morningMinute,
      eveningEnabled: enabled,
      eveningHour: eveningHour,
      eveningMinute: eveningMinute,
    );
  }

  /// Cancels a specific reminder by [notificationId].
  Future<void> cancelReminder(int notificationId) async {
    try {
      await _notificationsPlugin.cancel(notificationId);
    } catch (e) {
      developer.log('cancelReminder($notificationId) error: $e',
          name: 'NotificationService');
    }
  }

  /// Cancels all scheduled local reminders.
  Future<void> cancelAll() async {
    try {
      await _notificationsPlugin.cancelAll();
    } catch (e) {
      developer.log('cancelAll error: $e', name: 'NotificationService');
    }
  }
}
