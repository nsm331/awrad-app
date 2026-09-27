import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/parent_category.dart';
import '../../../domain/repositories/dhikr_repository.dart';
import '../../../domain/repositories/statistics_repository.dart';
import 'sub_category_state.dart';

/// Cubit managing the list of sub-chapters under a selected [ParentCategory].
class SubCategoryCubit extends Cubit<SubCategoryState> {
  final DhikrRepository _dhikrRepository;
  final StatisticsRepository _statisticsRepository;

  SubCategoryCubit({
    required DhikrRepository dhikrRepository,
    required StatisticsRepository statisticsRepository,
  })  : _dhikrRepository = dhikrRepository,
        _statisticsRepository = statisticsRepository,
        super(const SubCategoryInitial());

  /// Loads all sub-categories for the given [parentId].
  Future<void> loadSubCategories(int parentId) async {
    emit(const SubCategoryLoading());

    try {
      final parentResult = await _dhikrRepository.getParentCategoryById(parentId);
      final subCatsResult = await _dhikrRepository.getSubCategories(parentId);

      if (parentResult is Err<ParentCategory>) {
        emit(SubCategoryError(parentResult.failure.message));
        return;
      }
      final parent = (parentResult as Success<ParentCategory>).data;

      if (subCatsResult is Err) {
        emit(SubCategoryError((subCatsResult as Err).failure.message));
        return;
      }
      final subCategories = (subCatsResult as Success).data;

      // Check which chapters are completed today
      final completedTodayIds = <int>{};
      for (final sub in subCategories) {
        final compResult = await _statisticsRepository.isCompletedToday(sub.id);
        if (compResult is Success<bool> && compResult.data) {
          completedTodayIds.add(sub.id);
        }
      }

      emit(SubCategoryLoaded(
        parentCategory: parent,
        subCategories: subCategories,
        completedTodayIds: completedTodayIds,
      ));
    } catch (e, st) {
      developer.log('loadSubCategories error: $e', name: 'SubCategoryCubit', error: e, stackTrace: st);
      emit(SubCategoryError('حدث خطأ أثناء تحميل الفصول: $e'));
    }
  }

  /// Refreshes completion status after reading.
  Future<void> refreshCompletions() async {
    final currentState = state;
    if (currentState is SubCategoryLoaded) {
      final completedTodayIds = <int>{};
      for (final sub in currentState.subCategories) {
        final compResult = await _statisticsRepository.isCompletedToday(sub.id);
        if (compResult is Success<bool> && compResult.data) {
          completedTodayIds.add(sub.id);
        }
      }
      emit(SubCategoryLoaded(
        parentCategory: currentState.parentCategory,
        subCategories: currentState.subCategories,
        completedTodayIds: completedTodayIds,
      ));
    }
  }
}
