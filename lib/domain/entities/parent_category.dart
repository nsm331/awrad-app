/// Domain entity representing a main Parent Category (thematic group).
///
/// Awrad groups 133 authentic chapters into 11 canonical parent categories
/// plus the virtual all-inclusive "جميع الأذكار" category (id: 0).
library;

import 'package:equatable/equatable.dart';

/// A primary thematic group displayed on the Home Dashboard (e.g. "اليوم والليلة").
class ParentCategory extends Equatable {
  /// Unique identifier (0 = جميع الأذكار, 1..11 = canonical thematic parents).
  final int id;

  /// Full Arabic name (e.g. "اليوم والليلة", "البيت والأهل").
  final String name;

  /// Material icon name string used to resolve [Icons] at runtime.
  final String iconName;

  /// Display order index for sorting parent categories.
  final int orderIndex;

  /// Total number of sub-chapters contained within this parent category.
  final int subCategoryCount;

  /// Total number of individual Dhikrs contained within this parent category.
  final int totalDhikrCount;

  const ParentCategory({
    required this.id,
    required this.name,
    this.iconName = 'category',
    this.orderIndex = 0,
    this.subCategoryCount = 0,
    this.totalDhikrCount = 0,
  });

  /// Alias for subCategoryCount.
  int get chapterCount => subCategoryCount;

  /// Creates a copy with updated counts or fields.
  ParentCategory copyWith({
    int? id,
    String? name,
    String? iconName,
    int? orderIndex,
    int? subCategoryCount,
    int? totalDhikrCount,
  }) {
    return ParentCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      orderIndex: orderIndex ?? this.orderIndex,
      subCategoryCount: subCategoryCount ?? this.subCategoryCount,
      totalDhikrCount: totalDhikrCount ?? this.totalDhikrCount,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        iconName,
        orderIndex,
        subCategoryCount,
        totalDhikrCount,
      ];

  @override
  String toString() =>
      'ParentCategory(id: $id, name: $name, chapters: $subCategoryCount, dhikrs: $totalDhikrCount)';
}
