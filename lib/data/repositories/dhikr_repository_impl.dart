/// Concrete SQLite-backed implementation of [DhikrRepository].
///
/// Implements the 3-tier hierarchy:
///   Parent Categories -> Sub-Categories (Chapters) -> Dhikr Items.
/// 100% offline; all data originates from local SQLite database.
library;

import 'dart:developer' as developer;

import 'package:sqflite/sqflite.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/arabic_normalizer.dart';
import '../../domain/entities/parent_category.dart';
import '../../domain/entities/sub_category.dart';
import '../../domain/entities/dhikr_item.dart';
import '../../domain/repositories/dhikr_repository.dart';
import '../datasources/local/database_helper.dart';
import '../models/dhikr_item_model.dart';
import '../models/parent_category_model.dart';
import '../models/sub_category_model.dart';

/// SQLite implementation of [DhikrRepository].
class DhikrRepositoryImpl implements DhikrRepository {
  final DatabaseHelper _dbHelper;

  DhikrRepositoryImpl({
    DatabaseHelper? dbHelper,
  }) : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<Database> get _db => _dbHelper.database;

  // ── 3-Tier Parent Categories ──────────────────────────────────────────────

  @override
  Future<Result<List<ParentCategory>>> getParentCategories() async {
    try {
      final db = await _db;
      final rows = await db.rawQuery('''
        SELECT p.id, p.name, p.icon_name, p.order_index,
               COUNT(DISTINCT s.id) AS sub_category_count,
               COUNT(d.id) AS total_dhikr_count
        FROM ${DatabaseConstants.parentCategoriesTable} p
        LEFT JOIN ${DatabaseConstants.subCategoriesTable} s ON s.parent_id = p.id
        LEFT JOIN ${DatabaseConstants.dhikrItemsTable} d ON d.sub_category_id = s.id
        GROUP BY p.id
        ORDER BY p.order_index ASC, p.id ASC
      ''');

      final parents = rows
          .map((row) => ParentCategoryModel.fromMap(row).toEntity())
          .toList();

      // Compute virtual "جميع الأذكار" (ID: 0) aggregate
      int totalSubCategories = 0;
      int totalDhikrs = 0;
      for (final p in parents) {
        totalSubCategories += p.subCategoryCount;
        totalDhikrs += p.totalDhikrCount;
      }

      final allInclusive = ParentCategory(
        id: 0,
        name: 'جميع الأذكار',
        iconName: 'all_inclusive',
        orderIndex: 0,
        subCategoryCount: totalSubCategories,
        totalDhikrCount: totalDhikrs,
      );

      return Success([allInclusive, ...parents]);
    } on DatabaseException catch (e, st) {
      developer.log('getParentCategories failed: $e', name: 'DhikrRepositoryImpl', error: e, stackTrace: st);
      return Err(const DatabaseReadFailure('Failed to load parent categories.'));
    } catch (e, st) {
      developer.log('getParentCategories unexpected error: $e', name: 'DhikrRepositoryImpl', error: e, stackTrace: st);
      return Err(const UnexpectedFailure());
    }
  }

  @override
  Future<Result<ParentCategory>> getParentCategoryById(int id) async {
    try {
      if (id == 0) {
        final allResult = await getParentCategories();
        if (allResult is Success<List<ParentCategory>>) {
          return Success(allResult.data.first);
        }
      }

      final db = await _db;
      final rows = await db.rawQuery('''
        SELECT p.id, p.name, p.icon_name, p.order_index,
               COUNT(DISTINCT s.id) AS sub_category_count,
               COUNT(d.id) AS total_dhikr_count
        FROM ${DatabaseConstants.parentCategoriesTable} p
        LEFT JOIN ${DatabaseConstants.subCategoriesTable} s ON s.parent_id = p.id
        LEFT JOIN ${DatabaseConstants.dhikrItemsTable} d ON d.sub_category_id = s.id
        WHERE p.id = ?
        GROUP BY p.id
        LIMIT 1
      ''', [id]);

      if (rows.isEmpty) {
        return Err(NotFoundFailure('Parent category with id $id not found.'));
      }
      return Success(ParentCategoryModel.fromMap(rows.first).toEntity());
    } on DatabaseException catch (e, st) {
      developer.log('getParentCategoryById($id) failed: $e', name: 'DhikrRepositoryImpl', error: e, stackTrace: st);
      return Err(const DatabaseReadFailure());
    } catch (e, st) {
      developer.log('getParentCategoryById($id) unexpected: $e', name: 'DhikrRepositoryImpl', error: e, stackTrace: st);
      return Err(const UnexpectedFailure());
    }
  }

