import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:awrad_app/domain/entities/category_completion_stat.dart';
import 'package:awrad_app/domain/entities/completion_log.dart';
import 'package:awrad_app/domain/entities/weekly_day_matrix.dart';
import 'package:awrad_app/domain/repositories/dhikr_repository.dart';
import 'package:awrad_app/domain/repositories/statistics_repository.dart';
import 'package:awrad_app/presentation/blocs/stats/stats_cubit.dart';
import 'package:awrad_app/presentation/blocs/stats/stats_state.dart';
import 'package:awrad_app/presentation/screens/stats/stats_screen.dart';

class _MockStatisticsRepository implements StatisticsRepository {
  int currentStreak = 5;
  int longestStreak = 12;
  int totalCompletions = 28;
  int uniqueSubCategories = 4;
  double activeRate = 80.0;
  List<CategoryCompletionStat> topCategories = const [
    CategoryCompletionStat(
      subCategoryId: 5,
      title: 'أذكار الصباح',
      completionCount: 15,
    ),
    CategoryCompletionStat(
      subCategoryId: 29,
      title: 'أذكار المساء',
      completionCount: 10,
    ),
    CategoryCompletionStat(
      subCategoryId: 51,
      title: 'أذكار النوم',
      completionCount: 3,
    ),
  ];

  @override
  Future<Result<int>> getCurrentStreak() async => Success(currentStreak);

  @override
  Future<Result<int>> getLongestStreak() async => Success(longestStreak);

  @override
  Future<Result<int>> getTotalCompletions() async => Success(totalCompletions);

  @override
  Future<Result<int>> getTotalCompletedSubCategoriesCount() async =>
      Success(uniqueSubCategories);

  @override
  Future<Result<double>> getActiveDayRate({int days = 30}) async =>
      Success(activeRate);

  @override
  Future<Result<List<CategoryCompletionStat>>> getMostCompletedSubCategories({
    int limit = 3,
  }) async =>
      Success(topCategories);

  @override
  Future<Result<List<WeeklyDayData>>> getWeeklyMatrix() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return Success([
      WeeklyDayData(
        date: today.subtract(const Duration(days: 2)),
        dayName: 'السبت',
        dateLabel: '25/9',
        count: 2,
        status: WeeklyDayStatus.completed,
        isToday: false,
      ),
      WeeklyDayData(
        date: today.subtract(const Duration(days: 1)),
        dayName: 'الأحد',
        dateLabel: '26/9',
        count: 0,
        status: WeeklyDayStatus.missed,
        isToday: false,
      ),
      WeeklyDayData(
        date: today,
        dayName: 'الإثنين',
        dateLabel: '27/9',
        count: 1,
        status: WeeklyDayStatus.completed,
        isToday: true,
      ),
      WeeklyDayData(
        date: today.add(const Duration(days: 1)),
        dayName: 'الثلاثاء',
        dateLabel: '28/9',
        count: 0,
        status: WeeklyDayStatus.future,
        isToday: false,
      ),
      WeeklyDayData(
        date: today.add(const Duration(days: 2)),
        dayName: 'الأربعاء',
        dateLabel: '29/9',
        count: 0,
        status: WeeklyDayStatus.future,
        isToday: false,
      ),
      WeeklyDayData(
        date: today.add(const Duration(days: 3)),
        dayName: 'الخميس',
        dateLabel: '30/9',
        count: 0,
        status: WeeklyDayStatus.future,
        isToday: false,
      ),
      WeeklyDayData(
        date: today.add(const Duration(days: 4)),
        dayName: 'الجمعة',
        dateLabel: '1/10',
        count: 0,
        status: WeeklyDayStatus.future,
        isToday: false,
      ),
    ]);
  }

  @override
  Future<Result<Map<String, int>>> getWeeklyCompletions() async =>
      const Success({});

  @override
  Future<Result<Map<String, int>>> getCompletionHeatmap({int days = 30}) async {
    final now = DateTime.now();
    final todayStr =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return Success({todayStr: 2});
  }

  @override
  Future<Result<int>> deleteCompletionLog(int id) async => const Success(1);

  @override
  Future<Result<List<CompletionLog>>> getAllCompletionLogs() async =>
      const Success([]);

  @override
  Future<Result<List<CompletionLog>>> getCompletionLogsByCategory(
          int categoryId) async =>
      const Success([]);

  @override
  Future<Result<List<CompletionLog>>> getCompletionLogsBySubCategory(
          int subCategoryId) async =>
      const Success([]);

  @override
  Future<Result<List<CompletionLog>>> getCompletionLogsInRange({
    required String from,
    required String to,
  }) async =>
      const Success([]);

  @override
  Future<Result<bool>> isCompletedToday(int subCategoryId) async =>
      const Success(true);

  @override
  Future<Result<int>> logCompletion({
    required int subCategoryId,
    required String completedDate,
    bool isStreakEligible = true,
  }) async =>
      const Success(1);
}

