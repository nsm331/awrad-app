import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/dhikr_repository.dart' show Success, Err;
import '../../../domain/repositories/statistics_repository.dart';
import 'stats_state.dart';

/// Cubit responsible for aggregating and loading streak & completion statistics.
class StatsCubit extends Cubit<StatsState> {
  final StatisticsRepository _repository;

  StatsCubit(this._repository) : super(const StatsInitial());

  /// Loads current streak, longest streak, total completions, and heatmap data.
  Future<void> loadStats() async {
    emit(const StatsLoading());

    final currentStreakResult = await _repository.getCurrentStreak();
    final longestStreakResult = await _repository.getLongestStreak();
    final totalCompletionsResult = await _repository.getTotalCompletions();
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

    final heatmap = switch (heatmapResult) {
      Success(data: final m) => m,
      Err() => <String, int>{},
    };

    emit(StatsLoaded(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      totalCompletions: totalCompletions,
      heatmap: heatmap,
    ));
  }
}
