/// Domain entity representing a completion log entry.
///
/// One log entry is created per completed chapter session (when the user
/// completes all items in a [SubCategory]). The [completedDate] string (YYYY-MM-DD)
/// enables robust daily streak calculation.
library;

import 'package:equatable/equatable.dart';

/// Records that the user completed a full chapter session on a given date.
class CompletionLog extends Equatable {
  /// Unique, auto-assigned SQLite row ID.
  final int id;

  /// Foreign key referencing [SubCategory.id].
  final int subCategoryId;

  /// ISO date string in **YYYY-MM-DD** format (local device date).
  final String completedDate;

  /// Whether this completion counts towards the user's daily streak.
  final bool isStreakEligible;

  const CompletionLog({
    required this.id,
    required this.subCategoryId,
    required this.completedDate,
    this.isStreakEligible = true,
  });

  /// Legacy alias for [subCategoryId].
  int get categoryId => subCategoryId;

  @override
  List<Object?> get props => [
        id,
        subCategoryId,
        completedDate,
        isStreakEligible,
      ];

  @override
  String toString() =>
      'CompletionLog(id: $id, subCategoryId: $subCategoryId, date: $completedDate)';
}
