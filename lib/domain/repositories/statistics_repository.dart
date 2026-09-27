/// Abstract contract for the Statistics repository.
///
/// Manages [CompletionLog] persistence and exposes streak and weekly
/// completion metrics used by the statistics presentation layer.
library;

import '../entities/completion_log.dart';
import 'dhikr_repository.dart' show Result;

/// Contract for completion-log and statistics data operations (100% offline).
abstract class StatisticsRepository {
  // ── CompletionLog CRUD ────────────────────────────────────────────────────

  /// Returns all [CompletionLog] entries, newest first.
  Future<Result<List<CompletionLog>>> getAllCompletionLogs();

  /// Returns all [CompletionLog] entries for the given [subCategoryId], newest first.
  Future<Result<List<CompletionLog>>> getCompletionLogsBySubCategory(int subCategoryId);

  /// Returns [CompletionLog] entries for a date range [from]–[to] (inclusive),
  /// formatted as YYYY-MM-DD.
  Future<Result<List<CompletionLog>>> getCompletionLogsInRange({
    required String from,
    required String to,
  });

  /// Records a new completion event for [subCategoryId] on [completedDate] (YYYY-MM-DD).
  Future<Result<int>> logCompletion({
    required int subCategoryId,
    required String completedDate,
    bool isStreakEligible = true,
  });

  /// Checks if a given [subCategoryId] was completed today.
  Future<Result<bool>> isCompletedToday(int subCategoryId);

  /// Deletes the [CompletionLog] with the given [id].
  Future<Result<int>> deleteCompletionLog(int id);

  // ── Aggregation queries ───────────────────────────────────────────────────

  /// Returns the user's current unbroken consecutive-day streak.
  Future<Result<int>> getCurrentStreak();

  /// Returns the user's all-time longest streak in days.
  Future<Result<int>> getLongestStreak();

  /// Returns the total number of completed sessions across all chapters.
  Future<Result<int>> getTotalCompletions();

  /// Returns a map of YYYY-MM-DD -> completionCount for the 7 days of the current week.
  Future<Result<Map<String, int>>> getWeeklyCompletions();

  /// Returns a map of YYYY-MM-DD -> completionCount for the last [days] days.
  Future<Result<Map<String, int>>> getCompletionHeatmap({int days = 30});

  // ── Backward-compatible Aliases ───────────────────────────────────────────

  /// Legacy alias for [getCompletionLogsBySubCategory].
  Future<Result<List<CompletionLog>>> getCompletionLogsByCategory(int categoryId);
}
