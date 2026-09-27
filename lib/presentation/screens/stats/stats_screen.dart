import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/category_completion_stat.dart';
import '../../../domain/entities/weekly_day_matrix.dart';
import '../../blocs/stats/stats_cubit.dart';
import '../../blocs/stats/stats_state.dart';

/// Screen displaying Dhikr streaks, completion milestones, weekly tracker,
/// top completed categories, and a 30-day activity heatmap.
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<StatsCubit>().loadStats(),
          color: AppTheme.emeraldPrimary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // ── Header Title ──────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'إِحْصَائِيَّاتُ الْأَوْرَادِ',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppTheme.goldLight : AppTheme.emeraldPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'تابع إنجازك اليومي وثباتك على ذكر الله تعالى',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? AppTheme.darkTextSecondary
                              : AppTheme.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Stats Content ─────────────────────────────────────────────
              BlocBuilder<StatsCubit, StatsState>(
                builder: (context, state) {
                  return switch (state) {
                    StatsInitial() || StatsLoading() => const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.emeraldPrimary,
                          ),
                        ),
                      ),
                    StatsError(:final message) => SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Text(message, style: theme.textTheme.bodyMedium),
                        ),
                      ),
                    StatsLoaded(
                      :final currentStreak,
                      :final longestStreak,
                      :final totalCompletions,
                      :final totalCompletedSubCategories,
                      :final activeDayRate,
                      :final topSubCategories,
                      :final weeklyMatrix,
                      :final heatmap,
                    ) =>
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            // ── 1. Hero Streak Badge ────────────────────────
                            _HeroStreakBadge(currentStreak: currentStreak),

                            const SizedBox(height: 16),

                            // ── 2. Two-Column Stat Cards (2 x 2) ────────────
                            Row(
                              children: [
                                Expanded(
                                  child: _StatMetricCard(
                                    title: 'إجمالي الجلسات',
                                    value: '$totalCompletions',
                                    unit: 'جلسة مباركة',
                                    icon: Icons.task_alt_rounded,
                                    iconColor: AppTheme.emeraldLight,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _StatMetricCard(
                                    title: 'الأبواب المنجزة',
                                    value: '$totalCompletedSubCategories',
                                    unit: 'أبواب مختلفة',
                                    icon: Icons.auto_stories_rounded,
                                    iconColor: const Color(0xFF2A9D8F),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _StatMetricCard(
                                    title: 'معدل الالتزام',
                                    value: '${activeDayRate.toStringAsFixed(activeDayRate % 1 == 0 ? 0 : 1)}%',
                                    unit: 'نسبة النشاط',
                                    icon: Icons.trending_up_rounded,
                                    iconColor: const Color(0xFF264653),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _StatMetricCard(
                                    title: 'أطول سلسلة',
                                    value: '$longestStreak',
                                    unit: 'أيام قياسية',
                                    icon: Icons.emoji_events_rounded,
                                    iconColor: AppTheme.goldAccent,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // ── 3. Visual 7-Day Arabic Weekly Matrix ────────
                            _WeeklyMatrixCard(weeklyMatrix: weeklyMatrix),

                            const SizedBox(height: 16),

                            // ── 4. Top 3 Most Completed Categories ──────────
                            _TopCategoriesCard(topCategories: topSubCategories),

                            const SizedBox(height: 16),

                            // ── 5. 30-Day Heatmap Card ──────────────────────
                            _HeatmapCard(heatmap: heatmap),

                            const SizedBox(height: 20),

                            // ── 6. Inspirational Quranic Card ───────────────
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppTheme.darkSurfaceVariant
                                    : AppTheme.lightSurfaceVariant,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isDark
                                      ? AppTheme.goldAccent.withAlpha(40)
                                      : AppTheme.emeraldPrimary.withAlpha(30),
                                ),
                              ),
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.auto_awesome_rounded,
                                    color: AppTheme.goldAccent,
                                    size: 28,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    '﴿ وَالذَّاكِرِينَ اللَّهَ كَثِيرًا وَالذَّاكِرَاتِ أَعَدَّ اللَّهُ لَهُمْ مَغْفِرَةً وَأَجْرًا عَظِيمًا ﴾',
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: isDark
                                          ? AppTheme.goldLight
                                          : AppTheme.emeraldPrimary,
                                      fontWeight: FontWeight.bold,
                                      height: 1.6,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'سورة الأحزاب: 35',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: isDark
                                          ? AppTheme.darkTextSecondary
                                          : AppTheme.lightTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 32),
                          ]),
                        ),
                      ),
                  };
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. Hero Streak Badge
// ─────────────────────────────────────────────────────────────────────────────

class _HeroStreakBadge extends StatelessWidget {
  final int currentStreak;

