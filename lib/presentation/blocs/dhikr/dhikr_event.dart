import 'package:equatable/equatable.dart';

import '../../../domain/entities/sub_category.dart';

/// Base class for all [DhikrBloc] events.
sealed class DhikrEvent extends Equatable {
  const DhikrEvent();

  @override
  List<Object?> get props => [];
}

/// Loads chapter details and associated Dhikr items from SQLite.
final class LoadDhikrList extends DhikrEvent {
  final int subCategoryId;
  final int initialIndex;
  final int? targetDhikrId;
  final SubCategory? subCategory;

  const LoadDhikrList(
    this.subCategoryId, {
    this.initialIndex = 0,
    this.targetDhikrId,
    this.subCategory,
  });

  /// Backward-compatible alias
  int get categoryId => subCategoryId;

  @override
  List<Object?> get props => [subCategoryId, initialIndex, targetDhikrId, subCategory];
}

/// Increments the repetition counter for the active Dhikr item by 1.
final class IncrementCounter extends DhikrEvent {
  const IncrementCounter();
}

/// Resets the current reading session back to the first Dhikr with 0 counter.
final class ResetDhikrSession extends DhikrEvent {
  const ResetDhikrSession();
}

/// Navigates to the previous Dhikr item in the sequence.
final class PreviousDhikr extends DhikrEvent {
  const PreviousDhikr();
}

/// Skips or advances to the next Dhikr item in the sequence manually.
final class NextDhikr extends DhikrEvent {
  const NextDhikr();
}

/// Jumps directly to the Dhikr item at [index].
final class JumpToDhikr extends DhikrEvent {
  final int index;

  const JumpToDhikr(this.index);

  @override
  List<Object?> get props => [index];
}
