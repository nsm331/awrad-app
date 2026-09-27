/// Abstract contract for the Dhikr repository.
///
/// Supports the 3-tier hierarchy:
///   Parent Categories -> Sub-Categories (Chapters) -> Dhikr Items.
library;

import '../entities/parent_category.dart';
import '../entities/sub_category.dart';
import '../entities/dhikr_item.dart';
import '../../core/errors/failures.dart';

// ── Result discriminated union ────────────────────────────────────────────────

sealed class Result<T> {
  const Result();
}

final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

final class Err<T> extends Result<T> {
  final Failure failure;
  const Err(this.failure);
}

// ── Repository contract ───────────────────────────────────────────────────────

/// Contract for all Dhikr-related data operations (100% offline).
abstract class DhikrRepository {
  // ── 3-Tier Parent Categories ──────────────────────────────────────────────

  /// Returns all parent categories with their sub-category count and total dhikr count.
  /// Includes "جميع الأذكار" (id: 0) as an aggregate.
  Future<Result<List<ParentCategory>>> getParentCategories();

  /// Returns a specific parent category by [id].
  Future<Result<ParentCategory>> getParentCategoryById(int id);

  // ── 3-Tier Sub Categories (Chapters) ──────────────────────────────────────

  /// Returns all sub-categories belonging to [parentId].
  /// If [parentId] == 0 ("جميع الأذكار"), returns all sub-categories in the app.
  Future<Result<List<SubCategory>>> getSubCategories(int parentId);

  /// Returns a specific sub-category by [id].
  Future<Result<SubCategory>> getSubCategoryById(int id);

  /// Returns all sub-categories across the entire dataset.
  Future<Result<List<SubCategory>>> getAllSubCategories();

  // ── 3-Tier Dhikr Items ────────────────────────────────────────────────────

  /// Returns all [DhikrItem]s belonging to chapter [subCategoryId], ordered by [orderIndex].
  Future<Result<List<DhikrItem>>> getDhikrItemsBySubCategory(int subCategoryId);

  /// Returns the [DhikrItem] with the given [id].
  Future<Result<DhikrItem>> getDhikrItemById(int id);

  /// Returns the total count of [DhikrItem]s stored in the database.
  Future<Result<int>> getDhikrItemCount();

  /// Returns all [DhikrItem]s across all chapters.
  Future<Result<List<DhikrItem>>> getAllDhikrItems();

  // ── Search & Mutators ─────────────────────────────────────────────────────

  /// Searches across sub-category titles and Dhikr content.
  Future<Result<List<DhikrItem>>> searchDhikr(String query);

  Future<Result<int>> insertDhikrItem(DhikrItem item);
  Future<Result<int>> updateDhikrItem(DhikrItem item);
  Future<Result<int>> deleteDhikrItem(int id);

  // ── Backward-compatible Aliases ───────────────────────────────────────────

  /// Legacy alias for [getParentCategories].
  Future<Result<List<ParentCategory>>> getAllCategories();

  /// Legacy alias for [getParentCategoryById].
  Future<Result<ParentCategory>> getCategoryById(int id);

  /// Legacy alias for [getDhikrItemsBySubCategory].
  Future<Result<List<DhikrItem>>> getDhikrItemsByCategory(int categoryId);

  Future<Result<Map<int, int>>> getCategoryItemCounts();
  Future<Result<int>> insertCategory(ParentCategory category);
  Future<Result<int>> updateCategory(ParentCategory category);
  Future<Result<int>> deleteCategory(int id);
}
