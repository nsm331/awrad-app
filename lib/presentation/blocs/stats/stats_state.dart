import 'package:equatable/equatable.dart';

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

  /// Map of {YYYY-MM-DD: completionCount} for the last 30 days.
  final Map<String, int> heatmap;

  const StatsLoaded({
    required this.currentStreak,
    required this.longestStreak,
    required this.totalCompletions,
    required this.heatmap,
  });

  @override
  List<Object?> get props => [
        currentStreak,
        longestStreak,
        totalCompletions,
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
