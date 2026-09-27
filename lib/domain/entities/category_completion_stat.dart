import 'package:equatable/equatable.dart';

/// Represents aggregated completion statistics for a SubCategory chapter.
class CategoryCompletionStat extends Equatable {
  /// The SubCategory primary key identifier.
  final int subCategoryId;

  /// The SubCategory title (e.g., 'أذكار الصباح').
  final String title;

  /// Total number of times this SubCategory has been completed.
  final int completionCount;

  const CategoryCompletionStat({
    required this.subCategoryId,
    required this.title,
    required this.completionCount,
  });

  @override
  List<Object?> get props => [subCategoryId, title, completionCount];
}
