import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awrad_app/presentation/blocs/settings/settings_cubit.dart';
import 'package:awrad_app/presentation/blocs/theme/theme_cubit.dart';
import 'package:awrad_app/presentation/screens/settings/settings_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'awrad_selected_font_family': 'Amiri',
      'awrad_text_scale_factor': '1.4',
      'awrad_notifications_enabled': true,
      'awrad_use_default_notification_slots': true,
      'awrad_morning_notification_enabled': true,
      'awrad_evening_notification_enabled': true,
    });
  });

  testWidgets('SettingsScreen renders at 140% font scale without overflow', (tester) async {
    final prefs = await SharedPreferences.getInstance();

    // Set compact phone viewport (360 x 800 dp)
    tester.view.physicalSize = const Size(360 * 2, 800 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<ThemeCubit>(create: (_) => ThemeCubit(prefs)),
          BlocProvider<SettingsCubit>(create: (_) => SettingsCubit(prefs)),
        ],
        child: const MaterialApp(
          home: SettingsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify live preview card header
    expect(find.text('معاينة الخط الحيّة'), findsOneWidget);

    // Scroll to find the font scaling slider section
    final fontScaleSectionFinder = find.text('حجم الخط والتكبير');
    await tester.scrollUntilVisible(
      fontScaleSectionFinder,
      100,
      scrollable: find.byType(Scrollable).first,
    );
    expect(fontScaleSectionFinder, findsOneWidget);

    // Verify slider boundary labels
    expect(find.text('صغير (80%)'), findsOneWidget);
    expect(find.text('كبير (140%)'), findsOneWidget);
    expect(find.text('إعادة الضبط إلى 100%'), findsOneWidget);

    // Scroll to find the offline guarantee banner
    final offlineBannerFinder = find.text('تطبيق أَوْرَاد (Awrad) — يعمل 100% دون إنترنت');
    await tester.scrollUntilVisible(
      offlineBannerFinder,
      100,
      scrollable: find.byType(Scrollable).first,
    );
    expect(offlineBannerFinder, findsOneWidget);

    // Verify zero overflow exceptions were logged
    expect(tester.takeException(), isNull);
  });

  testWidgets('SettingsScreen renders Daily Reminders section with Morning and Evening controls', (tester) async {
    final prefs = await SharedPreferences.getInstance();

    tester.view.physicalSize = const Size(360 * 2, 800 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final settingsCubit = SettingsCubit(prefs);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<ThemeCubit>(create: (_) => ThemeCubit(prefs)),
          BlocProvider<SettingsCubit>.value(value: settingsCubit),
        ],
        child: const MaterialApp(
          home: SettingsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Scroll to the Daily Notifications master toggle
    final masterToggleFinder = find.text('تفعيل تنبيهات الأذكار');
    await tester.scrollUntilVisible(
      masterToggleFinder,
      100,
      scrollable: find.byType(Scrollable).first,
    );
    expect(masterToggleFinder, findsOneWidget);

    // Verify Mode A (Recommended slots) is visible
    expect(find.text('المواعيد الموصى بها (افتراضي)'), findsOneWidget);
    expect(find.text('الصباح (06:00 ص) • المساء (04:30 م)'), findsOneWidget);

    // Scroll to the Custom Radio option
    final customRadioFinder = find.text('تحديد أوقات مخصصة');
    await tester.scrollUntilVisible(
      customRadioFinder,
      100,
      scrollable: find.byType(Scrollable).first,
    );
    expect(customRadioFinder, findsOneWidget);

    // Scroll to Morning and Evening reminders
    final morningFinder = find.text('أذكار الصباح');
    await tester.scrollUntilVisible(
      morningFinder,
      100,
      scrollable: find.byType(Scrollable).first,
    );
    expect(morningFinder, findsOneWidget);
    expect(find.text('06:00 ص'), findsOneWidget);

    final eveningFinder = find.text('أذكار المساء');
    await tester.scrollUntilVisible(
      eveningFinder,
      100,
      scrollable: find.byType(Scrollable).first,
    );
    expect(eveningFinder, findsOneWidget);
    expect(find.text('04:30 م'), findsOneWidget);

    // Switch to custom mode via cubit and settle
    await settingsCubit.setUseDefaultSlots(false);
    await tester.pumpAndSettle();

    // In custom mode, time change triggers appear
    expect(find.text('تغيير الوقت'), findsWidgets);

    expect(tester.takeException(), isNull);
  });
}
