/// Production database seeder for the Awrad app.
///
/// Implements verified parsing, robust footnote alignment (resolving array
/// length desynchronization), regex repeat-count extraction, and atomic
/// batch insertion into the 3-tier SQLite schema:
///   `parent_categories` -> `sub_categories` -> `dhikr_items`.
library;

import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/hisn_category_mapper.dart';
import '../../models/dhikr_item_model.dart';
import '../../models/parent_category_model.dart';
import '../../models/sub_category_model.dart';

/// Handles seeding the SQLite database from the bundled Hisn al-Muslim JSON dataset.
class DatabaseSeeder {
  const DatabaseSeeder();

  /// Loads, parses, aligns, and bulk-inserts all categories, sub-categories,
  /// and Dhikr items into [db] inside a single atomic transaction.
  Future<void> seed(Database db) async {
    developer.log('Loading dataset from ${AssetPaths.hisnAlmuslimJson}...', name: 'DatabaseSeeder');

    String rawJson;
    try {
      rawJson = await rootBundle.loadString(AssetPaths.hisnAlmuslimJson);
    } catch (_) {
      try {
        rawJson = await rootBundle.loadString(AssetPaths.hisnMuslimJson);
      } catch (e) {
        throw StateError('Cannot load asset "${AssetPaths.hisnAlmuslimJson}" or "${AssetPaths.hisnMuslimJson}": $e');
      }
    }

    final dynamic rawData;
    try {
      rawData = json.decode(rawJson);
    } catch (e) {
      throw StateError('Cannot parse JSON from "${AssetPaths.hisnAlmuslimJson}": $e');
    }

    // 1. Prepare Parent Categories (the 11 canonical parents, IDs 1..11)
    final parentModels = HisnCategoryMapper.parentCategories
        .where((p) => p.id > 0) // ID 0 is virtual "جميع الأذكار"
        .map((p) => ParentCategoryModel(
              id: p.id,
              name: p.name,
              iconName: p.iconName,
              orderIndex: p.orderIndex,
            ))
        .toList(growable: false);

    final Map<String, int> parentNameToId = {
      for (final p in parentModels) p.name.trim(): p.id,
    };

    // 2. Prepare Sub-categories & Dhikr items
    final List<SubCategoryModel> subCategoryModels = [];
    final List<DhikrItemModel> dhikrItemModels = [];

    int subCatIdCounter = 1;
    int dhikrIdCounter = 1;
    final Map<int, int> subCatOrderCounters = {};

    if (rawData is List) {
      for (final rawChapter in rawData) {
        if (rawChapter is! Map<String, dynamic>) continue;
        final parentName = (rawChapter['parent_category'] as String?)?.trim() ?? '';
        final chapterTitle = (rawChapter['sub_category'] as String?)?.trim() ?? '';
        final rawItems = rawChapter['items'] as List<dynamic>? ?? [];

        if (chapterTitle.isEmpty || rawItems.isEmpty) continue;
        if (HisnCategoryMapper.shouldExclude(chapterTitle)) continue;

        int? parentId = parentNameToId[parentName];
        parentId ??= HisnCategoryMapper.resolveParentCategoryId(chapterTitle);
        parentId ??= 1;

        final currentSubCatId = subCatIdCounter++;
        final orderInParent = (subCatOrderCounters[parentId] ?? 0) + 1;
        subCatOrderCounters[parentId] = orderInParent;

        final subCatModel = SubCategoryModel(
          id: currentSubCatId,
          parentId: parentId,
          title: chapterTitle,
          orderIndex: orderInParent,
          dhikrCount: rawItems.length,
        );
        subCategoryModels.add(subCatModel);

        for (int i = 0; i < rawItems.length; i++) {
          final item = rawItems[i] as Map<String, dynamic>;
          final content = (item['text'] as String?)?.trim() ?? '';
          if (content.isEmpty) continue;

          final rawId = (item['id'] as num?)?.toInt();
          final itemId = rawId ?? dhikrIdCounter++;

          final repeatCount = (item['repeat'] as num?)?.toInt() ?? extractRepeatCount(content);
          final fadl = (item['fadl'] as String?)?.trim() ?? '';
          final source = (item['source'] as String?)?.trim() ?? '';

          String footnote = '';
          if (fadl.isNotEmpty && source.isNotEmpty) {
            footnote = '$fadl\n• المصدر: $source';
          } else if (fadl.isNotEmpty) {
            footnote = fadl;
          } else if (source.isNotEmpty) {
            footnote = source;
          }

          final dhikrModel = DhikrItemModel(
            id: itemId,
            subCategoryId: currentSubCatId,
            content: content,
            footnote: footnote,
            fadl: fadl,
            source: source,
            repeatCount: repeatCount > 0 ? repeatCount : 1,
            orderIndex: i + 1,
            subCategoryTitle: chapterTitle,
          );
          dhikrItemModels.add(dhikrModel);
        }
      }
    } else if (rawData is Map<String, dynamic>) {
      for (final entry in rawData.entries) {
        final chapterTitle = entry.key.trim();
        if (chapterTitle.isEmpty || entry.value is! Map<String, dynamic>) continue;

        // Exclude introductory / non-dhikr content completely from normal chapters
        if (HisnCategoryMapper.shouldExclude(chapterTitle)) {
          developer.log('Excluding non-Dhikr chapter: $chapterTitle', name: 'DatabaseSeeder');
          continue;
        }

        // Resolve parent category ID (1..11)
        final parentId = HisnCategoryMapper.resolveParentCategoryId(chapterTitle);
        if (parentId == null) {
          developer.log('Warning: No parent category found for "$chapterTitle"', name: 'DatabaseSeeder');
          continue;
        }

        final chapterData = entry.value as Map<String, dynamic>;
        final rawTexts = chapterData['text'];
        final rawFootnotes = chapterData['footnote'];

        final List<String> texts = rawTexts is List
            ? rawTexts.map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList()
            : [];
        final List<String> footnotes = rawFootnotes is List
            ? rawFootnotes.map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList()
            : [];

        if (texts.isEmpty) continue;

        final currentSubCatId = subCatIdCounter++;
        final orderInParent = (subCatOrderCounters[parentId] ?? 0) + 1;
        subCatOrderCounters[parentId] = orderInParent;

        final subCatModel = SubCategoryModel(
          id: currentSubCatId,
          parentId: parentId,
          title: chapterTitle,
          orderIndex: orderInParent,
          dhikrCount: texts.length,
        );
        subCategoryModels.add(subCatModel);

        // Align footnotes to resolve index desynchronization
        final alignedFootnotes = alignFootnotes(chapterTitle, texts, footnotes);

        for (int i = 0; i < texts.length; i++) {
          final content = texts[i];
          final footnote = alignedFootnotes[i];
          final repeatCount = extractRepeatCount(content);

          final dhikrModel = DhikrItemModel(
            id: dhikrIdCounter++,
            subCategoryId: currentSubCatId,
            content: content,
            footnote: footnote,
            repeatCount: repeatCount,
            orderIndex: i + 1,
            subCategoryTitle: chapterTitle,
          );
          dhikrItemModels.add(dhikrModel);
        }
      }
    }

    developer.log(
      'Prepared ${parentModels.length} parents, ${subCategoryModels.length} sub-categories, '
      'and ${dhikrItemModels.length} Dhikr items.',
      name: 'DatabaseSeeder',
    );

    // 3. Atomic Batch Insertion inside SQLite transaction
    await db.transaction((txn) async {
      // Clear existing records
      await txn.delete(DatabaseConstants.completionLogsTable);
      await txn.delete(DatabaseConstants.dhikrItemsTable);
      await txn.delete(DatabaseConstants.subCategoriesTable);
      await txn.delete(DatabaseConstants.parentCategoriesTable);

      final batch = txn.batch();

      // Insert parent categories
      for (final p in parentModels) {
        batch.insert(
          DatabaseConstants.parentCategoriesTable,
          p.toMapWithId(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      // Insert sub-categories
      for (final s in subCategoryModels) {
        batch.insert(
          DatabaseConstants.subCategoriesTable,
          s.toMapWithId(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      // Insert dhikr items
      for (final d in dhikrItemModels) {
        batch.insert(
          DatabaseConstants.dhikrItemsTable,
          d.toMapWithId(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit(noResult: true);
    });

    developer.log(
      'Atomic batch insertion completed successfully.',
      name: 'DatabaseSeeder',
    );
  }

  /// Extracts target repeat count from Dhikr text using regex matching.
  ///
  /// Matches patterns like `((.*?)مرات)` or `((.*?)مرة)` extracting integers
  /// (e.g., 3, 4, 7, 10, 33, 100), defaulting to 1 if unspecified.
  static int extractRepeatCount(String text) {
    // 1. Search for standard parenthetical repeat expressions: (3 مرات), (عشر مرات), etc.
    final parenRegex = RegExp(r'\(([^)]*مر(?:ات|ة)[^)]*)\)');
    final match = parenRegex.firstMatch(text);
    final target = match != null ? match.group(1)! : text;

    // Check for explicit Arabic or English digits
    final digitMatch = RegExp(r'(\d+)').firstMatch(target);
    if (digitMatch != null) {
      final parsed = int.tryParse(digitMatch.group(1)!);
      if (parsed != null && parsed > 0) return parsed;
    }

    // Check Arabic word numbers
    if (target.contains('مائة') || target.contains('مئة')) return 100;
    if (target.contains('ثلاث وثلاثين') || target.contains('ثلاثاً وثلاثين')) return 33;
    if (target.contains('عشر')) return 10;
    if (target.contains('سبع')) return 7;
    if (target.contains('أربع')) return 4;
    if (target.contains('ثلاث')) return 3;
    if (target.contains('مرة واحدة')) return 1;

    // Direct text checks if parentheses were omitted in the source
    if (text.contains('ثلاث مرات') || text.contains('ثلاثاً') || text.contains('ثلاثا')) return 3;
    if (text.contains('أربع مرات') || text.contains('أربعاً') || text.contains('أربعا')) return 4;
    if (text.contains('سبع مرات') || text.contains('سبعاً') || text.contains('سبعا')) return 7;
    if (text.contains('عشر مرات') || text.contains('عشراً') || text.contains('عشرا')) return 10;
    if (text.contains('مائة مرة') || text.contains('مئة مرة')) return 100;
    if (text.contains('ثلاث وثلاثين') || text.contains('ثلاثاً وثلاثين')) return 33;

    return 1;
  }

  /// Aligns footnotes to their corresponding texts, resolving array length mismatches.
  ///
  /// In Hisn al-Muslim JSON, certain chapters contain more footnotes than text blocks
  /// due to explanatory notes (e.g. "أقر وأعترف") or situational variants (e.g. "وإذا أمسى قال...").
  /// This method attaches multiple related footnote lines to their matching parent text block
  /// rather than shifting indices across unrelated Dhikrs.
  static List<String> alignFootnotes(
    String chapterTitle,
    List<String> texts,
    List<String> footnotes,
  ) {
    if (footnotes.isEmpty) {
      return List.filled(texts.length, '');
    }
    if (footnotes.length == texts.length) {
      return List.from(footnotes);
    }
    if (footnotes.length == 1) {
      return List.filled(texts.length, footnotes.first);
    }

    // ── 1. أذكار الصباح والمساء (25 texts vs 35 footnotes) ───────────────────
    if (chapterTitle == 'أذكار الصباح والمساء') {
      final result = List.filled(texts.length, '');
      final mapping = <int, List<int>>{
        0: [0, 1],       // Anas hadith + Ayat al-Kursi
        1: [2],          // Al-Ikhlas & Al-Mu'awwidhatayn
        2: [3, 4, 5],    // Asbahna wa Asbaha + Evening variants + Muslim
        3: [6, 7],       // Allahumma bika asbahna + Evening variant + Tirmidhi
        4: [8, 9],       // Sayyid al-Istighfar + "أقر وأعترف" + Bukhari
        5: [10, 11],     // Allahumma inni asbahtu + Evening variant + Takhrij
        6: [12, 13],     // Allahumma ma asbaha bi + Evening variant + Takhrij
        7: [14],         // Allahumma 'afini
        8: [15],         // Hasbiyallahu
        9: [16],         // Al-'afw wal-'afiyah
        10: [17],        // 'Alim al-ghayb
        11: [18],        // Bismillahil-ladhi
        12: [19],        // Raditu billah
        13: [20],        // Ya Hayyu Ya Qayyum
        14: [21, 22, 23],// Asbahna wa asbaha al-mulku + variants + Takhrij
        15: [24, 25],    // Asbahna 'ala fitratil-Islam + variant + Ahmad
        16: [26],        // Subhanallahi wa bihamdihi (100)
        17: [27, 28],    // La ilaha illallah (10)
        18: [29],        // La ilaha illallah (100)
        19: [30],        // Subhanallahi wa bihamdihi 'adada khalqihi
        20: [31],        // 'Ilman nafi'an
        21: [32],        // Astaghfirullah
        22: [33],        // A'udhu bi kalimatillah (evening 3)
        23: [34],        // Salawat 10 times
        24: [34],        // Salawat continued
      };

      for (int i = 0; i < texts.length; i++) {
        final indices = mapping[i] ?? [i < footnotes.length ? i : footnotes.length - 1];
        result[i] = indices
            .where((idx) => idx < footnotes.length)
            .map((idx) => footnotes[idx])
            .join('\n• ');
      }
      return result;
    }

    // ── 2. أذكار الاستيقاظ من النوم (4 texts vs 7 footnotes) ─────────────────
    if (chapterTitle == 'أذكار الاستيقاظ من النوم') {
      final result = List.filled(texts.length, '');
      result[0] = [footnotes[0], footnotes[1], footnotes[2]].join('\n• ');
      result[1] = footnotes[3];
      result[2] = [footnotes[4], footnotes[5]].join('\n• ');
      result[3] = footnotes[6];
      return result;
    }

    // ── 3. دعاء دخول المسجد (2 texts vs 4 footnotes) ────────────────────────
    if (chapterTitle == 'دعاء دخول المسجد') {
      return [
        footnotes[0],
        [footnotes[1], footnotes[2], footnotes[3]].join('\n• '),
      ];
    }

    // ── 4. أذكار الأذان (5 texts vs 6 footnotes) ─────────────────────────────
    if (chapterTitle == 'أذكار الأذان') {
      return [
        footnotes[0],
        [footnotes[1], footnotes[2]].join('\n• '),
        footnotes[3],
        footnotes[4],
        footnotes[5],
      ];
    }

    // ── 5. أذكار النوم (13 texts vs 16 footnotes) ───────────────────────────
    if (chapterTitle == 'أذكار النوم') {
      final result = List.filled(texts.length, '');
      final mapping = <int, List<int>>{
        0: [0],
        1: [1],
        2: [2],
        3: [3, 4],
        4: [5],
        5: [6, 7],
        6: [8],
        7: [9, 10],
        8: [11],
        9: [12],
        10: [13],
        11: [13],
        12: [14, 15],
      };
      for (int i = 0; i < texts.length; i++) {
        final indices = mapping[i] ?? [i];
        result[i] = indices
            .where((idx) => idx < footnotes.length)
            .map((idx) => footnotes[idx])
            .join('\n• ');
      }
      return result;
    }

    // ── 6. ما يعصم به من الدجال (1 text vs 2 footnotes) ─────────────────────
    if (chapterTitle == 'ما يعصم به من الدجال') {
      return [footnotes.join('\n• ')];
    }

    // ── Generic Fallback for Any Other Chapter ──────────────────────────────
    final result = <String>[];
    for (int i = 0; i < texts.length; i++) {
      if (i < footnotes.length) {
        result.add(footnotes[i]);
      } else {
        result.add(footnotes.last);
      }
    }
    return result;
  }
}
