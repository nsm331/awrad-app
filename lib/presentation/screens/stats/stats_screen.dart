import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../blocs/stats/stats_cubit.dart';
import '../../blocs/stats/stats_state.dart';

/// Screen displaying Dhikr streaks, completion milestones, and 30-day activity heatmap.
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
                        style: theme.textTheme.bodyMedium,
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
                      :final heatmap,
                    ) =>
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            // ── Top Summary Cards ───────────────────────────
                            Row(
                              children: [
                                Expanded(
                                  child: _StatMetricCard(
                                    title: 'السلسلة الحالية',
                                    value: '$currentStreak',
                                    unit: 'أيام',
                                    icon: Icons.local_fire_department_rounded,
                                    iconColor: const Color(0xFFE76F51),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _StatMetricCard(
                                    title: 'أطول سلسلة',
                                    value: '$longestStreak',
                                    unit: 'أيام',
                                    icon: Icons.emoji_events_rounded,
                                    iconColor: AppTheme.goldAccent,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Total completions wide card
                            _StatMetricCard(
                              title: 'إجمالي جلسات الأذكار المكتملة',
                              value: '$totalCompletions',
                              unit: 'جلسة مباركة',
                              icon: Icons.task_alt_rounded,
                              iconColor: AppTheme.emeraldLight,
                              isWide: true,
                            ),

                            const SizedBox(height: 16),

                            // ── Visual 7-Day Weekly Completion Matrix ───────
                            _WeeklyMatrixCard(heatmap: heatmap),

                            const SizedBox(height: 16),

                            // ── 30-Day Heatmap Card ─────────────────────────
                            _HeatmapCard(heatmap: heatmap),

                            const SizedBox(height: 20),

                            // ── Inspirational Quranic Card ───────────────────
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

class _StatMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color iconColor;
  final bool isWide;

  const _StatMetricCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.iconColor,
    this.isWide = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: isWide
            ? Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: iconColor.withAlpha(isDark ? 50 : 30),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: iconColor, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              value,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppTheme.goldLight : AppTheme.emeraldPrimary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              unit,
                              style: theme.textTheme.labelSmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: iconColor.withAlpha(isDark ? 50 : 30),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: iconColor, size: 24),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        value,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppTheme.goldLight : AppTheme.emeraldPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        unit,
                        style: theme.textTheme.labelSmall,
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}

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

class _WeeklyMatrixCard extends StatelessWidget {
  final Map<String, int> heatmap;

  const _WeeklyMatrixCard({required this.heatmap});

  static const _arabicDays = {
    1: 'الإثنين',
    2: 'الثلاثاء',
    3: 'الأربعاء',
    4: 'الخميس',
    5: 'الجمعة',
    6: 'السبت',
    7: 'الأحد',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Generate 7 days (from 6 days ago up to today)
    final days = List.generate(7, (i) {
      final date = today.subtract(Duration(days: 6 - i));
      final dateStr =
          '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final count = heatmap[dateStr] ?? 0;
      final isToday = date.day == today.day && date.month == today.month && date.year == today.year;
      return (
        date: date,
        dayName: _arabicDays[date.weekday] ?? '',
        dateLabel: '${date.day}/${date.month}',
        count: count,
        isToday: isToday,
      );
    });

    int completedDaysCount = days.where((d) => d.count > 0).length;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(18),
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
                    color: completedDaysCount > 0
                        ? Colors.green.withValues(alpha: 0.15)
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$completedDaysCount / 7 أيام',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: completedDaysCount > 0 ? Colors.green.shade700 : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 7 Days Horizontal Matrix
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: days.map((d) {
                final isDone = d.count > 0;

                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
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
                                : Colors.transparent,
                        width: d.isToday ? 1.5 : 1.0,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          d.dayName,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: d.isToday ? FontWeight.bold : FontWeight.w500,
                            color: d.isToday
                                ? (isDark ? AppTheme.goldLight : AppTheme.emeraldPrimary)
                                : colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          d.dateLabel,
                          style: TextStyle(
                            fontSize: 10,
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: isDone
                                ? Colors.green
                                : (isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.06)),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: isDone
                                ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                                : const Text('-', style: TextStyle(color: Colors.grey, fontSize: 16)),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isDone ? '${d.count}' : '0',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isDone ? Colors.green : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
