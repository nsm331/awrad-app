import 'package:flutter_test/flutter_test.dart';
import 'package:awrad_app/core/utils/arabic_normalizer.dart';

void main() {
  group('ArabicNormalizer Tests', () {
    test('stripTashkeel removes all vowel and diacritic marks', () {
      const vocalized = 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ';
      final stripped = ArabicNormalizer.stripTashkeel(vocalized);
      expect(stripped, 'أصبحنا وأصبح الملك لله');
    });

    test('normalize standardizes Alif, Taa Marbuta, and Yaa variants', () {
      const input = 'أَذْكَارُ الصَّبَاحِ وَالْمَسَاءِ وَالْأَدْعِيَةِ';
      final normalized = ArabicNormalizer.normalize(input);
      expect(normalized, 'اذكار الصباح والمساء والادعيه');
    });

    test('containsNormalized correctly matches unvocalized query against vocalized text', () {
      const fullContent = 'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ ، خَلَقْتَنِي وَأَنَا عَبْدُكَ';

      expect(ArabicNormalizer.containsNormalized(fullContent, 'اللهم'), isTrue);
      expect(ArabicNormalizer.containsNormalized(fullContent, 'انت ربي'), isTrue);
      expect(ArabicNormalizer.containsNormalized(fullContent, 'لا اله الا انت'), isTrue);
      expect(ArabicNormalizer.containsNormalized(fullContent, 'خلقتني'), isTrue);
      expect(ArabicNormalizer.containsNormalized(fullContent, 'غير موجود'), isFalse);
    });

    test('handles empty strings gracefully', () {
      expect(ArabicNormalizer.stripTashkeel(''), '');
      expect(ArabicNormalizer.normalize(''), '');
      expect(ArabicNormalizer.containsNormalized('نص ما', ''), isTrue);
    });
  });
}