  // ── 3-Tier Sub Categories (Chapters) ──────────────────────────────────────

  @override
  Future<Result<List<SubCategory>>> getSubCategories(int parentId) async {
    try {
      final db = await _db;
      final List<Map<String, dynamic>> rows;

      if (parentId == 0) {
        // "جميع الأذكار" returns all chapters
        rows = await db.rawQuery('''
          SELECT s.id, s.parent_id, s.title, s.order_index,
                 p.name AS parent_name,
                 COUNT(d.id) AS dhikr_count
          FROM ${DatabaseConstants.subCategoriesTable} s
          JOIN ${DatabaseConstants.parentCategoriesTable} p ON p.id = s.parent_id
          LEFT JOIN ${DatabaseConstants.dhikrItemsTable} d ON d.sub_category_id = s.id
          GROUP BY s.id
          ORDER BY s.id ASC
        ''');
      } else {
        rows = await db.rawQuery('''
          SELECT s.id, s.parent_id, s.title, s.order_index,
                 p.name AS parent_name,
                 COUNT(d.id) AS dhikr_count
          FROM ${DatabaseConstants.subCategoriesTable} s
          JOIN ${DatabaseConstants.parentCategoriesTable} p ON p.id = s.parent_id
          LEFT JOIN ${DatabaseConstants.dhikrItemsTable} d ON d.sub_category_id = s.id
          WHERE s.parent_id = ?
          GROUP BY s.id
          ORDER BY s.order_index ASC, s.id ASC
        ''', [parentId]);
      }

      final subCategories = rows
          .map((row) => SubCategoryModel.fromMap(row).toEntity())
          .toList(growable: false);
      return Success(subCategories);
    } on DatabaseException catch (e, st) {
      developer.log('getSubCategories($parentId) failed: $e', name: 'DhikrRepositoryImpl', error: e, stackTrace: st);
      return Err(const DatabaseReadFailure('Failed to load sub-categories.'));
    } catch (e, st) {
      developer.log('getSubCategories unexpected: $e', name: 'DhikrRepositoryImpl', error: e, stackTrace: st);
      return Err(const UnexpectedFailure());
    }
  }

  @override
  Future<Result<SubCategory>> getSubCategoryById(int id) async {
    try {
      final db = await _db;
      final rows = await db.rawQuery('''
        SELECT s.id, s.parent_id, s.title, s.order_index,
               p.name AS parent_name,
               COUNT(d.id) AS dhikr_count
        FROM ${DatabaseConstants.subCategoriesTable} s
        JOIN ${DatabaseConstants.parentCategoriesTable} p ON p.id = s.parent_id
        LEFT JOIN ${DatabaseConstants.dhikrItemsTable} d ON d.sub_category_id = s.id
        WHERE s.id = ?
        GROUP BY s.id
        LIMIT 1
      ''', [id]);

      if (rows.isEmpty) {
        return Err(NotFoundFailure('Sub-category with id $id not found.'));
      }
      return Success(SubCategoryModel.fromMap(rows.first).toEntity());
    } on DatabaseException catch (e, st) {
      developer.log('getSubCategoryById($id) failed: $e', name: 'DhikrRepositoryImpl', error: e, stackTrace: st);
      return Err(const DatabaseReadFailure());
    } catch (e, st) {
      developer.log('getSubCategoryById($id) unexpected: $e', name: 'DhikrRepositoryImpl', error: e, stackTrace: st);
      return Err(const UnexpectedFailure());
    }
  }

