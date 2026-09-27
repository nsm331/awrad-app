import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/parent_category.dart';
import '../../../domain/entities/sub_category.dart';
import '../../blocs/category/category_cubit.dart';
import '../../blocs/category/category_state.dart';
import '../../blocs/search/search_cubit.dart';
import '../../blocs/search/search_state.dart';
import '../dhikr/dhikr_reading_screen.dart';
import 'sub_category_list_screen.dart';

/// Screen displaying the grid of Hisn al-Muslim Parent Categories from SQLite,
/// along with offline real-time search with Arabic Tashkeel normalization.
class AdhkarCategoriesScreen extends StatefulWidget {
  const AdhkarCategoriesScreen({super.key});

  @override
  State<AdhkarCategoriesScreen> createState() => _AdhkarCategoriesScreenState();
}

class _AdhkarCategoriesScreenState extends State<AdhkarCategoriesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CategoryCubit>().loadCategories();
        context.read<SearchCubit>().initIndex();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  IconData _resolveIcon(String iconName) {
    return switch (iconName) {
      'all_inclusive' => Icons.all_inclusive_rounded,
      'nights_stay' => Icons.nights_stay_rounded,
      'home' => Icons.home_rounded,
      'mosque' => Icons.mosque_rounded,
      'restaurant' => Icons.restaurant_rounded,
      'flight_takeoff' => Icons.flight_takeoff_rounded,
      'sentiment_very_satisfied' => Icons.sentiment_very_satisfied_rounded,
      'explore' => Icons.explore_rounded,
      'healing' => Icons.healing_rounded,
      'people' => Icons.people_rounded,
      'wb_cloudy' => Icons.wb_cloudy_rounded,
      'stars' => Icons.stars_rounded,
      _ => Icons.auto_stories_rounded,
    };
  }

  void _openParentCategory(BuildContext context, ParentCategory category) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => SubCategoryListScreen(parentCategory: category),
      ),
    );
  }

  void _openSubCategoryReader(
    BuildContext context,
    SubCategory subCategory, {
    int? targetDhikrId,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => DhikrReadingScreen(
          subCategory: subCategory,
          targetDhikrId: targetDhikrId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              await context.read<CategoryCubit>().loadCategories();
              if (context.mounted) {
                await context.read<SearchCubit>().initIndex();
              }
            },
            child: CustomScrollView(
              slivers: [
                // ── App Bar / Header ──────────────────────────────────────────
                SliverAppBar(
                  floating: true,
                  snap: true,
                  elevation: 0,
                  scrolledUnderElevation: 2,
                  toolbarHeight: 70,
                  title: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppTheme.emeraldPrimary.withAlpha(50)
                              : AppTheme.emeraldPrimary.withAlpha(25),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? AppTheme.goldAccent.withAlpha(80) : Colors.transparent,
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.menu_book_rounded,
                          color: AppTheme.goldAccent,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'أَوْرَاد',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            'حِصْنُ المُسْلِمِ مِن أَذْكَارِ الكِتَابِ وَالسُّنَّةِ',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Diacritics-Agnostic Search Bar ───────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: SearchBar(
                      controller: _searchController,
                      hintText: 'ابحث في الأذكار أو الأبواب بدون تشكيل...',
                      leading: const Icon(Icons.search_rounded),
                      trailing: [
                        if (_searchController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
                              context.read<SearchCubit>().clearSearch();
                            },
                          ),
                      ],
                      onChanged: (val) {
                        context.read<SearchCubit>().search(val);
                      },
                      elevation: const WidgetStatePropertyAll(1),
                      backgroundColor: WidgetStatePropertyAll(
                        isDark ? AppTheme.darkSurfaceVariant : AppTheme.lightSurfaceVariant,
                      ),
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Dynamic Body: Search Results or Category Grid ─────────────
                BlocBuilder<SearchCubit, SearchState>(
                  builder: (context, searchState) {
                    if (searchState.isSearching) {
                      return _buildSearchResults(context, searchState);
                    }

                    // Default Home View
                    return _buildDefaultCategoriesView(context, isDark, theme);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context, SearchState searchState) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (searchState.totalMatches == 0) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.search_off_rounded,
                  size: 56,
                  color: AppTheme.goldAccent,
                ),
                const SizedBox(height: 16),
                Text(
                  'لا توجد نتائج مطابقة لـ «${searchState.query}»',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'جرب البحث بكلمات أخرى أو بدون تشكيل.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          // ── Matching Sub-Categories (Chapters) ───────────────────────────
          if (searchState.matchingSubCategories.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.folder_open_rounded, size: 18, color: AppTheme.goldAccent),
                  const SizedBox(width: 8),
                  Text(
                    'الأبواب المطابقة (${searchState.matchingSubCategories.length})',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppTheme.goldLight : AppTheme.emeraldPrimary,
                    ),
                  ),
                ],
              ),
            ),
            ...searchState.matchingSubCategories.map((subCat) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppTheme.emeraldPrimary.withAlpha(50)
                          : AppTheme.emeraldPrimary.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      color: AppTheme.goldAccent,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    subCat.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${subCat.dhikrCount} ذِكر',
                    style: theme.textTheme.labelSmall,
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: () => _openSubCategoryReader(context, subCat),
                ),
              );
            }),
            const SizedBox(height: 12),
          ],

          // ── Matching Dhikr Items ──────────────────────────────────────────
          if (searchState.matchingDhikrItems.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.auto_stories_rounded, size: 18, color: AppTheme.emeraldLight),
                  const SizedBox(width: 8),
                  Text(
                    'الأذكار المطابقة (${searchState.matchingDhikrItems.length})',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppTheme.goldLight : AppTheme.emeraldPrimary,
                    ),
                  ),
                ],
              ),
            ),
            ...searchState.matchingDhikrItems.map((result) {
              final item = result.item;
              final subCat = result.subCategory;

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _openSubCategoryReader(
                    context,
                    subCat,
                    targetDhikrId: item.id,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppTheme.darkSurfaceVariant
                                    : AppTheme.lightSurfaceVariant,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                subCat.title,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: isDark
                                      ? AppTheme.goldLight
                                      : AppTheme.emeraldPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              'التكرار: ${item.repeatCount} مرات',
                              style: theme.textTheme.labelSmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.content,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.6,
                            fontFamily: 'Amiri',
                            fontSize: 15,
                          ),
                        ),
                        if (item.footnote.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            item.footnote,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: isDark
                                  ? AppTheme.darkTextSecondary
                                  : AppTheme.lightTextSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ]),
      ),
    );
  }

  Widget _buildDefaultCategoriesView(
    BuildContext context,
    bool isDark,
    ThemeData theme,
  ) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          // Section Title
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'أقسام الأذكار',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                BlocBuilder<CategoryCubit, CategoryState>(
                  builder: (context, state) {
                    if (state is CategoryLoaded) {
                      return Text(
                        '${state.categories.length} أقسام رئيسية',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? AppTheme.goldLight : AppTheme.emeraldPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),

          // Categories Grid
          BlocBuilder<CategoryCubit, CategoryState>(
            builder: (context, state) {
              return switch (state) {
                CategoryInitial() || CategoryLoading() => const Padding(
                    padding: EdgeInsets.all(48.0),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                CategoryError(:final message) => Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent),
                          const SizedBox(height: 12),
                          Text(
                            message,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: () => context.read<CategoryCubit>().loadCategories(force: true),
                            child: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    ),
                  ),
                CategoryLoaded(:final categories) => GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.05,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return _ParentCategoryCard(
                        category: category,
                        icon: _resolveIcon(category.iconName),
                        onTap: () => _openParentCategory(context, category),
                      );
                    },
                  ),
              };
            },
          ),
        ]),
      ),
    );
  }
}

class _ParentCategoryCard extends StatelessWidget {
  final ParentCategory category;
  final IconData icon;
  final VoidCallback onTap;

  const _ParentCategoryCard({
    required this.category,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Row: Icon Container + Chapter Count Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppTheme.emeraldPrimary.withAlpha(60)
                          : AppTheme.emeraldPrimary.withAlpha(25),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark
                            ? AppTheme.goldAccent.withAlpha(80)
                            : AppTheme.emeraldPrimary.withAlpha(40),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: isDark ? AppTheme.goldLight : AppTheme.emeraldPrimary,
                      size: 24,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppTheme.darkSurfaceVariant
                          : AppTheme.lightSurfaceVariant,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${category.subCategoryCount} باب',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isDark ? AppTheme.goldLight : AppTheme.emeraldPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Arabic Category Name
              Text(
                category.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  height: 1.35,
                ),
              ),

              const SizedBox(height: 4),

              // Total Dhikr Count e.g. "42 ذكر"
              Row(
                children: [
                  Icon(
                    Icons.format_list_numbered_rounded,
                    size: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${category.totalDhikrCount} ذِكراً',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
