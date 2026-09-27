import 'package:flutter_test/flutter_test.dart';
import 'package:awrad_app/core/utils/share_helper.dart';

void main() {
  group('ShareHelper Tests', () {
    test('formatDhikrText formats text with all components cleanly', () {
      final text = ShareHelper.formatDhikrText(
        categoryName: 'أذكار الصباح',
        content: 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ',
        repeatCount: 3,
        fadl: 'حفظ من كل سوء حتى يمسي',
        source: 'صحيح مسلم (رقم ٢٦٩٢)',
      );

      expect(text, contains('من تطبيق أَوْرَاد — حصن المسلم الموثق'));
      expect(text, contains('﴿ أذكار الصباح ﴾'));
      expect(text, contains('أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ'));
      expect(text, contains('• عدد التكرار: 3 مرات'));
      expect(text, contains('• فضل الذكر: حفظ من كل سوء حتى يمسي'));
      expect(text, contains('• المصدر والتخريج: صحيح مسلم (رقم ٢٦٩٢)'));
      expect(text, contains('اللهم اجعله صدقة جارية'));
    });

    test('formatDhikrText handles singular repeat count', () {
      final text = ShareHelper.formatDhikrText(
        categoryName: 'أذكار النوم',
        content: 'بِاسْمِكَ رَبِّي وَضَعْتُ جَنْبِي',
        repeatCount: 1,
      );

      expect(text, contains('• عدد التكرار: 1 مرة'));
      expect(text, isNot(contains('• فضل الذكر:')));
      expect(text, isNot(contains('• المصدر والتخريج:')));
    });

    test('formatDhikrText gracefully ignores whitespace-only fadl and source', () {
      final text = ShareHelper.formatDhikrText(
        categoryName: 'أذكار المساء',
        content: 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ',
        repeatCount: 1,
        fadl: '   ',
        source: '  \n  ',
      );

      expect(text, isNot(contains('• فضل الذكر:')));
      expect(text, isNot(contains('• المصدر والتخريج:')));
    });
  });
}
