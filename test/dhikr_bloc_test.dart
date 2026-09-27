import 'package:flutter_test/flutter_test.dart';
import 'package:awrad_app/domain/entities/completion_log.dart';
import 'package:awrad_app/domain/entities/dhikr_item.dart';
import 'package:awrad_app/domain/entities/parent_category.dart';
import 'package:awrad_app/domain/entities/sub_category.dart';
import 'package:awrad_app/domain/repositories/dhikr_repository.dart';
import 'package:awrad_app/domain/repositories/statistics_repository.dart';
import 'package:awrad_app/presentation/blocs/dhikr/dhikr_bloc.dart';
import 'package:awrad_app/presentation/blocs/dhikr/dhikr_event.dart';
import 'package:awrad_app/presentation/blocs/dhikr/dhikr_state.dart';

class _FakeDhikrRepository implements DhikrRepository {
  final ParentCategory _testCategory = const ParentCategory(
    id: 1,
    name: 'اليوم والليلة',
    iconName: 'nights_stay',
    orderIndex: 1,
    subCategoryCount: 1,
    totalDhikrCount: 2,
  );

  final SubCategory _testSubCategory = const SubCategory(
    id: 1,
    parentId: 1,
    title: 'أذكار الصباح والمساء',
    orderIndex: 1,
    dhikrCount: 2,
  );

  final List<DhikrItem> _testItems = const [
    DhikrItem(
      id: 1,
      subCategoryId: 1,
      content: 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ',
      footnote: 'صحيح مسلم: 2723',
      repeatCount: 1,
      orderIndex: 0,
      subCategoryTitle: 'أذكار الصباح والمساء',
    ),
    DhikrItem(
      id: 2,
      subCategoryId: 1,
      content: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
      footnote: 'صحيح البخاري: 6405',
      repeatCount: 2,
      orderIndex: 1,
      subCategoryTitle: 'أذكار الصباح والمساء',
    ),
  ];

  @override
  Future<Result<List<ParentCategory>>> getParentCategories() async =>
      Success([_testCategory]);

  @override
  Future<Result<ParentCategory>> getParentCategoryById(int id) async =>
      Success(_testCategory);

  @override
  Future<Result<List<SubCategory>>> getSubCategories(int parentId) async =>
      Success([_testSubCategory]);

  @override
  Future<Result<SubCategory>> getSubCategoryById(int id) async =>
      Success(_testSubCategory);

  @override
  Future<Result<List<SubCategory>>> getAllSubCategories() async =>
      Success([_testSubCategory]);

  @override
  Future<Result<List<DhikrItem>>> getDhikrItemsBySubCategory(
          int subCategoryId) async =>
      Success(_testItems);

  @override
  Future<Result<DhikrItem>> getDhikrItemById(int id) async =>
      Success(_testItems.first);

  @override
  Future<Result<int>> getDhikrItemCount() async => Success(_testItems.length);

  @override
  Future<Result<List<DhikrItem>>> getAllDhikrItems() async =>
      Success(_testItems);

  @override
  Future<Result<List<DhikrItem>>> searchDhikr(String query) async =>
      Success(_testItems);

  @override
  Future<Result<int>> insertDhikrItem(DhikrItem item) async =>
      const Success(1);

  @override
  Future<Result<int>> updateDhikrItem(DhikrItem item) async =>
      const Success(1);

  @override
  Future<Result<int>> deleteDhikrItem(int id) async => const Success(1);

  @override
  Future<Result<List<ParentCategory>>> getAllCategories() async =>
      Success([_testCategory]);

  @override
  Future<Result<ParentCategory>> getCategoryById(int id) async =>
      Success(_testCategory);

  @override
  Future<Result<List<DhikrItem>>> getDhikrItemsByCategory(
          int categoryId) async =>
      Success(_testItems);

  @override
  Future<Result<Map<int, int>>> getCategoryItemCounts() async =>
      Success({1: _testItems.length});

  @override
  Future<Result<int>> deleteCategory(int id) async => const Success(1);

  @override
  Future<Result<int>> insertCategory(ParentCategory category) async =>
      const Success(1);

  @override
  Future<Result<int>> updateCategory(ParentCategory category) async =>
      const Success(1);
}

class _FakeStatisticsRepository implements StatisticsRepository {
  int loggedCompletions = 0;

  @override
  Future<Result<int>> logCompletion({
    required int subCategoryId,
    required String completedDate,
    bool isStreakEligible = true,
  }) async {
    loggedCompletions++;
    return const Success(1);
  }

  @override
  Future<Result<bool>> isCompletedToday(int subCategoryId) async =>
      const Success(true);

  @override
  Future<Result<int>> getCurrentStreak() async => const Success(3);

  @override
  Future<Result<int>> getLongestStreak() async => const Success(7);

