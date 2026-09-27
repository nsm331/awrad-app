import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:awrad_app/domain/entities/dhikr_item.dart';
import 'package:awrad_app/presentation/widgets/dhikr/dhikr_card.dart';

void main() {
  group('DhikrCard Unified Single-Card Layout Tests', () {
    testWidgets('Renders Dhikr body, chapter badge, and header', (tester) async {
      const item = DhikrItem(
        id: 5,
        subCategoryId: 2,
        content: 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ وَالْحَمْدُ لِلَّهِ',
        repeatCount: 1,
        orderIndex: 1,
        subCategoryTitle: 'أذكار الصباح',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DhikrCard(
              item: item,
              chapterTitle: 'أذكار الصباح',
              currentIndex: 0,
              totalItems: 24,
            ),
          ),
        ),
      );

      // Verify header and badge
      expect(find.text('أَوْرَاد — حِصْنُ الْمُسْلِمِ'), findsOneWidget);
      expect(find.text('1 / 24'), findsOneWidget);
      expect(find.text('أذكار الصباح'), findsOneWidget);

      // Verify Dhikr body text
      expect(
        find.text('أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ وَالْحَمْدُ لِلَّهِ'),
        findsOneWidget,
      );

      // Verify that no divider is shown since fadl and source are empty
      expect(find.byType(Divider), findsOneWidget); // only header divider, no content divider

      // Verify SingleChildScrollView wraps card internal content
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('Renders subtle divider, Fadl badge, and Source when non-empty', (tester) async {
      const item = DhikrItem(
        id: 6,
        subCategoryId: 2,
        content: 'اللَّهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا',
        fadl: 'من قالها حين يصبح وحين يمسي كفته من كل شيء',
        source: 'رواه أبو داود والترمذي',
        repeatCount: 3,
        orderIndex: 2,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DhikrCard(
              item: item,
              chapterTitle: 'أذكار الصباح',
              currentIndex: 1,
              totalItems: 24,
            ),
          ),
        ),
      );

      // Verify Dhikr body
      expect(find.text('اللَّهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا'), findsOneWidget);

      // Verify Fadl text
      expect(
        find.text('من قالها حين يصبح وحين يمسي كفته من كل شيء'),
        findsOneWidget,
      );

      // Verify Source text
      expect(find.text('رواه أبو داود والترمذي'), findsOneWidget);

      // Verify Book icon is rendered for source
      expect(find.byIcon(Icons.menu_book_rounded), findsOneWidget);

      // Verify 2 dividers: header divider + content divider
      expect(find.byType(Divider), findsNWidgets(2));
    });

    testWidgets('Fallback extraction for effectiveFadl and effectiveSource', (tester) async {
      const item = DhikrItem(
        id: 7,
        subCategoryId: 2,
        content: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
        footnote: 'حُطَّتْ خَطَايَاهُ وَإِنْ كَانَتْ مِثْلَ زَبَدِ الْبَحْرِ\n• المصدر: صحيح البخاري',
        repeatCount: 100,
        orderIndex: 3,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DhikrCard(
              item: item,
              currentIndex: 2,
              totalItems: 24,
            ),
          ),
        ),
      );

      // Verify extracted Fadl and Source
      expect(
        find.text('حُطَّتْ خَطَايَاهُ وَإِنْ كَانَتْ مِثْلَ زَبَدِ الْبَحْرِ'),
        findsOneWidget,
      );
      expect(find.text('صحيح البخاري'), findsOneWidget);
    });
  });
}