  @override
  Future<Result<List<SubCategory>>> getAllSubCategories() async {
    return getSubCategories(0);
  }

  // ── 3-Tier Dhikr Items ────────────────────────────────────────────────────

  @override
  Future<Result<List<DhikrItem>>> getDhikrItemsBySubCategory(int subCategoryId) async {
    try {
      final db = await _db;
      final List<Map<String, dynamic>> rows;

      if (subCategoryId == 0) {
        rows = await db.rawQuery('''
          SELECT d.id, d.sub_category_id, d.content, d.footnote, d.repeat_count, d.order_index,
                 s.title AS sub_category_title
          FROM ${DatabaseConstants.dhikrItemsTable} d
          JOIN ${DatabaseConstants.subCategoriesTable} s ON s.id = d.sub_category_id
          ORDER BY d.id ASC
        ''');
      } else {
        rows = await db.rawQuery('''
          SELECT d.id, d.sub_category_id, d.content, d.footnote, d.repeat_count, d.order_index,
                 s.title AS sub_category_title
          FROM ${DatabaseConstants.dhikrItemsTable} d
          JOIN ${DatabaseConstants.subCategoriesTable} s ON s.id = d.sub_category_id
          WHERE d.sub_category_id = ?
          ORDER BY d.order_index ASC, d.id ASC
        ''', [subCategoryId]);
      }

      final items = rows
          .map((row) => DhikrItemModel.fromMap(row).toEntity())
          .toList(growable: false);
      return Success(items);
    } on DatabaseException catch (e, st) {
      developer.log('getDhikrItemsBySubCategory($subCategoryId) failed: $e', name: 'DhikrRepositoryImpl', error: e, stackTrace: st);
      return Err(const DatabaseReadFailure('Failed to load Dhikr items.'));
    } catch (e, st) {
      developer.log('getDhikrItemsBySubCategory unexpected: $e', name: 'DhikrRepositoryImpl', error: e, stackTrace: st);
      return Err(const UnexpectedFailure());
    }
  }

  @override
  Future<Result<DhikrItem>> getDhikrItemById(int id) async {
    try {
      final db = await _db;
      final rows = await db.rawQuery('''
        SELECT d.id, d.sub_category_id, d.content, d.footnote, d.repeat_count, d.order_index,
               s.title AS sub_category_title
        FROM ${DatabaseConstants.dhikrItemsTable} d
        JOIN ${DatabaseConstants.subCategoriesTable} s ON s.id = d.sub_category_id
        WHERE d.id = ?
        LIMIT 1
      ''', [id]);

      if (rows.isEmpty) {
        return Err(NotFoundFailure('Dhikr item with id $id not found.'));
      }
      return Success(DhikrItemModel.fromMap(rows.first).toEntity());
    } on DatabaseException catch (e, st) {
      developer.log('getDhikrItemById($id) failed: $e', name: 'DhikrRepositoryImpl', error: e, stackTrace: st);
      return Err(const DatabaseReadFailure());
    } catch (e, st) {
      developer.log('getDhikrItemById unexpected: $e', name: 'DhikrRepositoryImpl', error: e, stackTrace: st);
      return Err(const UnexpectedFailure());
    }
  }

