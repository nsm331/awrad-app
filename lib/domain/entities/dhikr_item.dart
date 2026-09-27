/// Domain entity representing a single Dhikr item.
///
/// Contains the full verified Arabic text with Tashkeel, the authentic Hadith
/// footnote reference (Takhrij / explanatory note), spiritual merit (Fadl),
/// the prescribed repeat count, and its display order within its parent chapter ([SubCategory]).
library;

import 'package:equatable/equatable.dart';

/// A single remembrance / supplication item from Hisn al-Muslim.
class DhikrItem extends Equatable {
  /// Unique, auto-assigned SQLite row ID.
  final int id;

  /// Foreign key referencing [SubCategory.id].
  final int subCategoryId;

  /// The full Arabic text with complete Tashkeel (vowel diacritics).
  final String content;

  /// The combined footnote (Fadl + Takhrij).
  final String footnote;

  /// Spiritual merit or meaning of difficult words (فضل الذكر وشرح المفردات).
  final String fadl;

  /// The authentic Hadith reference (تخريج الحديث / مصدر الذكر).
  final String source;

  /// The number of times the user is prescribed to recite this Dhikr (e.g. 1, 3, 7, 33, 100).
  final int repeatCount;

  /// Zero-based display order within the sub-category chapter.
  final int orderIndex;

  /// The specific sub-chapter title from Hisn al-Muslim (e.g. "أذكار الصباح", "أذكار المساء").
  final String subCategoryTitle;

  const DhikrItem({
    required this.id,
    required this.subCategoryId,
    required this.content,
    this.footnote = '',
    this.fadl = '',
    this.source = '',
    required this.repeatCount,
    required this.orderIndex,
    this.subCategoryTitle = '',
  });

  /// Resolved non-empty Fadl text (falls back to extracting from [footnote] if separate field is empty).
  String get effectiveFadl {
    if (fadl.trim().isNotEmpty) return fadl.trim();
    if (footnote.contains('• المصدر:')) {
      final parts = footnote.split('• المصدر:');
      return parts[0].trim();
    }
    if (footnote.contains('المصدر:')) {
      final parts = footnote.split('المصدر:');
      return parts[0].trim();
    }
    return '';
  }

  /// Resolved non-empty Source / Takhrij text (falls back to [footnote] if separate field is empty).
  String get effectiveSource {
    if (source.trim().isNotEmpty) return source.trim();
    if (footnote.contains('• المصدر:')) {
      final parts = footnote.split('• المصدر:');
      return parts.length > 1 ? parts[1].trim() : '';
    }
    if (footnote.contains('المصدر:')) {
      final parts = footnote.split('المصدر:');
      return parts.length > 1 ? parts[1].trim() : '';
    }
    return footnote.trim();
  }

  // ── Backward-compatibility getters ──────────────────────────────────────────

  /// Legacy alias for [subCategoryId].
  int get categoryId => subCategoryId;

  /// Legacy alias for [subCategoryTitle].
  String get subCategory => subCategoryTitle;

  @override
  List<Object?> get props => [
        id,
        subCategoryId,
        content,
        footnote,
        fadl,
        source,
        repeatCount,
        orderIndex,
        subCategoryTitle,
      ];

  @override
  String toString() =>
      'DhikrItem(id: $id, subCategoryId: $subCategoryId, chapter: $subCategoryTitle, repeat: $repeatCount)';
}
