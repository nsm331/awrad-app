import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:awrad_app/data/repositories/dhikr_repository_impl.dart';
import 'package:awrad_app/data/repositories/statistics_repository_impl.dart';
import 'package:awrad_app/main.dart';

void main() {
  testWidgets('Awrad app boots and renders main screen shell',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final dhikrRepo = DhikrRepositoryImpl();
    final statsRepo = StatisticsRepositoryImpl();

    await tester.pumpWidget(
      AwradApp(
        prefs: prefs,
        dhikrRepository: dhikrRepo,
        statisticsRepository: statsRepo,
      ),
    );

    expect(find.byType(AwradApp), findsOneWidget);
  });
}
