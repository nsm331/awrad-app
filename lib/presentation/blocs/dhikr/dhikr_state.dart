import 'package:equatable/equatable.dart';

import '../../../domain/entities/parent_category.dart';
import '../../../domain/entities/sub_category.dart';
import '../../../domain/entities/dhikr_item.dart';

/// Status of the active Dhikr session.
enum DhikrStatus {
  initial,
  loading,
  loaded,
  completed,
  error,
}

/// State of the Dhikr reading and counting engine.
class DhikrState extends Equatable {
  final DhikrStatus status;
  final ParentCategory? category;
  final SubCategory? subCategory;
  final List<DhikrItem> items;
  final int currentDhikrIndex;
  final int currentCounter;
  final bool isSetCompleted;
  final bool justCompletedItem;
  final String? errorMessage;

  const DhikrState({
    this.status = DhikrStatus.initial,
    this.category,
    this.subCategory,
    this.items = const [],
    this.currentDhikrIndex = 0,
    this.currentCounter = 0,
    this.isSetCompleted = false,
    this.justCompletedItem = false,
    this.errorMessage,
  });

  /// The active [DhikrItem] currently displayed on screen.
  DhikrItem? get currentItem {
    if (items.isEmpty || currentDhikrIndex < 0 || currentDhikrIndex >= items.length) {
      return null;
    }
    return items[currentDhikrIndex];
  }

  /// Total count of Dhikr items in this chapter.
  int get totalItems => items.length;

  /// Progress fraction (0.0 to 1.0) for the active Dhikr item.
  double get itemProgress {
    final item = currentItem;
    if (item == null || item.repeatCount <= 0) return 0.0;
    return (currentCounter / item.repeatCount).clamp(0.0, 1.0);
  }

  /// Overall session progress fraction (0.0 to 1.0) across all items in chapter.
  double get overallProgress {
    if (items.isEmpty) return 0.0;
    return ((currentDhikrIndex + itemProgress) / items.length).clamp(0.0, 1.0);
  }

  /// Whether there is a preceding Dhikr item in the sequence.
  bool get hasPrevious => currentDhikrIndex > 0;

  /// Whether there is a subsequent Dhikr item in the sequence.
  bool get hasNext => currentDhikrIndex < items.length - 1;

  DhikrState copyWith({
    DhikrStatus? status,
    ParentCategory? category,
    SubCategory? subCategory,
    List<DhikrItem>? items,
    int? currentDhikrIndex,
    int? currentCounter,
    bool? isSetCompleted,
    bool? justCompletedItem,
    String? errorMessage,
  }) {
    return DhikrState(
      status: status ?? this.status,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      items: items ?? this.items,
      currentDhikrIndex: currentDhikrIndex ?? this.currentDhikrIndex,
      currentCounter: currentCounter ?? this.currentCounter,
      isSetCompleted: isSetCompleted ?? this.isSetCompleted,
      justCompletedItem: justCompletedItem ?? this.justCompletedItem,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        category,
        subCategory,
        items,
        currentDhikrIndex,
        currentCounter,
        isSetCompleted,
        justCompletedItem,
        errorMessage,
      ];
}
