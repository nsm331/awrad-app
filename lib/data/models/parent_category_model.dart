/// SQLite data model for [ParentCategory].
library;

import '../../core/constants/app_constants.dart';
import '../../domain/entities/parent_category.dart';

/// SQLite data model representing the `parent_categories` table.
class ParentCategoryModel {
  final int id;
  final String name;
  final String? iconName;
  final int orderIndex;
  final int subCategoryCount;
  final int totalDhikrCount;

  const ParentCategoryModel({
    required this.id,
    required this.name,
    this.iconName,
    this.orderIndex = 0,
    this.subCategoryCount = 0,
    this.totalDhikrCount = 0,
  });

  /// DDL string to create the `parent_categories` table in SQLite.
  static const String createTableSql = '''
    CREATE TABLE ${DatabaseConstants.parentCategoriesTable} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      icon_name TEXT,
      order_index INTEGER
    )
  ''';

  /// Converts a SQLite row map into a [ParentCategoryModel].
  factory ParentCategoryModel.fromMap(Map<String, dynamic> map) {
    return ParentCategoryModel(
      id: map['id'] as int,
      name: map['name'] as String,
      iconName: map['icon_name'] as String?,
      orderIndex: (map['order_index'] as int?) ?? 0,
      subCategoryCount: (map['sub_category_count'] as int?) ?? 0,
      totalDhikrCount: (map['total_dhikr_count'] as int?) ?? 0,
    );
  }

  /// Converts this model into a map for SQLite insert/update.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'icon_name': iconName,
      'order_index': orderIndex,
    };
  }

  /// Converts this model into a map including the explicit [id].
  Map<String, dynamic> toMapWithId() {
    return {
      'id': id,
      'name': name,
      'icon_name': iconName,
      'order_index': orderIndex,
    };
  }

  /// Converts this data model to the domain [ParentCategory] entity.
  ParentCategory toEntity() {
    return ParentCategory(
      id: id,
      name: name,
      iconName: iconName ?? 'category',
      orderIndex: orderIndex,
      subCategoryCount: subCategoryCount,
      totalDhikrCount: totalDhikrCount,
    );
  }

  /// Factory creating a model from a domain [ParentCategory] entity.
  factory ParentCategoryModel.fromEntity(ParentCategory entity) {
    return ParentCategoryModel(
      id: entity.id,
      name: entity.name,
      iconName: entity.iconName,
      orderIndex: entity.orderIndex,
      subCategoryCount: entity.subCategoryCount,
      totalDhikrCount: entity.totalDhikrCount,
    );
  }
}
