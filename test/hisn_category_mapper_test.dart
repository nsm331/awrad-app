import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:awrad_app/core/utils/hisn_category_mapper.dart';

void main() {
  group('HisnCategoryMapper Tests', () {
    test('Verify canonical 12 parent categories structure', () {
      final categories = HisnCategoryMapper.parentCategories;
      expect(categories.length, equals(12));

      // Category 0: All Remembrances (جميع الأذكار)
      expect(categories[0].id, equals(0));
      expect(categories[0].name, equals('جميع الأذكار'));
      expect(categories[0].iconName, equals('all_inclusive'));
      expect(categories[0].orderIndex, equals(0));

      // Categories 1 to 11
      final expectedNames = [
        'جميع الأذكار',
        'اليوم والليلة',
        'البيت والأهل',
        'الوضوء والصلاة',
        'الطعام والشراب',
        'السفر والتنقل',
        'الفرح والخوف والكرب',
        'الحج والعمرة',
        'المرض والجنائز',
        'التعامل والآداب',
        'الطبيعة والأنواء',
        'التسابيح والاستغفار',
      ];

      for (int i = 0; i < 12; i++) {
        expect(categories[i].id, equals(i));
        expect(categories[i].name, equals(expectedNames[i]));
        expect(categories[i].orderIndex, equals(i));
        expect(categories[i].iconName.isNotEmpty, isTrue);
      }
    });

    test('Introduction (المقدمة) is completely excluded', () {
      expect(HisnCategoryMapper.shouldExclude('المقدمة'), isTrue);
      expect(HisnCategoryMapper.shouldExclude('المقدمة '), isTrue);
      expect(HisnCategoryMapper.resolveParentCategoryId('المقدمة'), isNull);
    });

    test('Primary Group 1: اليوم والليلة mapping', () {
      expect(HisnCategoryMapper.resolveParentCategoryId('أذكار الصباح والمساء'), equals(1));
      expect(HisnCategoryMapper.resolveParentCategoryId('أذكار الصباح'), equals(1));
      expect(HisnCategoryMapper.resolveParentCategoryId('أذكار المساء'), equals(1));
      expect(HisnCategoryMapper.resolveParentCategoryId('أذكار الاستيقاظ من النوم'), equals(1));
      expect(HisnCategoryMapper.resolveParentCategoryId('أذكار النوم'), equals(1));
      expect(HisnCategoryMapper.resolveParentCategoryId('الدعاء إذا تقلب ليلاً'), equals(1));
      expect(HisnCategoryMapper.resolveParentCategoryId('دعاء القلق والفزع في النوم ومن بلي بالوحشة'), equals(1));
    });

    test('Primary Group 2: البيت والأهل mapping', () {
      expect(HisnCategoryMapper.resolveParentCategoryId('الذكر عند الخروج من المنزل'), equals(2));
      expect(HisnCategoryMapper.resolveParentCategoryId('الذكر عند الدخول المنزل'), equals(2));
      expect(HisnCategoryMapper.resolveParentCategoryId('دعاء لبس الثوب'), equals(2));
      expect(HisnCategoryMapper.resolveParentCategoryId('ما يقول إذا وضع الثوب'), equals(2));
      expect(HisnCategoryMapper.resolveParentCategoryId('تهنئة المولود له وجوابه'), equals(2));
      expect(HisnCategoryMapper.resolveParentCategoryId('ما يعوذ به الأولاد'), equals(2));
    });

    test('Primary Group 3: الوضوء والصلاة mapping', () {
      expect(HisnCategoryMapper.resolveParentCategoryId('الذكر قبل الوضوء'), equals(3));
      expect(HisnCategoryMapper.resolveParentCategoryId('الذكر بعد الفراغ من الوضوء'), equals(3));
      expect(HisnCategoryMapper.resolveParentCategoryId('دعاء الذهاب إلى المسجد'), equals(3));
      expect(HisnCategoryMapper.resolveParentCategoryId('دعاء دخول المسجد'), equals(3));
      expect(HisnCategoryMapper.resolveParentCategoryId('دعاء الخروج من المسجد'), equals(3));
      expect(HisnCategoryMapper.resolveParentCategoryId('أذكار الأذان'), equals(3));
      expect(HisnCategoryMapper.resolveParentCategoryId('دعاء الاستفتاح'), equals(3));
      expect(HisnCategoryMapper.resolveParentCategoryId('دعاء الركوع'), equals(3));
      expect(HisnCategoryMapper.resolveParentCategoryId('دعاء السجود'), equals(3));
      expect(HisnCategoryMapper.resolveParentCategoryId('التشهد'), equals(3));
      expect(HisnCategoryMapper.resolveParentCategoryId('الأذكار بعد السلام من الصلاة'), equals(3));
      expect(HisnCategoryMapper.resolveParentCategoryId('دعاء قنوت الوتر'), equals(3));
    });

    test('Primary Group 4: الطعام والشراب mapping', () {
      expect(HisnCategoryMapper.resolveParentCategoryId('الدعاء قبل الطعام'), equals(4));
      expect(HisnCategoryMapper.resolveParentCategoryId('الدعاء عند الفراغ من الطعام'), equals(4));
      expect(HisnCategoryMapper.resolveParentCategoryId('دعاء الضيف لصاحب الطعام'), equals(4));
      expect(HisnCategoryMapper.resolveParentCategoryId('الدعاء لمن سقاه أو إذا أراد ذلك'), equals(4));
      expect(HisnCategoryMapper.resolveParentCategoryId('الدعاء إذا أفطر عند أهل بيت'), equals(4));
    });

    test('Primary Group 5: السفر والتنقل mapping', () {
      expect(HisnCategoryMapper.resolveParentCategoryId('دعاء ركوب الدابة'), equals(5));
      expect(HisnCategoryMapper.resolveParentCategoryId('دعاء السفر'), equals(5));
      expect(HisnCategoryMapper.resolveParentCategoryId('دعاء دخول القرية أو البلدة'), equals(5));
      expect(HisnCategoryMapper.resolveParentCategoryId('دعاء دخول السوق'), equals(5));
      expect(HisnCategoryMapper.resolveParentCategoryId('دعاء المسافر للمقيم'), equals(5));
    });

    test('Primary Group 6: الفرح والخوف mapping', () {
      expect(HisnCategoryMapper.resolveParentCategoryId('دعاء الكرب'), equals(6));
      expect(HisnCategoryMapper.resolveParentCategoryId('دعاء الهم والحزن'), equals(6));
      expect(HisnCategoryMapper.resolveParentCategoryId('دعاء لقاء العدو وذي السلطان'), equals(6));
      expect(HisnCategoryMapper.resolveParentCategoryId('دعاء الغضب'), equals(6));
      expect(HisnCategoryMapper.resolveParentCategoryId('ما يقال عند الفزع'), equals(6));
    });

    test('Primary Group 7: الحج والعمرة mapping', () {
      expect(HisnCategoryMapper.resolveParentCategoryId('كيف يلبي المحرم في الحج أو العمرة'), equals(7));
      expect(HisnCategoryMapper.resolveParentCategoryId('التكبير إذا أتى الركن الأسود'), equals(7));
      expect(HisnCategoryMapper.resolveParentCategoryId('الدعاء بين الركن اليماني والحجر الأسود'), equals(7));
      expect(HisnCategoryMapper.resolveParentCategoryId('دعاء يوم عرفة'), equals(7));
      expect(HisnCategoryMapper.resolveParentCategoryId('التكبير عند رمي الجمار مع كل حصاة'), equals(7));
    });

    test('Primary Group 8: المرض والجنائز mapping', () {
      expect(HisnCategoryMapper.resolveParentCategoryId('الدعاء للمريض في عيادته'), equals(8));
      expect(HisnCategoryMapper.resolveParentCategoryId('فضل عيادة المريض'), equals(8));
      expect(HisnCategoryMapper.resolveParentCategoryId('تلقين المحتضر'), equals(8));
      expect(HisnCategoryMapper.resolveParentCategoryId('دعاء من أصيب بمصيبة'), equals(8));
      expect(HisnCategoryMapper.resolveParentCategoryId('الدعاء للميت في الصلاة عليه'), equals(8));
      expect(HisnCategoryMapper.resolveParentCategoryId('دعاء زيارة القبور'), equals(8));
    });

    test('Primary Group 9: التعامل والآداب mapping', () {
      expect(HisnCategoryMapper.resolveParentCategoryId('إفشاء السلام'), equals(9));
      expect(HisnCategoryMapper.resolveParentCategoryId('الدعاء لمن صنع إليك معروفاً'), equals(9));
      expect(HisnCategoryMapper.resolveParentCategoryId('كفارة المجلس'), equals(9));
      expect(HisnCategoryMapper.resolveParentCategoryId('دعاء العطاس'), equals(9));
      expect(HisnCategoryMapper.resolveParentCategoryId('الدعاء لمن قال إني أحبك في الله'), equals(9));
    });

    test('Primary Group 10: الطبيعة mapping', () {
      expect(HisnCategoryMapper.resolveParentCategoryId('دعاء الريح'), equals(10));
      expect(HisnCategoryMapper.resolveParentCategoryId('دعاء الرعد'), equals(10));
      expect(HisnCategoryMapper.resolveParentCategoryId('من أدعية الاستسقاء'), equals(10));
      expect(HisnCategoryMapper.resolveParentCategoryId('الدعاء إذا نزل المطر'), equals(10));
      expect(HisnCategoryMapper.resolveParentCategoryId('دعاء رؤية الهلال'), equals(10));
    });

    test('Primary Group 11: التسابيح والاستغفار mapping', () {
      expect(HisnCategoryMapper.resolveParentCategoryId('فضل التسبيح والتحميد ، والتهليل ، والتكبير'), equals(11));
      expect(HisnCategoryMapper.resolveParentCategoryId('فضل الذكر'), equals(11));
      expect(HisnCategoryMapper.resolveParentCategoryId('الاستغفار والتوبة'), equals(11));
      expect(HisnCategoryMapper.resolveParentCategoryId('كيف كان النبي صلى الله عليه وسلم يسبح ؟'), equals(11));
    });

    test('Exhaustive verification of hisn_muslim.json: all keys map cleanly without gaps', () {
      final file = File('assets/data/hisn_muslim.json');
      expect(file.existsSync(), isTrue, reason: 'hisn_muslim.json must exist');

      final dynamic decoded = json.decode(file.readAsStringSync());
      if (decoded is List) {
        final list = decoded;
        expect(list.isNotEmpty, isTrue);

        int totalDhikrCount = 0;
        final categoryItemCounts = <int, int>{};
        final canonicalNames = HisnCategoryMapper.parentCategories
            .where((p) => p.id > 0)
            .map((p) => p.name)
            .toSet();

        Map<String, dynamic>? morningChapter;
        Map<String, dynamic>? eveningChapter;

        for (final rawChapter in list) {
          final map = rawChapter as Map<String, dynamic>;
          final parentName = (map['parent_category'] as String?)?.trim() ?? '';
          final subTitle = (map['sub_category'] as String?)?.trim() ?? '';
          expect(canonicalNames.contains(parentName), isTrue,
              reason: 'Parent category "$parentName" must be one of the canonical categories');
          expect(subTitle.isNotEmpty, isTrue);

          if (subTitle == 'أذكار الصباح') {
            morningChapter = map;
          } else if (subTitle == 'أذكار المساء') {
            eveningChapter = map;
          }

          final items = map['items'] as List<dynamic>? ?? [];
          expect(items.isNotEmpty, isTrue, reason: 'Chapter "$subTitle" must have items');
          totalDhikrCount += items.length;

          final parentId = HisnCategoryMapper.parentCategories
              .firstWhere((p) => p.name == parentName)
              .id;
          categoryItemCounts[parentId] =
              (categoryItemCounts[parentId] ?? 0) + items.length;
        }

        // Verify separated morning and evening chapters
        expect(morningChapter, isNotNull, reason: 'أذكار الصباح chapter must exist');
        expect(eveningChapter, isNotNull, reason: 'أذكار المساء chapter must exist');

        final morningItems = morningChapter!['items'] as List<dynamic>;
        expect(morningItems.length, equals(24), reason: 'أذكار الصباح must contain 24 items');
        for (int i = 0; i < morningItems.length; i++) {
          final it = morningItems[i] as Map<String, dynamic>;
          expect(it['id'], equals(5 + i), reason: 'Morning item ID sequence 5..28');
        }

        final eveningItems = eveningChapter!['items'] as List<dynamic>;
        expect(eveningItems.length, equals(22), reason: 'أذكار المساء must contain 22 items');
        for (int i = 0; i < eveningItems.length; i++) {
          final it = eveningItems[i] as Map<String, dynamic>;
          expect(it['id'], equals(29 + i), reason: 'Evening item ID sequence 29..50');
        }

        expect(totalDhikrCount, greaterThan(0));
        // Ensure every parent category present has dhikrs
        for (final parentId in categoryItemCounts.keys) {
          expect((categoryItemCounts[parentId] ?? 0) > 0, isTrue);
        }
      } else if (decoded is Map) {
        final map = decoded as Map<String, dynamic>;
        int excludedCount = 0;
        int mappedCount = 0;
        int totalDhikrCount = 0;
        final categoryItemCounts = <int, int>{};

        for (final entry in map.entries) {
          final chapterName = entry.key.trim();
          if (HisnCategoryMapper.shouldExclude(chapterName)) {
            excludedCount++;
            expect(chapterName, equals('المقدمة'));
            continue;
          }

          final parentId = HisnCategoryMapper.resolveParentCategoryId(chapterName);
          expect(
            parentId,
            isNotNull,
            reason: 'Chapter "$chapterName" must map to a valid parent category ID',
          );
          expect(
            parentId! >= 1 && parentId <= 11,
            isTrue,
            reason: 'Parent ID for "$chapterName" must be between 1 and 11, got $parentId',
          );

          mappedCount++;

          final chapterData = entry.value as Map<String, dynamic>;
          final texts = chapterData['text'] as List<dynamic>? ?? [];
          totalDhikrCount += texts.length;
          categoryItemCounts[parentId] = (categoryItemCounts[parentId] ?? 0) + texts.length;
        }

        expect(excludedCount, equals(1));
        expect(mappedCount, equals(133));
        expect(totalDhikrCount, equals(293));
      }
    });
  });
}
