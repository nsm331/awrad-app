import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/datasources/local/database_helper.dart';
import '../../../domain/repositories/dhikr_repository.dart';
import 'category_state.dart';

/// Cubit responsible for loading and refreshing Dhikr categories from SQLite.
class CategoryCubit extends Cubit<CategoryState> {
  final DhikrRepository _repository;

  CategoryCubit(this._repository) : super(const CategoryInitial());

  /// Loads all categories and their Dhikr item counts from the local database.
  /// Automatically ensures the database is seeded from `hisn_muslim.json` if needed.
  Future<void> loadCategories({bool force = false}) async {
    emit(const CategoryLoading());

    try {
      await DatabaseHelper.instance.seedIfNeeded(force: force);
    } catch (e, st) {
      developer.log(
        'CategoryCubit seedIfNeeded error: $e',
        name: 'CategoryCubit',
        error: e,
        stackTrace: st,
      );
    }

    try {
      final categoriesResult = await _repository.getAllCategories();
      final countsResult = await _repository.getCategoryItemCounts();

      switch (categoriesResult) {
        case Success(:final data):
          final counts = switch (countsResult) {
            Success(data: final map) => map,
            Err() => <int, int>{},
          };
          emit(CategoryLoaded(categories: data, itemCounts: counts));

        case Err(:final failure):
          emit(CategoryError(failure.message));
      }
    } catch (e, st) {
      developer.log(
        'CategoryCubit loadCategories error: $e',
        name: 'CategoryCubit',
        error: e,
        stackTrace: st,
      );
      emit(CategoryError('حدث خطأ أثناء تحميل البيانات: $e'));
    }
  }
}
