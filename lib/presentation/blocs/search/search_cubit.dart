import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/arabic_normalizer.dart';
import '../../../domain/entities/parent_category.dart';
import '../../../domain/entities/sub_category.dart';
import '../../../domain/entities/dhikr_item.dart';
import '../../../domain/repositories/dhikr_repository.dart';
import 'search_state.dart';

/// Cubit responsible for real-time offline search with Tashkeel normalization.
class SearchCubit extends Cubit<SearchState> {
  final DhikrRepository _repository;

  List<ParentCategory> _allParents = [];
  List<SubCategory> _allSubCategories = [];
  List<DhikrItem> _allDhikrItems = [];
  final Map<int, ParentCategory> _parentMap = {};
  final Map<int, SubCategory> _subCategoryMap = {};

  SearchCubit(this._repository) : super(const SearchState()) {
    initIndex();
  }

  /// Indexes all parent categories, sub-categories, and Dhikrs for instant search.
  Future<void> initIndex() async {
    emit(state.copyWith(isLoading: true));

    final parentsResult = await _repository.getParentCategories();
    final subCatsResult = await _repository.getAllSubCategories();
    final itemsResult = await _repository.getAllDhikrItems();

    if (parentsResult is Success<List<ParentCategory>>) {
      _allParents = parentsResult.data;
      _parentMap.clear();
      for (final p in _allParents) {
        _parentMap[p.id] = p;
      }
    }

    if (subCatsResult is Success<List<SubCategory>>) {
      _allSubCategories = subCatsResult.data;
      _subCategoryMap.clear();
      for (final s in _allSubCategories) {
        _subCategoryMap[s.id] = s;
      }
    }

    if (itemsResult is Success<List<DhikrItem>>) {
      _allDhikrItems = itemsResult.data;
    }

    emit(state.copyWith(isLoading: false));
  }

  /// Executes real-time normalized search across parent categories, chapter titles,
  /// and Dhikr text.
  void search(String rawQuery) {
    final query = rawQuery.trim();

    if (query.isEmpty) {
      emit(state.copyWith(
        query: '',
        matchingCategories: const [],
        matchingSubCategories: const [],
        matchingDhikrItems: const [],
        isSearching: false,
      ));
      return;
    }

    // 1. Filter matching parent categories
    final matchingParents = _allParents.where((p) {
      return ArabicNormalizer.containsNormalized(p.name, query);
    }).toList(growable: false);

    // 2. Filter matching sub-categories (chapters)
    final matchingSubs = _allSubCategories.where((s) {
      return ArabicNormalizer.containsNormalized(s.title, query);
    }).toList(growable: false);

    // 3. Filter matching Dhikr items
    final matchingItems = <DhikrSearchResultItem>[];
    for (final item in _allDhikrItems) {
      if (ArabicNormalizer.containsNormalized(item.content, query) ||
          ArabicNormalizer.containsNormalized(item.subCategoryTitle, query) ||
          ArabicNormalizer.containsNormalized(item.footnote, query)) {
        final subCat = _subCategoryMap[item.subCategoryId] ??
            SubCategory(
              id: item.subCategoryId,
              parentId: 0,
              title: item.subCategoryTitle,
            );
        final parentCat = _parentMap[subCat.parentId];

        matchingItems.add(DhikrSearchResultItem(
          item: item,
          subCategory: subCat,
          category: parentCat,
        ));
      }
    }

    emit(state.copyWith(
      query: query,
      matchingCategories: matchingParents,
      matchingSubCategories: matchingSubs,
      matchingDhikrItems: matchingItems,
      isSearching: true,
    ));
  }

  /// Clears the active search query.
  void clearSearch() {
    emit(state.copyWith(
      query: '',
      matchingCategories: const [],
      matchingSubCategories: const [],
      matchingDhikrItems: const [],
      isSearching: false,
    ));
  }
}
