import 'package:flutter_test/flutter_test.dart';
import 'package:awrad_app/domain/entities/parent_category.dart';
import 'package:awrad_app/domain/entities/sub_category.dart';
import 'package:awrad_app/domain/entities/dhikr_item.dart';
import 'package:awrad_app/domain/repositories/dhikr_repository.dart';
import 'package:awrad_app/presentation/blocs/search/search_cubit.dart';

class _MockDhikrRepository implements DhikrRepository {
  final List<ParentCategory> _parents = const [
    ParentCategory(
      id: 1,
      name: 'اليوم والليلة',
      iconName: 'nights_stay',
      subCategoryCount: 1,
      totalDhikrCount: 2,
    ),
    ParentCategory(
      id: 2,
      name: 'التسابيح والاستغفار',
      iconName: 'stars',
      subCategoryCount: 1,
      totalDhikrCount: 1,
    ),
  ];

  final List<SubCategory> _subCategories = const [
    SubCategory(
      id: 1,
      parentId: 1,
      title: 'أَذْكَارُ الصَّبَاحِ وَالْمَسَاءِ',
      orderIndex: 0,
      dhikrCount: 2,
    ),
    SubCategory(
      id: 2,
      parentId: 2,
      title: 'الاستغفار والتوبة',
      orderIndex: 0,
      dhikrCount: 1,
    ),
  ];

  final List<DhikrItem> _items = const [
    DhikrItem(
      id: 1,
      subCategoryId: 1,
      content: 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ رَبِّ الْعَالَمِينَ',
      footnote: 'صحيح مسلم',
      repeatCount: 1,
      orderIndex: 0,
      subCategoryTitle: 'أَذْكَارُ الصَّبَاحِ وَالْمَسَاءِ',
    ),
    DhikrItem(
      id: 2,
      subCategoryId: 1,
      content: 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ',
      footnote: 'صحيح مسلم',
      repeatCount: 1,
      orderIndex: 1,
      subCategoryTitle: 'أَذْكَارُ الصَّبَاحِ وَالْمَسَاءِ',
    ),
    DhikrItem(
      id: 3,
      subCategoryId: 2,
      content: 'أَسْتَغْفِرُ اللَّهَ الْعَظِيمَ وَأَتُوبُ إِلَيْهِ',
      footnote: 'الترمذي: مغفرة الذنوب',
      repeatCount: 100,
      orderIndex: 0,
      subCategoryTitle: 'الاستغفار والتوبة',
    ),
  ];

  @override
  Future<Result<List<ParentCategory>>> getParentCategories() async =>
      Success(_parents);

  @override
  Future<Result<ParentCategory>> getParentCategoryById(int id) async =>
      Success(_parents.firstWhere((p) => p.id == id));

  @override
  Future<Result<List<SubCategory>>> getSubCategories(int parentId) async =>
      Success(_subCategories.where((s) => s.parentId == parentId).toList());

  @override
  Future<Result<SubCategory>> getSubCategoryById(int id) async =>
      Success(_subCategories.firstWhere((s) => s.id == id));

  @override
  Future<Result<List<SubCategory>>> getAllSubCategories() async =>
      Success(_subCategories);

  @override
  Future<Result<List<DhikrItem>>> getDhikrItemsBySubCategory(
          int subCategoryId) async =>
      Success(_items.where((i) => i.subCategoryId == subCategoryId).toList());

  @override
  Future<Result<DhikrItem>> getDhikrItemById(int id) async =>
      Success(_items.firstWhere((i) => i.id == id));

  @override
  Future<Result<int>> getDhikrItemCount() async => Success(_items.length);

  @override
  Future<Result<List<DhikrItem>>> getAllDhikrItems() async => Success(_items);

  @override
  Future<Result<List<DhikrItem>>> searchDhikr(String query) async =>
      Success(_items);

  @override
  Future<Result<int>> insertDhikrItem(DhikrItem item) async => const Success(1);

  @override
  Future<Result<int>> updateDhikrItem(DhikrItem item) async => const Success(1);

  @override
  Future<Result<int>> deleteDhikrItem(int id) async => const Success(1);

  @override
  Future<Result<List<ParentCategory>>> getAllCategories() async =>
      Success(_parents);

  @override
  Future<Result<ParentCategory>> getCategoryById(int id) async =>
      Success(_parents.firstWhere((p) => p.id == id));

  @override
  Future<Result<List<DhikrItem>>> getDhikrItemsByCategory(int categoryId) async =>
      Success(_items.where((i) => i.subCategoryId == categoryId).toList());

  @override
  Future<Result<Map<int, int>>> getCategoryItemCounts() async =>
      const Success({1: 2, 2: 1});

  @override
  Future<Result<int>> deleteCategory(int id) async => const Success(1);

  @override
  Future<Result<int>> insertCategory(ParentCategory category) async =>
      const Success(1);

  @override
  Future<Result<int>> updateCategory(ParentCategory category) async =>
      const Success(1);
}

void main() {
  late SearchCubit searchCubit;
  late _MockDhikrRepository mockRepo;

  setUp(() async {
    mockRepo = _MockDhikrRepository();
    searchCubit = SearchCubit(mockRepo);
    await searchCubit.initIndex();
  });

  tearDown(() {
    searchCubit.close();
  });

  group('SearchCubit Tests', () {
    test('initial state has empty query and isSearching is false', () {
      expect(searchCubit.state.query, '');
      expect(searchCubit.state.isSearching, isFalse);
      expect(searchCubit.state.totalMatches, 0);
    });

    test(
        'searches unvocalized query and matches vocalized sub-category and items',
        () {
      // Query for chapter name without Tashkeel
      searchCubit.search('الصباح');
      expect(searchCubit.state.isSearching, isTrue);
      expect(searchCubit.state.matchingSubCategories.length, 1);
      expect(searchCubit.state.matchingSubCategories.first.title,
          'أَذْكَارُ الصَّبَاحِ وَالْمَسَاءِ');

      // Query for item content without Tashkeel and with normalized Alif
      searchCubit.search('اصبحنا');
      expect(searchCubit.state.isSearching, isTrue);
      expect(searchCubit.state.matchingDhikrItems.length, 1);
      expect(searchCubit.state.matchingDhikrItems.first.item.content,
          contains('أَصْبَحْنَا'));
    });

    test('matches parent category as well', () {
      searchCubit.search('اليوم والليله'); // unvocalized query
      expect(searchCubit.state.isSearching, isTrue);
      expect(searchCubit.state.matchingCategories.length, 1);
      expect(searchCubit.state.matchingCategories.first.name, 'اليوم والليلة');
    });

    test('matches footnote text as well', () {
      searchCubit.search('مغفره'); // unvocalized search for 'مغفرة الذنوب'

      expect(searchCubit.state.matchingDhikrItems.length, 1);
      expect(searchCubit.state.matchingDhikrItems.first.item.footnote,
          contains('مغفرة الذنوب'));
    });

    test('clearSearch resets query and results', () {
      searchCubit.search('الصباح');
      expect(searchCubit.state.isSearching, isTrue);

      searchCubit.clearSearch();
      expect(searchCubit.state.query, '');
      expect(searchCubit.state.isSearching, isFalse);
      expect(searchCubit.state.totalMatches, 0);
    });
  });
}
