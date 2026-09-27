import 'package:equatable/equatable.dart';

import '../../../domain/entities/category_completion_stat.dart';
import '../../../domain/entities/weekly_day_matrix.dart';

/// Base state for Dhikr statistics.
sealed class StatsState extends Equatable {
  const StatsState();

  @override
  List<Object?> get props => [];
}

/// Initial uninitialized state.
final class StatsInitial extends StatsState {
  const StatsInitial();
}

/// Loading state while querying SQLite.
final class StatsLoading extends StatsState {
  const StatsLoading();
}

/// Successfully loaded statistics data.
final class StatsLoaded extends StatsState {
  /// Consecutive days streak ending today.
  final int currentStreak;

  /// All-time record streak in days.
  final int longestStreak;

  /// Total number of completed Dhikr sessions.
  final int totalCompletions;

  /// Total number of distinct sub-categories completed at least once.
  final int totalCompletedSubCategories;

  /// Active day completion rate percentage (0.0% to 100.0%).
  final double activeDayRate;

  /// Top most completed sub-categories (ranked 1st, 2nd, 3rd).
  final List<CategoryCompletionStat> topSubCategories;

  /// 7-day Arabic week matrix (Saturday to Friday) with statuses.
  final List<WeeklyDayData> weeklyMatrix;

  /// Map of {YYYY-MM-DD: completionCount} for the last 30 days.
  final Map<String, int> heatmap;

  const StatsLoaded({
    required this.currentStreak,
    required this.longestStreak,
    required this.totalCompletions,
    this.totalCompletedSubCategories = 0,
    this.activeDayRate = 0.0,
    this.topSubCategories = const [],
    this.weeklyMatrix = const [],
    required this.heatmap,
  });

  @override
  List<Object?> get props => [
        currentStreak,
        longestStreak,
        totalCompletions,
        totalCompletedSubCategories,
        activeDayRate,
        topSubCategories,
        weeklyMatrix,
        heatmap,
      ];
}

/// Error state if statistics queries fail.
final class StatsError extends StatsState {
  final String message;

  const StatsError(this.message);

  @override
  List<Object?> get props => [message];
}