void main() {
  group('Phase 6: Domain Entities', () {
    test('CategoryCompletionStat value equality and properties', () {
      const stat1 = CategoryCompletionStat(
        subCategoryId: 5,
        title: 'أذكار الصباح',
        completionCount: 10,
      );
      const stat2 = CategoryCompletionStat(
        subCategoryId: 5,
        title: 'أذكار الصباح',
        completionCount: 10,
      );
      const stat3 = CategoryCompletionStat(
        subCategoryId: 29,
        title: 'أذكار المساء',
        completionCount: 8,
      );

      expect(stat1, equals(stat2));
      expect(stat1 == stat3, isFalse);
      expect(stat1.subCategoryId, 5);
      expect(stat1.title, 'أذكار الصباح');
      expect(stat1.completionCount, 10);
    });

    test('WeeklyDayData equality and WeeklyDayStatus enum', () {
      final now = DateTime(2026, 9, 27);
      final day1 = WeeklyDayData(
        date: now,
        dayName: 'السبت',
        dateLabel: '27/9',
        count: 2,
        status: WeeklyDayStatus.completed,
        isToday: true,
      );
      final day2 = WeeklyDayData(
        date: now,
        dayName: 'السبت',
        dateLabel: '27/9',
        count: 2,
        status: WeeklyDayStatus.completed,
        isToday: true,
      );

      expect(day1, equals(day2));
      expect(WeeklyDayStatus.values.length, 4);
    });
  });

  group('Phase 6: StatsCubit Aggregation', () {
    test('loadStats emits StatsLoading then StatsLoaded with full metrics',
        () async {
      final mockRepo = _MockStatisticsRepository();
      final cubit = StatsCubit(mockRepo);

      expect(cubit.state, isA<StatsInitial>());

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<StatsLoading>(),
          predicate<StatsState>((state) {
            if (state is! StatsLoaded) return false;
            return state.currentStreak == 5 &&
                state.longestStreak == 12 &&
                state.totalCompletions == 28 &&
                state.totalCompletedSubCategories == 4 &&
                state.activeDayRate == 80.0 &&
                state.topSubCategories.length == 3 &&
                state.weeklyMatrix.length == 7;
          }),
        ]),
      );

      await cubit.loadStats();
      await expectation;
      await cubit.close();
    });
  });

  group('Phase 6: StatsScreen UI', () {
    testWidgets('renders Hero Streak Badge, 2x2 cards, weekly matrix & top categories',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final mockRepo = _MockStatisticsRepository();
      final cubit = StatsCubit(mockRepo);
      await cubit.loadStats();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<StatsCubit>.value(
            value: cubit,
            child: const StatsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Header
      expect(find.text('إِحْصَائِيَّاتُ الْأَوْرَادِ'), findsOneWidget);

      // 2. Hero Streak Badge
      expect(find.text('السلسلة الحالية'), findsOneWidget);
      expect(find.text('أيام متتالية'), findsOneWidget);

      // 3. Two-Column Stat Cards
      expect(find.text('إجمالي الجلسات'), findsOneWidget);
      expect(find.text('28'), findsOneWidget);
      expect(find.text('الأبواب المنجزة'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('معدل الالتزام'), findsOneWidget);
      expect(find.text('80%'), findsOneWidget);
      expect(find.text('أطول سلسلة'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);

      // 4. Weekly Matrix
      expect(find.text('مصفوفة الإنجاز الأسبوعي'), findsOneWidget);
      expect(find.text('السبت'), findsOneWidget);
      expect(find.text('الأحد'), findsOneWidget);
      expect(find.text('الإثنين'), findsOneWidget);

      // 5. Top 3 Categories
      expect(find.text('الأوراد الأكثر إنجازاً'), findsOneWidget);
      expect(find.text('أذكار الصباح'), findsOneWidget);
      expect(find.text('15 ختمة'), findsOneWidget);
      expect(find.text('أذكار المساء'), findsOneWidget);
      expect(find.text('10 ختمة'), findsOneWidget);

      // 6. Quranic verse card
      expect(
        find.text(
            '﴿ وَالذَّاكِرِينَ اللَّهَ كَثِيرًا وَالذَّاكِرَاتِ أَعَدَّ اللَّهُ لَهُمْ مَغْفِرَةً وَأَجْرًا عَظِيمًا ﴾'),
        findsOneWidget,
      );

      await cubit.close();
    });
  });
}
