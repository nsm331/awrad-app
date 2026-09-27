import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/category_completion_stat.dart';
import '../../../domain/entities/weekly_day_matrix.dart';
import '../../../domain/repositories/dhikr_repository.dart' show Success, Err;
import '../../../domain/repositories/statistics_repository.dart';
import 'stats_state.dart';

/// Cubit responsible for aggregating and loading streak & completion statistics.
class StatsCubit extends Cubit<StatsState> {
  final StatisticsRepository _repository;

  StatsCubit(this._repository) : super(const StatsInitial());

  /// Loads current streak, longest streak, total completions, weekly matrix, and heatmap data.
  Future<void> loadStats() async {
    emit(const StatsLoading());

    final currentStreakResult = await _repository.getCurrentStreak();
    final longestStreakResult = await _repository.getLongestStreak();
    final totalCompletionsResult = await _repository.getTotalCompletions();
    final totalSubCategoriesResult = await _repository.getTotalCompletedSubCategoriesCount();
    final activeRateResult = await _repository.getActiveDayRate(days: 30);
    final topSubCategoriesResult = await _repository.getMostCompletedSubCategories(limit: 3);
    final weeklyMatrixResult = await _repository.getWeeklyMatrix();
    final heatmapResult = await _repository.getCompletionHeatmap(days: 30);

    final currentStreak = switch (currentStreakResult) {
      Success(data: final v) => v,
      Err() => 0,
    };

    final longestStreak = switch (longestStreakResult) {
      Success(data: final v) => v,
      Err() => 0,
    };

    final totalCompletions = switch (totalCompletionsResult) {
      Success(data: final v) => v,
      Err() => 0,
    };

    final totalCompletedSubCategories = switch (totalSubCategoriesResult) {
      Success(data: final v) => v,
      Err() => 0,
    };

    final activeDayRate = switch (activeRateResult) {
      Success(data: final v) => v,
      Err() => 0.0,
    };

    final topSubCategories = switch (topSubCategoriesResult) {
      Success(data: final list) => list,
      Err() => const <CategoryCompletionStat>[],
    };

    final weeklyMatrix = switch (weeklyMatrixResult) {
      Success(data: final list) => list,
      Err() => const <WeeklyDayData>[],
    };

    final heatmap = switch (heatmapResult) {
      Success(data: final m) => m,
      Err() => <String, int>{},
    };

    emit(StatsLoaded(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      totalCompletions: totalCompletions,
      totalCompletedSubCategories: totalCompletedSubCategories,
      activeDayRate: activeDayRate,
      topSubCategories: topSubCategories,
      weeklyMatrix: weeklyMatrix,
      heatmap: heatmap,
    ));
  }
}
