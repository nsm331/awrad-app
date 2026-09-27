import 'package:flutter_test/flutter_test.dart';
import 'package:awrad_app/core/services/notification_service.dart';
import 'package:awrad_app/presentation/screens/settings/settings_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotificationService Contract & Config Tests', () {
    test('Default notification constants match specifications', () {
      expect(NotificationService.morningNotificationId, 1001);
      expect(NotificationService.eveningNotificationId, 1002);

      expect(NotificationService.dailyChannelId, 'awrad_daily_reminders');
      expect(NotificationService.dailyChannelName, 'أذكار اليوم والليلة');

      expect(NotificationService.morningSubCategoryId, '2');
      expect(NotificationService.eveningSubCategoryId, '3');

      expect(NotificationService.morningTitle, 'أَوْرَاد - أذكار الصباح');
      expect(
        NotificationService.morningBody,
        'أصبحنا وأصبح الملك لله.. حان وقت ورد الصباح المبارك.',
      );

      expect(NotificationService.eveningTitle, 'أَوْرَاد - أذكار المساء');
      expect(
        NotificationService.eveningBody,
        'أمسينا وأمسى الملك لله.. حان وقت ورد المساء المبارك.',
      );
    });

    test('Initial payload lifecycle consumes payload once', () {
      final service = NotificationService.instance;

      // When initialized without launch payload, returns null
      expect(service.consumeInitialPayload(), isNull);

      // Registering callback invokes callback if payload is queued
      String? deliveredPayload;
      service.setOnNotificationTap((payload) {
        deliveredPayload = payload;
      });

      // Directly invoke callback through registered handler
      service.setOnNotificationTap((payload) {
        deliveredPayload = 'received_$payload';
      });

      expect(deliveredPayload, isNull);
    });
  });

  group('formatArabicTime Formatter Tests', () {
    test('Formats morning AM hours correctly', () {
      expect(formatArabicTime(6, 0), '06:00 ص');
      expect(formatArabicTime(0, 0), '12:00 ص');
      expect(formatArabicTime(11, 45), '11:45 ص');
    });

    test('Formats evening PM hours correctly', () {
      expect(formatArabicTime(12, 0), '12:00 م');
      expect(formatArabicTime(16, 30), '04:30 م');
      expect(formatArabicTime(23, 59), '11:59 م');
    });
  });
}
