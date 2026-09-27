import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:awrad_app/presentation/blocs/settings/settings_cubit.dart';
import 'package:awrad_app/presentation/blocs/tasbeeh/tasbeeh_cubit.dart';
import 'package:awrad_app/presentation/blocs/theme/theme_cubit.dart';
import 'package:awrad_app/presentation/screens/tasbeeh/tasbeeh_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'awrad_tasbeeh_total_count': 0,
      'awrad_tasbeeh_target': 33,
      'awrad_tasbeeh_selected_index': 0,
    });
    prefs = await SharedPreferences.getInstance();
  });

  Widget buildTestWidget() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SettingsCubit>(create: (_) => SettingsCubit(prefs)),
        BlocProvider<ThemeCubit>(create: (_) => ThemeCubit(prefs)),
        BlocProvider<TasbeehCubit>(create: (_) => TasbeehCubit(prefs)),
      ],
      child: const MaterialApp(
        home: TasbeehScreen(),
      ),
    );
  }

  group('TasbeehScreen Widget Tests', () {
    testWidgets('renders all core UI elements and initial counter', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('سُبْحَانَ اللَّهِ'), findsAtLeastNWidgets(1));
      expect(find.text('٠').evaluate().isNotEmpty || find.text('0').evaluate().isNotEmpty, true);
      expect(find.text('المس للعد'), findsOneWidget);
      expect(find.text('مجموع التسبيحات المباركة:'), findsOneWidget);
    });

    testWidgets('tapping counter button increments counter display', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Tap the counter button
      await tester.tap(find.text('المس للعد'));
      await tester.pumpAndSettle();

      expect(find.text('١').evaluate().isNotEmpty || find.text('1').evaluate().isNotEmpty, true);
    });

    testWidgets('reset button opens confirmation dialog and confirms reset', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Tap twice
      await tester.tap(find.text('المس للعد'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('المس للعد'));
      await tester.pumpAndSettle();

      // Tap reset icon button
      final resetBtn = find.byTooltip('تصفير العداد');
      expect(resetBtn, findsOneWidget);
      await tester.tap(resetBtn);
      await tester.pumpAndSettle();

      // Verify dialog opened
      expect(find.text('إعادة ضبط العداد'), findsOneWidget);
      expect(find.text('تصفير العداد'), findsAtLeastNWidgets(1));

      // Tap confirm reset
      await tester.tap(find.text('تصفير العداد').last);
      await tester.pumpAndSettle();

      // Counter should now be 0
      expect(find.text('٠').evaluate().isNotEmpty || find.text('0').evaluate().isNotEmpty, true);
    });

    testWidgets('switching Dhikr chip updates active Dhikr phrase', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Tap on second chip 'الْحَمْدُ لِلَّهِ'
      final alhamdulillahChip = find.text('الْحَمْدُ لِلَّهِ');
      expect(alhamdulillahChip, findsOneWidget);
      await tester.tap(alhamdulillahChip);
      await tester.pumpAndSettle();

      // Both chip and active phrase card will have it
      expect(find.text('الْحَمْدُ لِلَّهِ'), findsAtLeastNWidgets(2));
    });
  });
}
