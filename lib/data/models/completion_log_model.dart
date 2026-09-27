/// SQLite-backed data model for [CompletionLog].
///
/// Handles serialisation/deserialisation to and from the `completion_logs`
/// table row map and converts to the domain [CompletionLog] entity.
library;

import '../../core/constants/app_constants.dart';
import '../../domain/entities/completion_log.dart';

/// Data-layer representation of a completion log row in the SQLite database.
class CompletionLogModel {
  final int id;
  final int subCategoryId;

  /// ISO 8601 date string in YYYY-MM-DD format (local device date).
  final String completedDate;

  /// Whether this completion counts towards the user's daily streak.
  final bool isStreakEligible;

  const CompletionLogModel({
    required this.id,
    required this.subCategoryId,
    required this.completedDate,
    this.isStreakEligible = true,
  });

  /// Legacy alias for [subCategoryId].
  int get categoryId => subCategoryId;

  // ── Factory constructors ──────────────────────────────────────────────────

  /// Constructs a [CompletionLogModel] from a sqflite row map.
  factory CompletionLogModel.fromMap(Map<String, dynamic> map) {
    return CompletionLogModel(
      id: map['id'] as int,
      subCategoryId: (map['sub_category_id'] ?? map['category_id']) as int,
      completedDate: map['completed_date'] as String,
      isStreakEligible: ((map['is_streak_eligible'] as int?) ?? 1) == 1,
    );
  }

  // ── Serialisation ─────────────────────────────────────────────────────────

  /// Returns a map suitable for sqflite insert/update (without [id]).
  Map<String, dynamic> toMap() {
    return {
      'sub_category_id': subCategoryId,
      'completed_date': completedDate,
    };
  }

  /// Returns the full map including [id] — use for updates.
  Map<String, dynamic> toMapWithId() {
    return {
      'id': id,
      'sub_category_id': subCategoryId,
      'completed_date': completedDate,
    };
  }

  // ── Domain conversion ─────────────────────────────────────────────────────

  /// Converts this data model to the domain [CompletionLog] entity.
  CompletionLog toEntity() {
    return CompletionLog(
      id: id,
      subCategoryId: subCategoryId,
      completedDate: completedDate,
      isStreakEligible: isStreakEligible,
    );
  }

  // ── Static helpers ────────────────────────────────────────────────────────

  /// SQL CREATE TABLE statement for the `completion_logs` table.
  static const String createTableSql = '''
    CREATE TABLE ${DatabaseConstants.completionLogsTable} (
      id              INTEGER PRIMARY KEY AUTOINCREMENT,
      sub_category_id INTEGER NOT NULL,
      completed_date  TEXT NOT NULL,
      UNIQUE(sub_category_id, completed_date)
    )
  ''';

  @override
  String toString() =>
      'CompletionLogModel(id: $id, subCategoryId: $subCategoryId, date: $completedDate)';
}
