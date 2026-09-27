/// SQLite data model for [SubCategory].
library;

import '../../core/constants/app_constants.dart';
import '../../domain/entities/sub_category.dart';

/// SQLite data model representing the `sub_categories` table.
class SubCategoryModel {
  final int id;
  final int parentId;
  final String title;
  final int orderIndex;
  final int dhikrCount;
  final String? parentName;

  const SubCategoryModel({
    required this.id,
    required this.parentId,
    required this.title,
    this.orderIndex = 0,
    this.dhikrCount = 0,
    this.parentName,
  });

  /// DDL string to create the `sub_categories` table in SQLite.
  static const String createTableSql = '''
    CREATE TABLE ${DatabaseConstants.subCategoriesTable} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      parent_id INTEGER NOT NULL,
      title TEXT NOT NULL,
      order_index INTEGER,
      FOREIGN KEY (parent_id) REFERENCES ${DatabaseConstants.parentCategoriesTable} (id) ON DELETE CASCADE
    )
  ''';

  /// Converts a SQLite row map into a [SubCategoryModel].
  factory SubCategoryModel.fromMap(Map<String, dynamic> map) {
    return SubCategoryModel(
      id: map['id'] as int,
      parentId: map['parent_id'] as int,
      title: map['title'] as String,
      orderIndex: (map['order_index'] as int?) ?? 0,
      dhikrCount: (map['dhikr_count'] as int?) ?? 0,
      parentName: map['parent_name'] as String?,
    );
  }

  /// Converts this model into a map for SQLite insert/update.
  Map<String, dynamic> toMap() {
    return {
      'parent_id': parentId,
      'title': title,
      'order_index': orderIndex,
    };
  }

  /// Converts this model into a map including explicit [id].
  Map<String, dynamic> toMapWithId() {
    return {
      'id': id,
      'parent_id': parentId,
      'title': title,
      'order_index': orderIndex,
    };
  }

  /// Converts this data model to the domain [SubCategory] entity.
  SubCategory toEntity() {
    return SubCategory(
      id: id,
      parentId: parentId,
      title: title,
      orderIndex: orderIndex,
      dhikrCount: dhikrCount,
      parentName: parentName,
    );
  }

  /// Factory creating a model from a domain [SubCategory] entity.
  factory SubCategoryModel.fromEntity(SubCategory entity) {
    return SubCategoryModel(
      id: entity.id,
      parentId: entity.parentId,
      title: entity.title,
      orderIndex: entity.orderIndex,
      dhikrCount: entity.dhikrCount,
      parentName: entity.parentName,
    );
  }
}
