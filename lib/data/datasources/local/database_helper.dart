/// SQLite database helper and lifecycle manager for the Awrad app.
///
/// Manages the sqflite [Database] lifecycle, 3-tier schema migrations
/// (`parent_categories` -> `sub_categories` -> `dhikr_items`), indexes,
/// and delegates first-launch seeding to [DatabaseSeeder].
library;

import 'dart:developer' as developer;

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../../../core/constants/app_constants.dart';
import '../../models/completion_log_model.dart';
import '../../models/dhikr_item_model.dart';
import '../../models/parent_category_model.dart';
import '../../models/sub_category_model.dart';
import 'database_seeder.dart';

/// Singleton helper managing the SQLite [Database].
class DatabaseHelper {
  DatabaseHelper._internal();

  /// The single, shared instance.
  static final DatabaseHelper instance = DatabaseHelper._internal();

  Database? _db;

  // ── Public API ──────────────────────────────────────────────────────────────

  /// Returns the open [Database], initialising it on first access.
  Future<Database> get database async {
    _db ??= await _initDatabase();
    return _db!;
  }

  /// Closes the database connection.
  Future<void> close() async {
    await _db?.close();
    _db = null;
  }

  // ── Initialisation ──────────────────────────────────────────────────────────

  Future<Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = p.join(directory.path, DatabaseConstants.databaseName);

    developer.log('Opening database at: $path', name: 'DatabaseHelper');

    return openDatabase(
      path,
      version: DatabaseConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  /// Creates the normalized 3-tier schema.
  Future<void> _onCreate(Database db, int version) async {
    developer.log(
      'Creating 3-tier database schema (v$version)',
      name: 'DatabaseHelper',
    );

    // 1. Parent Categories table
    await db.execute(ParentCategoryModel.createTableSql);

    // 2. Sub Categories table
    await db.execute(SubCategoryModel.createTableSql);

    // 3. Dhikr Items table
    await db.execute(DhikrItemModel.createTableSql);

    // 4. Completion Logs table
    await db.execute(CompletionLogModel.createTableSql);

    // Performance indexes for foreign keys & queries
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_sub_categories_parent
        ON ${DatabaseConstants.subCategoriesTable} (parent_id)
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_dhikr_items_sub_category
        ON ${DatabaseConstants.dhikrItemsTable} (sub_category_id)
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_completion_logs_sub_category
        ON ${DatabaseConstants.completionLogsTable} (sub_category_id)
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_completion_logs_date
        ON ${DatabaseConstants.completionLogsTable} (completed_date)
    ''');

    developer.log('3-tier schema created successfully.', name: 'DatabaseHelper');
  }

  /// Migrates database schema when [DatabaseConstants.databaseVersion] is bumped.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    developer.log(
      'Upgrading database from v$oldVersion to v$newVersion',
      name: 'DatabaseHelper',
    );

    if (oldVersion < 4) {
      await db.execute('DROP TABLE IF EXISTS ${DatabaseConstants.completionLogsTable}');
      await db.execute('DROP TABLE IF EXISTS ${DatabaseConstants.dhikrItemsTable}');
      await db.execute('DROP TABLE IF EXISTS ${DatabaseConstants.subCategoriesTable}');
      await db.execute('DROP TABLE IF EXISTS ${DatabaseConstants.parentCategoriesTable}');
      await db.execute('DROP TABLE IF EXISTS categories');
      await _onCreate(db, newVersion);
    }
  }

  /// Enables SQLite foreign key constraints.
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // ── First-launch & upgrade seeder ───────────────────────────────────────────

  /// Seeds or updates the database from bundled Hisn al-Muslim JSON.
  Future<void> seedIfNeeded({bool force = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final db = await database;

    // Check count of parent categories
    final parentCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM ${DatabaseConstants.parentCategoriesTable}'),
    ) ?? 0;

    // Check count of sub categories
    final subCatCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM ${DatabaseConstants.subCategoriesTable}'),
    ) ?? 0;

    const int kTargetDatasetVersion = 4; // Version 4: separated morning/evening dataset & unified layout
    final currentSeedVersion = prefs.getInt('awrad_db_dataset_version') ?? 0;

    final needsSeed = force ||
        parentCount < 11 ||
        subCatCount < 19 ||
        currentSeedVersion < kTargetDatasetVersion;

    if (!needsSeed) {
      developer.log(
        'Database already seeded with $parentCount parents and $subCatCount sub-categories — skipping.',
        name: 'DatabaseHelper.seedIfNeeded',
      );
      return;
    }

    developer.log(
      'Starting database seed (parents=$parentCount, subCats=$subCatCount, v=$currentSeedVersion, force=$force)...',
      name: 'DatabaseHelper.seedIfNeeded',
    );

    try {
      const seeder = DatabaseSeeder();
      await seeder.seed(db);

      await prefs.setBool(PreferencesKeys.isDbSeeded, true);
      await prefs.setInt('awrad_db_dataset_version', kTargetDatasetVersion);
      developer.log('Database seed completed successfully.', name: 'DatabaseHelper.seedIfNeeded');
    } catch (e, st) {
      developer.log(
        'Database seed FAILED: $e',
        name: 'DatabaseHelper.seedIfNeeded',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// Resets the seed flag for testing.
  Future<void> resetSeedFlag() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(PreferencesKeys.isDbSeeded);
    await prefs.remove('awrad_db_dataset_version');
    developer.log('Seed flag cleared.', name: 'DatabaseHelper');
  }
}
