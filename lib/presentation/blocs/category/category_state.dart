import 'package:equatable/equatable.dart';

import '../../../domain/entities/category.dart';

/// Base state for Category operations.
sealed class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object?> get props => [];
}

/// Initial uninitialized state.
final class CategoryInitial extends CategoryState {
  const CategoryInitial();
}

/// Loading state while fetching from SQLite.
final class CategoryLoading extends CategoryState {
  const CategoryLoading();
}

/// Successfully loaded categories with their respective Dhikr counts.
final class CategoryLoaded extends CategoryState {
  final List<Category> categories;
  final Map<int, int> itemCounts;

  const CategoryLoaded({
    required this.categories,
    required this.itemCounts,
  });

  /// Helper to get the Dhikr count for a specific category ID.
  int countFor(int categoryId) => itemCounts[categoryId] ?? 0;

  @override
  List<Object?> get props => [categories, itemCounts];
}

/// Error state if SQLite read fails.
final class CategoryError extends CategoryState {
  final String message;

  const CategoryError(this.message);

  @override
  List<Object?> get props => [message];
}
