import 'package:equatable/equatable.dart';

import '../../../domain/entities/parent_category.dart';
import '../../../domain/entities/sub_category.dart';
import '../../../domain/entities/dhikr_item.dart';

/// A search result pairing a matching [DhikrItem] with its chapter ([SubCategory])
/// and optional [ParentCategory].
class DhikrSearchResultItem extends Equatable {
  final DhikrItem item;
  final SubCategory subCategory;
  final ParentCategory? category;

  const DhikrSearchResultItem({
    required this.item,
    required this.subCategory,
    this.category,
  });

  @override
  List<Object?> get props => [item, subCategory, category];
}

/// State of the local offline search engine.
class SearchState extends Equatable {
  /// The raw user query.
  final String query;

  /// Parent categories matching the query.
  final List<ParentCategory> matchingCategories;

  /// Sub-categories (chapters) matching the query.
  final List<SubCategory> matchingSubCategories;

  /// Dhikr items whose content, chapter, or footnote matches the query.
  final List<DhikrSearchResultItem> matchingDhikrItems;

  /// Whether the search bar has active text.
  final bool isSearching;

  /// Whether initial search index is loading from SQLite.
  final bool isLoading;

  const SearchState({
    this.query = '',
    this.matchingCategories = const [],
    this.matchingSubCategories = const [],
    this.matchingDhikrItems = const [],
    this.isSearching = false,
    this.isLoading = false,
  });

  /// Total count of matching results across categories, sub-categories, and items.
  int get totalMatches =>
      matchingCategories.length +
      matchingSubCategories.length +
      matchingDhikrItems.length;

  SearchState copyWith({
    String? query,
    List<ParentCategory>? matchingCategories,
    List<SubCategory>? matchingSubCategories,
    List<DhikrSearchResultItem>? matchingDhikrItems,
    bool? isSearching,
    bool? isLoading,
  }) {
    return SearchState(
      query: query ?? this.query,
      matchingCategories: matchingCategories ?? this.matchingCategories,
      matchingSubCategories: matchingSubCategories ?? this.matchingSubCategories,
      matchingDhikrItems: matchingDhikrItems ?? this.matchingDhikrItems,
      isSearching: isSearching ?? this.isSearching,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
        query,
        matchingCategories,
        matchingSubCategories,
        matchingDhikrItems,
        isSearching,
        isLoading,
      ];
}
