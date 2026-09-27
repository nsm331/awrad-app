import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/parent_category.dart';
import '../../../domain/entities/sub_category.dart';
import '../../../domain/repositories/dhikr_repository.dart';
import '../../../domain/repositories/statistics_repository.dart';
import '../../blocs/sub_category/sub_category_cubit.dart';
import '../../blocs/sub_category/sub_category_state.dart';
import '../../blocs/theme/theme_cubit.dart';
import '../dhikr/dhikr_reading_screen.dart';

/// Screen displaying the list of specific chapters / sub-categories
/// under a selected [ParentCategory] (e.g. inside "البيت والأهل").
class SubCategoryListScreen extends StatelessWidget {
  final ParentCategory parentCategory;

  const SubCategoryListScreen({
    super.key,
    required this.parentCategory,
  });

  IconData _resolveIcon(String iconName) {
    return switch (iconName) {
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
      'all_inclusive' => Icons.all_inclusive_rounded,
      _ => Icons.auto_stories_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => SubCategoryCubit(
        dhikrRepository: ctx.read<DhikrRepository>(),
        statisticsRepository: ctx.read<StatisticsRepository>(),
      )..loadSubCategories(parentCategory.id),
      child: _SubCategoryListView(
        parentCategory: parentCategory,
        iconData: _resolveIcon(parentCategory.iconName),
      ),
    );
  }
}

class _SubCategoryListView extends StatefulWidget {
  final ParentCategory parentCategory;
  final IconData iconData;

  const _SubCategoryListView({
    required this.parentCategory,
    required this.iconData,
  });

  @override
  State<_SubCategoryListView> createState() => _SubCategoryListViewState();
}

class _SubCategoryListViewState extends State<_SubCategoryListView> {
  final TextEditingController _filterController = TextEditingController();
  String _filterQuery = '';

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  Future<void> _openChapter(BuildContext context, SubCategory chapter) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DhikrReadingScreen(
          subCategory: chapter,
          parentCategory: widget.parentCategory,
        ),
      ),
    );

    if (context.mounted) {
      context.read<SubCategoryCubit>().refreshCompletions();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.parentCategory.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: BlocBuilder<SubCategoryCubit, SubCategoryState>(
          builder: (context, state) {
            return switch (state) {
              SubCategoryInitial() || SubCategoryLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
              SubCategoryError(:final message) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline_rounded, size: 48, color: colorScheme.error),
                        const SizedBox(height: 16),
                        Text(message, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () => context
                              .read<SubCategoryCubit>()
                              .loadSubCategories(widget.parentCategory.id),
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  ),
                ),
              SubCategoryLoaded(
                :final subCategories,
                :final completedTodayIds,
              ) =>
                _buildListContent(
                  context,
                  subCategories,
                  completedTodayIds,
                  colorScheme,
                  isDark,
                ),
            };
          },
        ),
      ),
    );
  }

  Widget _buildListContent(
    BuildContext context,
    List<SubCategory> subCategories,
    Set<int> completedTodayIds,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final filtered = _filterQuery.isEmpty
        ? subCategories
        : subCategories
            .where((s) => s.title.toLowerCase().contains(_filterQuery.toLowerCase()))
            .toList();

    return Column(
      children: [
        // ── Parent Header Hero ─────────────────────────────────────────────
        Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [colorScheme.surfaceContainerHigh, colorScheme.surfaceContainer]
                  : [colorScheme.primaryContainer, colorScheme.primaryContainer.withValues(alpha: 0.7)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white10 : colorScheme.primary.withValues(alpha: 0.15),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isDark ? colorScheme.primary.withValues(alpha: 0.2) : Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.iconData,
                  size: 28,
                  color: isDark ? colorScheme.primary : colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.parentCategory.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${subCategories.length} أبواب • ${widget.parentCategory.totalDhikrCount} ذِكر',
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Chapter Filter Input ───────────────────────────────────────────
        if (subCategories.length > 5) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              controller: _filterController,
              onChanged: (val) => setState(() => _filterQuery = val.trim()),
              decoration: InputDecoration(
                hintText: 'ابحث في أبواب هذا القسم...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _filterQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _filterController.clear();
                          setState(() => _filterQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: isDark
                    ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.4)
                    : colorScheme.surfaceContainerLow,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],

        // ── Chapter Cards List ─────────────────────────────────────────────
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Text(
                    'لا توجد أبواب مطابقة للبحث',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final chapter = filtered[index];
                    final isCompleted = completedTodayIds.contains(chapter.id);

                    return _ChapterCard(
                      chapter: chapter,
                      isCompleted: isCompleted,
                      onTap: () => _openChapter(context, chapter),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _ChapterCard extends StatelessWidget {
  final SubCategory chapter;
  final bool isCompleted;
  final VoidCallback onTap;

  const _ChapterCard({
    required this.chapter,
    required this.isCompleted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final fontSettings = context.watch<ThemeCubit>().state;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isDark ? colorScheme.surfaceContainer : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isCompleted
                  ? Colors.green.withValues(alpha: 0.5)
                  : isDark
                      ? Colors.white10
                      : colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: isCompleted ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Index Badge or Completion checkmark
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.green.withValues(alpha: 0.15)
                      : isDark
                          ? colorScheme.primary.withValues(alpha: 0.15)
                          : colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check_circle_rounded, color: Colors.green, size: 22)
                      : Text(
                          '${chapter.orderIndex}',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 14),

              // Chapter Title & Item Count
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chapter.title,
                      style: TextStyle(
                        fontFamily: fontSettings.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark
                                ? colorScheme.surfaceContainerHighest
                                : colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${chapter.dhikrCount} ذِكر',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        if (isCompleted) ...[
                          const SizedBox(width: 8),
                          Text(
                            'اكتمل اليوم',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