  @override
  Future<Result<int>> getTotalCompletions() async => Success(loggedCompletions);

  @override
  Future<Result<Map<String, int>>> getWeeklyCompletions() async =>
      const Success({});

  @override
  Future<Result<Map<String, int>>> getCompletionHeatmap({int days = 30}) async =>
      const Success({});

  @override
  Future<Result<int>> deleteCompletionLog(int id) async => const Success(1);

  @override
  Future<Result<List<CompletionLog>>> getAllCompletionLogs() async =>
      const Success([]);

  @override
  Future<Result<List<CompletionLog>>> getCompletionLogsBySubCategory(
          int subCategoryId) async =>
      const Success([]);

  @override
  Future<Result<List<CompletionLog>>> getCompletionLogsByCategory(
          int categoryId) async =>
      const Success([]);

  @override
  Future<Result<List<CompletionLog>>> getCompletionLogsInRange({
    required String from,
    required String to,
  }) async =>
      const Success([]);
}

void main() {
  late DhikrBloc dhikrBloc;
  late _FakeDhikrRepository fakeDhikrRepo;
  late _FakeStatisticsRepository fakeStatsRepo;

  setUp(() {
    fakeDhikrRepo = _FakeDhikrRepository();
    fakeStatsRepo = _FakeStatisticsRepository();
    dhikrBloc = DhikrBloc(
      dhikrRepository: fakeDhikrRepo,
      statsRepository: fakeStatsRepo,
    );
  });

  tearDown(() {
    dhikrBloc.close();
  });

  group('DhikrBloc Engine Tests', () {
    test('initial state has empty items and initial status', () {
      expect(dhikrBloc.state.status, DhikrStatus.initial);
      expect(dhikrBloc.state.currentDhikrIndex, 0);
      expect(dhikrBloc.state.currentCounter, 0);
      expect(dhikrBloc.state.isSetCompleted, isFalse);
    });

    test('LoadDhikrList loads category and items successfully', () async {
      dhikrBloc.add(const LoadDhikrList(1));

      await expectLater(
        dhikrBloc.stream,
        emitsInOrder([
          predicate<DhikrState>((s) => s.status == DhikrStatus.loading),
          predicate<DhikrState>((s) =>
              s.status == DhikrStatus.loaded &&
              s.items.length == 2 &&
              s.currentDhikrIndex == 0 &&
              s.currentItem?.repeatCount == 1),
        ]),
      );
    });

    test('IncrementCounter advances to next item when repeat target reached',
        () async {
      dhikrBloc.add(const LoadDhikrList(1));
      await dhikrBloc.stream.firstWhere((s) => s.status == DhikrStatus.loaded);

      // First item repeatCount is 1 -> Incrementing should advance to item 1 with counter 0
      dhikrBloc.add(const IncrementCounter());

      await expectLater(
        dhikrBloc.stream,
        emits(predicate<DhikrState>((s) =>
            s.currentDhikrIndex == 1 &&
            s.currentCounter == 0 &&
            s.justCompletedItem == true)),
      );
    });

    test(
        'IncrementCounter marks set as completed and logs streak when final item finishes',
        () async {
      dhikrBloc.add(const LoadDhikrList(1, initialIndex: 1));
      await dhikrBloc.stream.firstWhere((s) => s.status == DhikrStatus.loaded);

      // Item 2 has repeatCount = 2
      // Tap 1: counter goes from 0 -> 1
      dhikrBloc.add(const IncrementCounter());
      await expectLater(
        dhikrBloc.stream,
        emits(predicate<DhikrState>((s) =>
            s.currentDhikrIndex == 1 &&
            s.currentCounter == 1 &&
            !s.isSetCompleted)),
      );

      // Tap 2: counter goes from 1 -> 2 (target reached on final item -> completed!)
      dhikrBloc.add(const IncrementCounter());
      await expectLater(
        dhikrBloc.stream,
        emits(predicate<DhikrState>((s) =>
            s.isSetCompleted == true &&
            s.status == DhikrStatus.completed &&
            s.currentCounter == 2)),
      );

      // Verify that StatisticsRepository logged the completion
      expect(fakeStatsRepo.loggedCompletions, 1);
    });

    test('ResetDhikrSession resets index and counter back to 0', () async {
      dhikrBloc.add(const LoadDhikrList(1, initialIndex: 1));
      await dhikrBloc.stream.firstWhere((s) => s.status == DhikrStatus.loaded);

      dhikrBloc.add(const ResetDhikrSession());
      await expectLater(
        dhikrBloc.stream,
        emits(predicate<DhikrState>((s) =>
            s.currentDhikrIndex == 0 &&
            s.currentCounter == 0 &&
            !s.isSetCompleted)),
      );
    });
  });
}
