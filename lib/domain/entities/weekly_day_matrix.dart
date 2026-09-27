import 'package:equatable/equatable.dart';

/// Completion status for a specific day in the 7-day Arabic week matrix.
enum WeeklyDayStatus {
  /// At least one Dhikr session was completed on this day.
  completed,

  /// Today, where no Dhikr session has been completed yet.
  incomplete,

  /// A past day in the current week with zero completed Dhikr sessions.
  missed,

  /// A future day in the current week that hasn't arrived yet.
  future,
}

/// Represents a single day in the 7-day Arabic week (Saturday to Friday).
class WeeklyDayData extends Equatable {
  /// The date of this day (without time component).
  final DateTime date;

  /// The Arabic day name (e.g. 'السبت', 'الأحد', ..., 'الجمعة').
  final String dayName;

  /// Compact formatted date label (e.g. '27/9').
  final String dateLabel;

  /// Total completed Dhikr sessions on this date.
  final int count;

  /// Visual status for this day (completed, incomplete, missed, or future).
  final WeeklyDayStatus status;

  /// Whether this day corresponds to today.
  final bool isToday;

  const WeeklyDayData({
    required this.date,
    required this.dayName,
    required this.dateLabel,
    required this.count,
    required this.status,
    required this.isToday,
  });

  @override
  List<Object?> get props => [date, dayName, dateLabel, count, status, isToday];
}
