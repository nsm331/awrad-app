import 'package:equatable/equatable.dart';

import '../../../domain/entities/parent_category.dart';
import '../../../domain/entities/sub_category.dart';

/// States for the [SubCategoryCubit].
sealed class SubCategoryState extends Equatable {
  const SubCategoryState();

  @override
  List<Object?> get props => [];
}

final class SubCategoryInitial extends SubCategoryState {
  const SubCategoryInitial();
}

final class SubCategoryLoading extends SubCategoryState {
  const SubCategoryLoading();
}

final class SubCategoryLoaded extends SubCategoryState {
  final ParentCategory parentCategory;
  final List<SubCategory> subCategories;
  final Set<int> completedTodayIds;

  const SubCategoryLoaded({
    required this.parentCategory,
    required this.subCategories,
    this.completedTodayIds = const {},
  });

  @override
  List<Object?> get props => [parentCategory, subCategories, completedTodayIds];
}

final class SubCategoryError extends SubCategoryState {
  final String message;

  const SubCategoryError(this.message);

  @override
  List<Object?> get props => [message];
}