  const _HeroStreakBadge({required this.currentStreak});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasStreak = currentStreak > 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: isDark
              ? [
                  AppTheme.emeraldDark,
                  const Color(0xFF132F23),
                  AppTheme.darkSurfaceVariant,
                ]
              : [
                  AppTheme.emeraldPrimary,
                  const Color(0xFF1E6F4A),
                  AppTheme.emeraldDark,
                ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? AppTheme.goldAccent.withValues(alpha: 0.3)
              : AppTheme.goldAccent.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : AppTheme.emeraldPrimary).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top pill label
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.goldAccent.withValues(alpha: 0.4),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: hasStreak ? const Color(0xFFFF9F1C) : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'السلسلة الحالية',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.goldLight,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.local_fire_department_rounded,
                color: Color(0xFFFF9F1C),
                size: 26,
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Main streak count & title
          if (hasStreak) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '$currentStreak',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Amiri',
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  currentStreak == 1
                      ? 'يوم متواصل'
                      : currentStreak == 2
                          ? 'يومان متواصلان'
                          : currentStreak <= 10
                              ? 'أيام متتالية'
                              : 'يوماً متتالياً',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.goldLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'ثباتٌ مبارك! استمر في المحافظة على وردك اليومي لتبقى شعلة الذكر متقدة.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.4,
              ),
            ),
          ] else ...[
            Text(
              'ابدأ سلسلتك المباركة اليوم',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'أكمل ورد الصباح أو المساء لتشعل شعلة الاستمرارية وتسجل أول يوم في سلسلتك.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. Stat Metric Card (2-Column)
// ─────────────────────────────────────────────────────────────────────────────

class _StatMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color iconColor;

  const _StatMetricCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: isDark ? 0.25 : 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.goldLight : AppTheme.emeraldPrimary,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    unit,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isDark
                          ? AppTheme.darkTextSecondary.withValues(alpha: 0.8)
                          : AppTheme.lightTextSecondary.withValues(alpha: 0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. Visual 7-Day Arabic Weekly Matrix
// ─────────────────────────────────────────────────────────────────────────────

class _WeeklyMatrixCard extends StatelessWidget {
  final List<WeeklyDayData> weeklyMatrix;

  const _WeeklyMatrixCard({required this.weeklyMatrix});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final completedCount = weeklyMatrix.where((d) => d.status == WeeklyDayStatus.completed).length;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_view_week_rounded, color: AppTheme.goldAccent, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'مصفوفة الإنجاز الأسبوعي',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: completedCount > 0
                        ? Colors.green.withValues(alpha: 0.15)
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$completedCount / 7 أيام',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: completedCount > 0 ? Colors.green.shade700 : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 7 Days Horizontal Row (Saturday to Friday)
            if (weeklyMatrix.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('جاري تحميل بيانات الأسبوع...'),
                ),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: weeklyMatrix.map((d) {
                  final isDone = d.status == WeeklyDayStatus.completed;
                  final isIncomplete = d.status == WeeklyDayStatus.incomplete;
                  final isMissed = d.status == WeeklyDayStatus.missed;
                  final isFuture = d.status == WeeklyDayStatus.future;

                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                      decoration: BoxDecoration(
                        color: d.isToday
                            ? (isDark
                                ? AppTheme.goldAccent.withValues(alpha: 0.15)
                                : AppTheme.goldAccent.withValues(alpha: 0.12))
                            : (isDark
                                ? colorScheme.surfaceContainer
                                : colorScheme.surfaceContainerLow),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: d.isToday
                              ? AppTheme.goldAccent
                              : isDone
                                  ? Colors.green.withValues(alpha: 0.4)
                                  : isMissed
                                      ? Colors.red.withValues(alpha: 0.25)
                                      : Colors.transparent,
                          width: d.isToday ? 1.5 : 1.0,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            d.dayName,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: d.isToday ? FontWeight.bold : FontWeight.w500,
                              color: d.isToday
                                  ? (isDark ? AppTheme.goldLight : AppTheme.emeraldPrimary)
                                  : colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            d.dateLabel,
                            style: TextStyle(
                              fontSize: 9,
                              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: isDone
                                  ? Colors.green
                                  : isIncomplete
                                      ? const Color(0xFFFF9F1C).withValues(alpha: 0.2)
                                      : isMissed
                                          ? Colors.red.withValues(alpha: 0.15)
                                          : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                              shape: BoxShape.circle,
                              border: isIncomplete
                                  ? Border.all(color: const Color(0xFFFF9F1C), width: 1.2)
                                  : null,
                            ),
                            child: Center(
                              child: isDone
                                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 15)
                                  : isIncomplete
                                      ? const Icon(Icons.hourglass_empty_rounded, color: Color(0xFFFF9F1C), size: 14)
                                      : isMissed
                                          ? const Icon(Icons.remove_rounded, color: Colors.redAccent, size: 14)
                                          : const Text('•', style: TextStyle(color: Colors.grey, fontSize: 14)),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isDone
                                ? '${d.count}'
                                : isIncomplete
                                    ? 'اليوم'
                                    : isMissed
                                        ? 'فائت'
                                        : '-',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
                              color: isDone
                                  ? Colors.green
                                  : isIncomplete
                                      ? const Color(0xFFFF9F1C)
                                      : isMissed
                                          ? Colors.red.shade400
                                          : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: 12),

            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _legendItem(Colors.green, 'مكتمل', theme),
                const SizedBox(width: 14),
                _legendItem(const Color(0xFFFF9F1C), 'قيد الانتظار', theme),
                const SizedBox(width: 14),
                _legendItem(Colors.redAccent, 'فائت', theme),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(Color color, String label, ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(fontSize: 10),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. Top 3 Most Completed Categories
// ─────────────────────────────────────────────────────────────────────────────

class _TopCategoriesCard extends StatelessWidget {
  final List<CategoryCompletionStat> topCategories;

  const _TopCategoriesCard({required this.topCategories});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.workspace_premium_rounded, color: AppTheme.goldAccent, size: 22),
                const SizedBox(width: 8),
                Text(
                  'الأوراد الأكثر إنجازاً',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'أكثر الأبواب التي داومت على قراءتها وختمها',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 14),

            if (topCategories.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkSurfaceVariant : AppTheme.lightSurfaceVariant,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.menu_book_rounded,
                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'لم تسجل أي ختمات بعد',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ابدأ بقراءة أذكار الصباح والمساء لتظهر إحصائياتك هنا.',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else ...[
              // Highest count for ratio calculation
              ...topCategories.asMap().entries.map((entry) {
                final index = entry.key;
                final stat = entry.value;
                final maxCount = topCategories.first.completionCount;
                final ratio = maxCount > 0 ? (stat.completionCount / maxCount).clamp(0.05, 1.0) : 1.0;

                final Color medalColor;
                final String medalBadge;
                if (index == 0) {
                  medalColor = const Color(0xFFFFD700); // Gold
                  medalBadge = 'الأول';
                } else if (index == 1) {
                  medalColor = const Color(0xFFC0C0C0); // Silver
                  medalBadge = 'الثاني';
                } else {
                  medalColor = const Color(0xFFCD7F32); // Bronze
                  medalBadge = 'الثالث';
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppTheme.darkSurfaceVariant
                          : AppTheme.lightSurfaceVariant,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: medalColor.withValues(alpha: 0.3),
                        width: 1.0,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: medalColor.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                                border: Border.all(color: medalColor, width: 1.2),
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                stat.title,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppTheme.emeraldPrimary.withValues(alpha: isDark ? 0.3 : 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${stat.completionCount} ختمة',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppTheme.goldLight : AppTheme.emeraldPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: ratio,
                            minHeight: 5,
                            backgroundColor: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
                            color: medalColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 5. 30-Day Activity Heatmap
// ─────────────────────────────────────────────────────────────────────────────

class _HeatmapCard extends StatelessWidget {
  final Map<String, int> heatmap;

  const _HeatmapCard({required this.heatmap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Generate last 28 days for clean 4 rows x 7 columns grid
    final today = DateTime.now();
    final days = List.generate(28, (index) {
      final date = today.subtract(Duration(days: 27 - index));
      final dateStr =
          '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final count = heatmap[dateStr] ?? 0;
      return (date: date, count: count);
    });

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'نشاط الأذكار (آخر 28 يوماً)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'مخطط الالتزام',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.goldAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 7 Columns x 4 Rows
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 28,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.0,
              ),
              itemBuilder: (context, index) {
                final item = days[index];
                final count = item.count;

                final Color cellColor;
                if (count == 0) {
                  cellColor = isDark
                      ? AppTheme.darkSurfaceVariant
                      : const Color(0xFFECE8E0);
                } else if (count == 1) {
                  cellColor = isDark
                      ? const Color(0xFF2A5946)
                      : const Color(0xFF88C9A1);
                } else if (count == 2) {
                  cellColor = isDark
                      ? const Color(0xFF387A5E)
                      : const Color(0xFF4FA878);
                } else {
                  cellColor = isDark
                      ? AppTheme.goldAccent
                      : AppTheme.emeraldPrimary;
                }

                return Tooltip(
                  message:
                      '${item.date.year}/${item.date.month}/${item.date.day}: $count ختمة',
                  child: Container(
                    decoration: BoxDecoration(
                      color: cellColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 14),

            // Legend Row
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('أقل', style: theme.textTheme.labelSmall),
                const SizedBox(width: 6),
                _legendDot(isDark ? AppTheme.darkSurfaceVariant : const Color(0xFFECE8E0)),
                const SizedBox(width: 4),
                _legendDot(isDark ? const Color(0xFF2A5946) : const Color(0xFF88C9A1)),
                const SizedBox(width: 4),
                _legendDot(isDark ? const Color(0xFF387A5E) : const Color(0xFF4FA878)),
                const SizedBox(width: 4),
                _legendDot(isDark ? AppTheme.goldAccent : AppTheme.emeraldPrimary),
                const SizedBox(width: 6),
                Text('أكثر', style: theme.textTheme.labelSmall),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendDot(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
