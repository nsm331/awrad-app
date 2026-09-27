/// Concrete SQLite-backed implementation of [StatisticsRepository].
///
/// Implements unbroken consecutive-day streak calculation, 7-day weekly
/// completion matrix, and completion logging for [SubCategory] chapters.
library;

import 'dart:developer' as developer;

import 'package:sqflite/sqflite.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/category_completion_stat.dart';
import '../../domain/entities/completion_log.dart';
import '../../domain/entities/weekly_day_matrix.dart';
import '../../domain/repositories/dhikr_repository.dart' show Result, Success, Err;
import '../../domain/repositories/statistics_repository.dart';
import '../datasources/local/database_helper.dart';
import '../models/completion_log_model.dart';

/// SQLite implementation of [StatisticsRepository].
class StatisticsRepositoryImpl implements StatisticsRepository {
  final DatabaseHelper _dbHelper;

  StatisticsRepositoryImpl({
    DatabaseHelper? dbHelper,
  }) : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<Database> get _db => _dbHelper.database;

  // ── Helpers ────────────────────────────────────────────────────────────────

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static String _formatDate(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  // ── CompletionLog CRUD ──────────────────────────────────────────────────────

  @override
  Future<Result<List<CompletionLog>>> getAllCompletionLogs() async {
    try {
      final db = await _db;
      final rows = await db.query(
        DatabaseConstants.completionLogsTable,
        orderBy: 'completed_date DESC, id DESC',
      );
      final logs = rows
          .map((row) => CompletionLogModel.fromMap(row).toEntity())
          .toList(growable: false);
      return Success(logs);
    } catch (e, st) {
      developer.log('getAllCompletionLogs failed: $e', name: 'StatisticsRepositoryImpl', error: e, stackTrace: st);
      return Err(const DatabaseReadFailure('Failed to load completion logs.'));
    }
  }

  @override
  Future<Result<List<CompletionLog>>> getCompletionLogsBySubCategory(int subCategoryId) async {
    try {
      final db = await _db;
      final rows = await db.query(
        DatabaseConstants.completionLogsTable,
        where: 'sub_category_id = ?',
        whereArgs: [subCategoryId],
        orderBy: 'completed_date DESC',
      );
      final logs = rows
          .map((row) => CompletionLogModel.fromMap(row).toEntity())
          .toList(growable: false);
      return Success(logs);
    } catch (e, st) {
      developer.log('getCompletionLogsBySubCategory failed: $e', name: 'StatisticsRepositoryImpl', error: e, stackTrace: st);
      return Err(const DatabaseReadFailure());
    }
  }

  @override
  Future<Result<List<CompletionLog>>> getCompletionLogsByCategory(int categoryId) {
    return getCompletionLogsBySubCategory(categoryId);
  }

  @override
  Future<Result<List<CompletionLog>>> getCompletionLogsInRange({
    required String from,
    required String to,
  }) async {
    try {
      final db = await _db;
      final rows = await db.query(
        DatabaseConstants.completionLogsTable,
        where: 'completed_date >= ? AND completed_date <= ?',
        whereArgs: [from, to],
        orderBy: 'completed_date DESC',
      );
      final logs = rows
          .map((row) => CompletionLogModel.fromMap(row).toEntity())
          .toList(growable: false);
      return Success(logs);
    } catch (e, st) {
      developer.log('getCompletionLogsInRange failed: $e', name: 'StatisticsRepositoryImpl', error: e, stackTrace: st);
      return Err(const DatabaseReadFailure());
    }
  }

  @override
  Future<Result<int>> logCompletion({
    required int subCategoryId,
    required String completedDate,
    bool isStreakEligible = true,
  }) async {
    try {
      final db = await _db;
      final newId = await db.insert(
        DatabaseConstants.completionLogsTable,
        {
          'sub_category_id': subCategoryId,
          'completed_date': completedDate,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      return Success(newId);
    } catch (e, st) {
      developer.log('logCompletion failed: $e', name: 'StatisticsRepositoryImpl', error: e, stackTrace: st);
      return Err(const DatabaseWriteFailure('Failed to record completion.'));
    }
  }

  @override
  Future<Result<bool>> isCompletedToday(int subCategoryId) async {
    try {
      final db = await _db;
      final todayStr = _formatDate(DateTime.now());
      final count = Sqflite.firstIntValue(
        await db.rawQuery(
          'SELECT COUNT(*) FROM ${DatabaseConstants.completionLogsTable} WHERE sub_category_id = ? AND completed_date = ?',
          [subCategoryId, todayStr],
        ),
      ) ?? 0;
      return Success(count > 0);
    } catch (e, st) {
      developer.log('isCompletedToday failed: $e', name: 'StatisticsRepositoryImpl', error: e, stackTrace: st);
      return const Success(false);
    }
  }

  @override
  Future<Result<int>> deleteCompletionLog(int id) async {
    try {
      final db = await _db;
      final affected = await db.delete(
        DatabaseConstants.completionLogsTable,
        where: 'id = ?',
        whereArgs: [id],
      );
      return Success(affected);
    } catch (e, st) {
      developer.log('deleteCompletionLog failed: $e', name: 'StatisticsRepositoryImpl', error: e, stackTrace: st);
      return Err(const DatabaseWriteFailure('Failed to delete completion log.'));
    }
  }

  // ── Aggregation ─────────────────────────────────────────────────────────────

  @override
  Future<Result<int>> getCurrentStreak() async {
    try {
      final db = await _db;
      final rows = await db.rawQuery('''
        SELECT DISTINCT completed_date
        FROM ${DatabaseConstants.completionLogsTable}
        ORDER BY completed_date DESC
      ''');

      if (rows.isEmpty) return const Success(0);

      final completedDates = rows
          .map((r) => r['completed_date'] as String)
          .toSet();

      final today = _today();
      final todayStr = _formatDate(today);
      final yesterdayStr = _formatDate(today.subtract(const Duration(days: 1)));

      // Determine where the streak starts (today or yesterday)
      DateTime currentCheck;
      if (completedDates.contains(todayStr)) {
        currentCheck = today;
      } else if (completedDates.contains(yesterdayStr)) {
        currentCheck = today.subtract(const Duration(days: 1));
      } else {
        // No completion today or yesterday -> streak broken
        return const Success(0);
      }

      int streak = 0;
      while (completedDates.contains(_formatDate(currentCheck))) {
        streak++;
        currentCheck = currentCheck.subtract(const Duration(days: 1));
      }

      return Success(streak);
    } catch (e, st) {
      developer.log('getCurrentStreak failed: $e', name: 'StatisticsRepositoryImpl', error: e, stackTrace: st);
      return const Success(0);
    }
  }

  @override
  Future<Result<int>> getLongestStreak() async {
    try {
      final db = await _db;
      final rows = await db.rawQuery('''
        SELECT DISTINCT completed_date
        FROM ${DatabaseConstants.completionLogsTable}
        ORDER BY completed_date ASC
      ''');

      if (rows.isEmpty) return const Success(0);

      final dates = rows
          .map((r) => DateTime.parse(r['completed_date'] as String))
          .map((d) => DateTime(d.year, d.month, d.day))
          .toList(growable: false);

      int maxStreak = 1;
      int currentStreak = 1;

      for (int i = 1; i < dates.length; i++) {
        final diff = dates[i].difference(dates[i - 1]).inDays;
        if (diff == 1) {
          currentStreak++;
          if (currentStreak > maxStreak) {
            maxStreak = currentStreak;
          }
        } else if (diff > 1) {
          currentStreak = 1;
        }
      }

      return Success(maxStreak);
    } catch (e, st) {
      developer.log('getLongestStreak failed: $e', name: 'StatisticsRepositoryImpl', error: e, stackTrace: st);
      return const Success(0);
    }
  }

  @override
  Future<Result<int>> getTotalCompletions() async {
    try {
      final db = await _db;
      final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM ${DatabaseConstants.completionLogsTable}'),
      ) ?? 0;
      return Success(count);
    } catch (e, st) {
      developer.log('getTotalCompletions failed: $e', name: 'StatisticsRepositoryImpl', error: e, stackTrace: st);
      return const Success(0);
    }
  }

  @override
  Future<Result<int>> getTotalCompletedSubCategoriesCount() async {
    try {
      final db = await _db;
      final count = Sqflite.firstIntValue(
        await db.rawQuery(
          'SELECT COUNT(DISTINCT sub_category_id) FROM ${DatabaseConstants.completionLogsTable}',
        ),
      ) ?? 0;
      return Success(count);
    } catch (e, st) {
      developer.log('getTotalCompletedSubCategoriesCount failed: $e', name: 'StatisticsRepositoryImpl', error: e, stackTrace: st);
      return const Success(0);
    }
  }

  @override
  Future<Result<List<CategoryCompletionStat>>> getMostCompletedSubCategories({int limit = 3}) async {
    try {
      final db = await _db;
      final rows = await db.rawQuery('''
        SELECT sc.id as sub_category_id, sc.title as title, COUNT(cl.id) as completion_count
        FROM ${DatabaseConstants.subCategoriesTable} sc
        JOIN ${DatabaseConstants.completionLogsTable} cl ON sc.id = cl.sub_category_id
        GROUP BY sc.id, sc.title
        ORDER BY completion_count DESC, sc.id ASC
        LIMIT ?
      ''', [limit]);

      final stats = rows.map((r) => CategoryCompletionStat(
        subCategoryId: r['sub_category_id'] as int,
        title: r['title'] as String,
        completionCount: (r['completion_count'] as int?) ?? 0,
      )).toList(growable: false);

      return Success(stats);
    } catch (e, st) {
      developer.log('getMostCompletedSubCategories failed: $e', name: 'StatisticsRepositoryImpl', error: e, stackTrace: st);
      return const Success([]);
    }
  }

  static const _arabicDayNames = [
    'السبت',
    'الأحد',
    'الإثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
  ];

  @override
  Future<Result<List<WeeklyDayData>>> getWeeklyMatrix() async {
    try {
      final db = await _db;
      final today = _today();

      // Arabic week starts on Saturday and ends on Friday
      int daysSinceSaturday;
      if (today.weekday == DateTime.saturday) {
        daysSinceSaturday = 0;
      } else if (today.weekday == DateTime.sunday) {
        daysSinceSaturday = 1;
      } else {
        daysSinceSaturday = today.weekday + 1;
      }

      final saturday = today.subtract(Duration(days: daysSinceSaturday));
      final friday = saturday.add(const Duration(days: 6));
      final startStr = _formatDate(saturday);
      final endStr = _formatDate(friday);

      final rows = await db.rawQuery('''
        SELECT completed_date, COUNT(*) as cnt
        FROM ${DatabaseConstants.completionLogsTable}
        WHERE completed_date >= ? AND completed_date <= ?
        GROUP BY completed_date
      ''', [startStr, endStr]);

      final countMap = <String, int>{};
      for (final r in rows) {
        countMap[r['completed_date'] as String] = (r['cnt'] as int?) ?? 0;
      }

      final List<WeeklyDayData> matrix = [];
      for (int i = 0; i < 7; i++) {
        final date = saturday.add(Duration(days: i));
        final dateStr = _formatDate(date);
        final count = countMap[dateStr] ?? 0;
        final isToday = date.isAtSameMomentAs(today);
        final isFuture = date.isAfter(today);

        final WeeklyDayStatus status;
        if (isFuture) {
          status = WeeklyDayStatus.future;
        } else if (count > 0) {
          status = WeeklyDayStatus.completed;
        } else if (isToday) {
          status = WeeklyDayStatus.incomplete;
        } else {
          status = WeeklyDayStatus.missed;
        }

        matrix.add(WeeklyDayData(
          date: date,
          dayName: _arabicDayNames[i],
          dateLabel: '${date.day}/${date.month}',
          count: count,
          status: status,
          isToday: isToday,
        ));
      }

      return Success(matrix);
    } catch (e, st) {
      developer.log('getWeeklyMatrix failed: $e', name: 'StatisticsRepositoryImpl', error: e, stackTrace: st);
      return const Success([]);
    }
  }

  @override
  Future<Result<double>> getActiveDayRate({int days = 30}) async {
    try {
      final db = await _db;
      final today = _today();
      final startDate = today.subtract(Duration(days: days - 1));
      final startStr = _formatDate(startDate);
      final endStr = _formatDate(today);

      final activeDaysCount = Sqflite.firstIntValue(
        await db.rawQuery('''
          SELECT COUNT(DISTINCT completed_date)
          FROM ${DatabaseConstants.completionLogsTable}
          WHERE completed_date >= ? AND completed_date <= ?
        ''', [startStr, endStr]),
      ) ?? 0;

      if (activeDaysCount == 0) {
        return const Success(0.0);
      }

      // Check earliest log to avoid penalising brand new users
      final earliestRow = await db.rawQuery('''
        SELECT MIN(completed_date) as first_date
        FROM ${DatabaseConstants.completionLogsTable}
      ''');
      int totalDays = days;
      if (earliestRow.isNotEmpty && earliestRow.first['first_date'] != null) {
        final firstDate = DateTime.tryParse(earliestRow.first['first_date'] as String);
        if (firstDate != null) {
          final daysSinceFirst = today.difference(DateTime(firstDate.year, firstDate.month, firstDate.day)).inDays + 1;
          if (daysSinceFirst > 0 && daysSinceFirst < days) {
            totalDays = daysSinceFirst;
          }
        }
      }

      final rate = ((activeDaysCount / totalDays) * 100.0).clamp(0.0, 100.0);
      return Success(double.parse(rate.toStringAsFixed(1)));
    } catch (e, st) {
      developer.log('getActiveDayRate failed: $e', name: 'StatisticsRepositoryImpl', error: e, stackTrace: st);
      return const Success(0.0);
    }
  }

  @override
  Future<Result<Map<String, int>>> getWeeklyCompletions() async {
    try {
      final db = await _db;
      final today = _today();
      final startDate = today.subtract(const Duration(days: 6));
      final startStr = _formatDate(startDate);
      final endStr = _formatDate(today);

      final rows = await db.rawQuery('''
        SELECT completed_date, COUNT(*) as cnt
        FROM ${DatabaseConstants.completionLogsTable}
        WHERE completed_date >= ? AND completed_date <= ?
        GROUP BY completed_date
      ''', [startStr, endStr]);

      final countMap = <String, int>{};
      for (final r in rows) {
        countMap[r['completed_date'] as String] = (r['cnt'] as int?) ?? 0;
      }

      // Populate full 7-day range (from 6 days ago up to today)
      final resultMap = <String, int>{};
      for (int i = 6; i >= 0; i--) {
        final dStr = _formatDate(today.subtract(Duration(days: i)));
        resultMap[dStr] = countMap[dStr] ?? 0;
      }

      return Success(resultMap);
    } catch (e, st) {
      developer.log('getWeeklyCompletions failed: $e', name: 'StatisticsRepositoryImpl', error: e, stackTrace: st);
      return const Success({});
    }
  }

  @override
  Future<Result<Map<String, int>>> getCompletionHeatmap({int days = 30}) async {
    try {
      final db = await _db;
      final today = _today();
      final startDate = today.subtract(Duration(days: days - 1));
      final startStr = _formatDate(startDate);
      final endStr = _formatDate(today);

      final rows = await db.rawQuery('''
        SELECT completed_date, COUNT(*) as cnt
        FROM ${DatabaseConstants.completionLogsTable}
        WHERE completed_date >= ? AND completed_date <= ?
        GROUP BY completed_date
      ''', [startStr, endStr]);

      final countMap = <String, int>{};
      for (final r in rows) {
        countMap[r['completed_date'] as String] = (r['cnt'] as int?) ?? 0;
      }

      final resultMap = <String, int>{};
      for (int i = days - 1; i >= 0; i--) {
        final dStr = _formatDate(today.subtract(Duration(days: i)));
        resultMap[dStr] = countMap[dStr] ?? 0;
      }

      return Success(resultMap);
    } catch (e, st) {
      developer.log('getCompletionHeatmap failed: $e', name: 'StatisticsRepositoryImpl', error: e, stackTrace: st);
      return const Success({});
    }
  }
}
