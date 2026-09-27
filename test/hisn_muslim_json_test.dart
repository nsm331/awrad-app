import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Hisn al-Muslim JSON Dataset Integrity Tests', () {
    const datasetPaths = [
      'assets/data/hisn_muslim.json',
      'assets/data/hisn_almuslim.json',
    ];

    for (final path in datasetPaths) {
      group('Dataset verification for $path', () {
        late List<dynamic> rawList;

        setUpAll(() {
          final file = File(path);
          expect(file.existsSync(), isTrue, reason: '$path must exist on disk.');
          final content = file.readAsStringSync();
          expect(content.isNotEmpty, isTrue, reason: '$path must not be empty.');
          final dynamic decoded = json.decode(content);
          expect(decoded, isA<List<dynamic>>(), reason: '$path must be a List of category blocks.');
          rawList = decoded as List<dynamic>;
        });

        test('Dataset contains non-empty chapters and valid structure', () {
          expect(rawList.isNotEmpty, isTrue);
          for (final entry in rawList) {
            expect(entry, isA<Map<String, dynamic>>());
            final map = entry as Map<String, dynamic>;
            expect(map.containsKey('parent_category'), isTrue);
            expect(map.containsKey('sub_category'), isTrue);
            expect(map.containsKey('items'), isTrue);
            final items = map['items'] as List<dynamic>;
            expect(items.isNotEmpty, isTrue);
          }
        });

        test('Separated Morning/Evening: أذكار الصباح (24 items, IDs 5-28)', () {
          final morningChapter = rawList.firstWhere(
            (c) => (c as Map<String, dynamic>)['sub_category'] == 'أذكار الصباح',
            orElse: () => null,
          ) as Map<String, dynamic>?;

          expect(morningChapter, isNotNull, reason: 'أذكار الصباح chapter must exist');
          expect(morningChapter!['parent_category'], equals('اليوم والليلة'));

          final items = morningChapter['items'] as List<dynamic>;
          expect(items.length, equals(24), reason: 'أذكار الصباح must contain exactly 24 items');

          for (int i = 0; i < items.length; i++) {
            final item = items[i] as Map<String, dynamic>;
            final expectedId = 5 + i;
            expect(item['id'], equals(expectedId), reason: 'Morning item ID should be $expectedId');
            expect(item['text'], isA<String>());
            expect((item['text'] as String).trim().isNotEmpty, isTrue);
            expect(item['repeat'], isA<num>());
            expect((item['repeat'] as num).toInt(), greaterThanOrEqualTo(1));
            expect(item.containsKey('fadl'), isTrue);
            expect(item.containsKey('source'), isTrue);
          }
        });

        test('Separated Morning/Evening: أذكار المساء (22 items, IDs 29-50)', () {
          final eveningChapter = rawList.firstWhere(
            (c) => (c as Map<String, dynamic>)['sub_category'] == 'أذكار المساء',
            orElse: () => null,
          ) as Map<String, dynamic>?;

          expect(eveningChapter, isNotNull, reason: 'أذكار المساء chapter must exist');
          expect(eveningChapter!['parent_category'], equals('اليوم والليلة'));

          final items = eveningChapter['items'] as List<dynamic>;
          expect(items.length, equals(22), reason: 'أذكار المساء must contain exactly 22 items');

          for (int i = 0; i < items.length; i++) {
            final item = items[i] as Map<String, dynamic>;
            final expectedId = 29 + i;
            expect(item['id'], equals(expectedId), reason: 'Evening item ID should be $expectedId');
            expect(item['text'], isA<String>());
            expect((item['text'] as String).trim().isNotEmpty, isTrue);
            expect(item['repeat'], isA<num>());
            expect((item['repeat'] as num).toInt(), greaterThanOrEqualTo(1));
            expect(item.containsKey('fadl'), isTrue);
            expect(item.containsKey('source'), isTrue);
          }
        });

        test('Every item in the dataset has explicit pre-mapped fields', () {
          int totalItems = 0;
          for (final rawChapter in rawList) {
            final chapter = rawChapter as Map<String, dynamic>;
            final items = chapter['items'] as List<dynamic>;
            for (final it in items) {
              final item = it as Map<String, dynamic>;
              expect(item.containsKey('id'), isTrue);
              expect(item.containsKey('text'), isTrue);
              expect(item.containsKey('repeat'), isTrue);
              expect(item.containsKey('fadl'), isTrue);
              expect(item.containsKey('source'), isTrue);

              final text = (item['text'] as String?)?.trim() ?? '';
              expect(text.isNotEmpty, isTrue);

              final repeat = (item['repeat'] as num?)?.toInt() ?? 0;
              expect(repeat, greaterThanOrEqualTo(1));

              totalItems++;
            }
          }
          expect(totalItems, equals(146));
        });
      });
    }
  });
}
