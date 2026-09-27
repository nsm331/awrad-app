/// SQLite-backed data model for [DhikrItem].
///
/// Handles serialisation/deserialisation to and from the `dhikr_items`
/// table row map and converts to the domain [DhikrItem] entity.
library;

import '../../core/constants/app_constants.dart';
import '../../domain/entities/dhikr_item.dart';

/// Data-layer representation of a Dhikr item row in the SQLite database.
class DhikrItemModel {
  final int id;
  final int subCategoryId;
  final String content;
  final String footnote;
  final String fadl;
  final String source;
  final int repeatCount;
  final int orderIndex;
  final String subCategoryTitle;

  const DhikrItemModel({
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

  // ── Backward-compatible getters ─────────────────────────────────────────────

  int get categoryId => subCategoryId;
  String get subCategory => subCategoryTitle;

  // ── Factory constructors ──────────────────────────────────────────────────

  /// Constructs a [DhikrItemModel] from a sqflite row map.
  factory DhikrItemModel.fromMap(Map<String, dynamic> map) {
    return DhikrItemModel(
      id: map['id'] as int,
      subCategoryId: (map['sub_category_id'] ?? map['category_id']) as int,
      content: map['content'] as String,
      footnote: (map['footnote'] ?? map['source'] ?? '') as String,
      fadl: (map['fadl'] ?? '') as String,
      source: (map['source'] ?? '') as String,
      repeatCount: (map['repeat_count'] as int?) ?? 1,
      orderIndex: (map['order_index'] as int?) ?? 0,
      subCategoryTitle: (map['sub_category_title'] ?? map['sub_category'] ?? '') as String,
    );
  }

  // ── Serialisation ─────────────────────────────────────────────────────────

  /// Returns a map suitable for sqflite insert/update (without [id]).
  Map<String, dynamic> toMap() {
    return {
      'sub_category_id': subCategoryId,
      'content': content,
      'footnote': footnote,
      'fadl': fadl,
      'source': source,
      'repeat_count': repeatCount,
      'order_index': orderIndex,
    };
  }

  /// Returns the full map including [id] — use for upsert / conflict replace.
  Map<String, dynamic> toMapWithId() {
    return {
      'id': id,
      'sub_category_id': subCategoryId,
      'content': content,
      'footnote': footnote,
      'fadl': fadl,
      'source': source,
      'repeat_count': repeatCount,
      'order_index': orderIndex,
    };
  }

  // ── Domain conversion ─────────────────────────────────────────────────────

  /// Converts this data model to the domain [DhikrItem] entity.
  DhikrItem toEntity() {
    return DhikrItem(
      id: id,
      subCategoryId: subCategoryId,
      content: content,
      footnote: footnote,
      fadl: fadl,
      source: source,
      repeatCount: repeatCount,
      orderIndex: orderIndex,
      subCategoryTitle: subCategoryTitle,
    );
  }

  /// Factory creating a model from a domain [DhikrItem] entity.
  factory DhikrItemModel.fromEntity(DhikrItem entity) {
    return DhikrItemModel(
      id: entity.id,
      subCategoryId: entity.subCategoryId,
      content: entity.content,
      footnote: entity.footnote,
      fadl: entity.fadl,
      source: entity.source,
      repeatCount: entity.repeatCount,
      orderIndex: entity.orderIndex,
      subCategoryTitle: entity.subCategoryTitle,
    );
  }

  // ── Static helpers ────────────────────────────────────────────────────────

  /// SQL CREATE TABLE statement for the `dhikr_items` table.
  static const String createTableSql = '''
    CREATE TABLE ${DatabaseConstants.dhikrItemsTable} (
      id              INTEGER PRIMARY KEY AUTOINCREMENT,
      sub_category_id INTEGER NOT NULL,
      content         TEXT NOT NULL,
      footnote        TEXT,
      fadl            TEXT,
      source          TEXT,
      repeat_count    INTEGER DEFAULT 1,
      order_index     INTEGER,
      FOREIGN KEY (sub_category_id) REFERENCES ${DatabaseConstants.subCategoriesTable} (id) ON DELETE CASCADE
    )
  ''';

  @override
  String toString() =>
      'DhikrItemModel(id: $id, subCategoryId: $subCategoryId, repeat: $repeatCount)';
}
