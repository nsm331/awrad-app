import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awrad_app/core/services/notification_service.dart';
import 'package:awrad_app/data/repositories/dhikr_repository_impl.dart';
import 'package:awrad_app/data/repositories/statistics_repository_impl.dart';
import 'package:awrad_app/main.dart';
import 'package:awrad_app/presentation/screens/dhikr/dhikr_reading_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;
  late DhikrRepositoryImpl dhikrRepo;
  late StatisticsRepositoryImpl statsRepo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    dhikrRepo = DhikrRepositoryImpl();
    statsRepo = StatisticsRepositoryImpl();
  });

  Widget buildApp() {
    return AwradApp(
      prefs: prefs,
      dhikrRepository: dhikrRepo,
      statisticsRepository: statsRepo,
    );
  }

  testWidgets('handleNotificationPayload pushes DhikrReadingScreen for morning payload', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Trigger morning notification deep link
    handleNotificationPayload(NotificationService.morningSubCategoryId);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify DhikrReadingScreen was pushed with subCategoryId == 2
    final screenFinder = find.byType(DhikrReadingScreen);
    expect(screenFinder, findsOneWidget);

    final screenWidget = tester.widget<DhikrReadingScreen>(screenFinder);
    expect(screenWidget.subCategoryId, 2);

    // Pop back to home
    appNavigatorKey.currentState?.pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  });

  testWidgets('handleNotificationPayload pushes DhikrReadingScreen for evening payload', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Trigger evening notification deep link
    handleNotificationPayload(NotificationService.eveningSubCategoryId);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify DhikrReadingScreen was pushed with subCategoryId == 3
    final screenFinder = find.byType(DhikrReadingScreen);
    expect(screenFinder, findsOneWidget);

    final screenWidget = tester.widget<DhikrReadingScreen>(screenFinder);
    expect(screenWidget.subCategoryId, 3);

    // Pop back to home
    appNavigatorKey.currentState?.pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  });

  testWidgets('handleNotificationPayload supports textual aliases morning and evening', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    handleNotificationPayload('morning');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    var screenFinder = find.byType(DhikrReadingScreen);
    expect(screenFinder, findsOneWidget);
    var screenWidget = tester.widget<DhikrReadingScreen>(screenFinder);
    expect(screenWidget.subCategoryId, 2);

    appNavigatorKey.currentState?.pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    handleNotificationPayload('evening');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    screenFinder = find.byType(DhikrReadingScreen);
    expect(screenFinder, findsOneWidget);
    screenWidget = tester.widget<DhikrReadingScreen>(screenFinder);
    expect(screenWidget.subCategoryId, 3);

    appNavigatorKey.currentState?.pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  });
}