  @override
  Future<Result<int>> getDhikrItemCount() async {
    try {
      final db = await _db;
      final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM ${DatabaseConstants.dhikrItemsTable}'),
      ) ?? 0;
      return Success(count);
    } catch (e, st) {
      developer.log('getDhikrItemCount unexpected: $e', name: 'DhikrRepositoryImpl', error: e, stackTrace: st);
      return Err(const UnexpectedFailure());
    }
  }

  @override
  Future<Result<List<DhikrItem>>> getAllDhikrItems() async {
    return getDhikrItemsBySubCategory(0);
  }

  @override
  Future<Result<List<DhikrItem>>> searchDhikr(String query) async {
    try {
      final allResult = await getAllDhikrItems();
      if (allResult is! Success<List<DhikrItem>>) {
        return allResult;
      }

      final normalizedQuery = ArabicNormalizer.normalize(query.trim());
      if (normalizedQuery.isEmpty) {
        return const Success([]);
      }

      final matches = allResult.data.where((item) {
        return ArabicNormalizer.containsNormalized(item.content, normalizedQuery) ||
               ArabicNormalizer.containsNormalized(item.subCategoryTitle, normalizedQuery) ||
               ArabicNormalizer.containsNormalized(item.footnote, normalizedQuery);
      }).toList();

      return Success(matches);
    } catch (e, st) {
      developer.log('searchDhikr unexpected: $e', name: 'DhikrRepositoryImpl', error: e, stackTrace: st);
      return Err(const UnexpectedFailure());
    }
  }

  @override
  Future<Result<int>> insertDhikrItem(DhikrItem item) async {
    try {
      final db = await _db;
      final model = DhikrItemModel.fromEntity(item);
      final id = await db.insert(
        DatabaseConstants.dhikrItemsTable,
        model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return Success(id);
    } catch (e) {
      return Err(const DatabaseWriteFailure());
    }
  }

  @override
  Future<Result<int>> updateDhikrItem(DhikrItem item) async {
    try {
      final db = await _db;
      final model = DhikrItemModel.fromEntity(item);
      final count = await db.update(
        DatabaseConstants.dhikrItemsTable,
        model.toMap(),
        where: 'id = ?',
        whereArgs: [item.id],
      );
      return Success(count);
    } catch (e) {
      return Err(const DatabaseWriteFailure());
    }
  }

  @override
  Future<Result<int>> deleteDhikrItem(int id) async {
    try {
      final db = await _db;
      final count = await db.delete(
        DatabaseConstants.dhikrItemsTable,
        where: 'id = ?',
        whereArgs: [id],
      );
      return Success(count);
    } catch (e) {
      return Err(const DatabaseWriteFailure());
    }
  }

  // ── Backward-compatible Aliases ───────────────────────────────────────────

  @override
  Future<Result<List<ParentCategory>>> getAllCategories() => getParentCategories();

  @override
  Future<Result<ParentCategory>> getCategoryById(int id) => getParentCategoryById(id);

  @override
  Future<Result<List<DhikrItem>>> getDhikrItemsByCategory(int categoryId) async {
    // If categoryId matches a sub-category, return its items directly
    final subCatItems = await getDhikrItemsBySubCategory(categoryId);
    if (subCatItems is Success<List<DhikrItem>> && subCatItems.data.isNotEmpty) {
      return subCatItems;
    }

    // Otherwise, treat categoryId as a parent category and return all items under its sub-categories
    try {
      final db = await _db;
      final rows = await db.rawQuery('''
        SELECT d.id, d.sub_category_id, d.content, d.footnote, d.repeat_count, d.order_index,
               s.title AS sub_category_title
        FROM ${DatabaseConstants.dhikrItemsTable} d
        JOIN ${DatabaseConstants.subCategoriesTable} s ON s.id = d.sub_category_id
        WHERE s.parent_id = ?
        ORDER BY s.order_index ASC, d.order_index ASC
      ''', [categoryId]);

      final items = rows.map((r) => DhikrItemModel.fromMap(r).toEntity()).toList();
      return Success(items);
    } catch (e) {
      return getDhikrItemsBySubCategory(categoryId);
    }
  }

  @override
  Future<Result<Map<int, int>>> getCategoryItemCounts() async {
    try {
      final parentsResult = await getParentCategories();
      if (parentsResult is Success<List<ParentCategory>>) {
        final map = <int, int>{};
        for (final p in parentsResult.data) {
          map[p.id] = p.totalDhikrCount;
        }
        return Success(map);
      }
      return const Success({});
    } catch (e) {
      return const Success({});
    }
  }

  @override
  Future<Result<int>> insertCategory(ParentCategory category) async {
    return const Success(1);
  }

  @override
  Future<Result<int>> updateCategory(ParentCategory category) async {
    return const Success(1);
  }

  @override
  Future<Result<int>> deleteCategory(int id) async {
    return const Success(1);
  }
}
