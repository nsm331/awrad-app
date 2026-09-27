/// Domain entity representing a Sub-Category / Chapter from Hisn al-Muslim.
///
/// Corresponds to individual chapter titles (e.g. "أذكار الصباح والمساء",
/// "دعاء لبس الثوب", "الذكر عند الخروج من المنزل").
library;

import 'package:equatable/equatable.dart';

/// A specific chapter under a [ParentCategory].
class SubCategory extends Equatable {
  /// Unique SQLite row ID.
  final int id;

  /// Foreign key referencing [ParentCategory.id].
  final int parentId;

  /// Exact chapter title from Hisn al-Muslim (e.g. "دعاء الاستفتاح").
  final String title;

  /// Display order within the parent category.
  final int orderIndex;

  /// Exact count of Dhikr items in this chapter (e.g. 25 for Morning & Evening Adhkar).
  final int dhikrCount;

  /// Optional parent category name for quick reference/display.
  final String? parentName;

  const SubCategory({
    required this.id,
    required this.parentId,
    required this.title,
    this.orderIndex = 0,
    this.dhikrCount = 0,
    this.parentName,
  });

  SubCategory copyWith({
    int? id,
    int? parentId,
    String? title,
    int? orderIndex,
    int? dhikrCount,
    String? parentName,
  }) {
    return SubCategory(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      title: title ?? this.title,
      orderIndex: orderIndex ?? this.orderIndex,
      dhikrCount: dhikrCount ?? this.dhikrCount,
      parentName: parentName ?? this.parentName,
    );
  }

  @override
  List<Object?> get props => [
        id,
        parentId,
        title,
        orderIndex,
        dhikrCount,
        parentName,
      ];

  @override
  String toString() =>
      'SubCategory(id: $id, parentId: $parentId, title: $title, items: $dhikrCount)';
}
