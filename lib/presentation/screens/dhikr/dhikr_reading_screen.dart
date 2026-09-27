import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/sound_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/share_helper.dart';
import '../../../domain/entities/parent_category.dart';
import '../../../domain/entities/sub_category.dart';
import '../../blocs/dhikr/dhikr_bloc.dart';
import '../../blocs/dhikr/dhikr_event.dart';
import '../../blocs/dhikr/dhikr_state.dart';
import '../../blocs/settings/settings_cubit.dart';
import '../../blocs/theme/theme_cubit.dart';
import '../../widgets/dhikr/dhikr_card.dart';

/// Screen providing the focused Dhikr reader strictly scoped to a selected chapter,
/// interactive repetition counter, Arabic Tashkeel typography, Takhrij footnotes,
/// RepaintBoundary image export, text sharing, and exit confirmation guard.
class DhikrReadingScreen extends StatefulWidget {
  final SubCategory? subCategory;
  final int? subCategoryId;
  final ParentCategory? parentCategory;
  final int? targetDhikrId;
  final int initialIndex;

  const DhikrReadingScreen({
    super.key,
    this.subCategory,
    this.subCategoryId,
    this.parentCategory,
    this.targetDhikrId,
    this.initialIndex = 0,
  });

  @override
  State<DhikrReadingScreen> createState() => _DhikrReadingScreenState();
}

class _DhikrReadingScreenState extends State<DhikrReadingScreen> {
  final GlobalKey _dhikrCardKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final effectiveSubCategoryId =
          widget.subCategory?.id ?? widget.subCategoryId;
      if (effectiveSubCategoryId != null) {
        context.read<DhikrBloc>().add(
              LoadDhikrList(
                effectiveSubCategoryId,
                subCategory: widget.subCategory,
                targetDhikrId: widget.targetDhikrId,
                initialIndex: widget.initialIndex,
              ),
            );
      }
    });
  }

  Future<bool> _onWillPop(BuildContext context, DhikrState state) async {
    // If the session is already completed, allow exiting directly without dialog
    if (state.isSetCompleted) {
      return true;
    }

    // Show exit confirmation guard dialog
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent),
              const SizedBox(width: 8),
              Text(
                'تأكيد الخروج',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'هل أنت متأكد من الخروج؟ سيتم إعادة ضبط تقدم الورد الحالي.',
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('متابعة الورد'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                context.read<DhikrBloc>().add(const ResetDhikrSession());
                Navigator.pop(dialogContext, true);
              },
              child: const Text('خروج'),
            ),
          ],
        );
      },
    );

    return shouldExit ?? false;
  }

  void _onTapCounter(BuildContext context, DhikrState state) {
    if (state.isSetCompleted) return;

    final settings = context.read<SettingsCubit>().state;

    // Trigger audio click feedback if enabled
    if (settings.soundEnabled) {
      SoundService.instance.playClickSound();
    }

    // Trigger haptic feedback if enabled
    if (settings.hapticEnabled) {
      final willCompleteItem =
          (state.currentCounter + 1) >= (state.currentItem?.repeatCount ?? 1);
      if (willCompleteItem) {
        HapticFeedback.mediumImpact();
      } else {
        HapticFeedback.lightImpact();
      }
    }

    context.read<DhikrBloc>().add(const IncrementCounter());
  }

  void _openShareModal(BuildContext context, DhikrState state) {
    final item = state.currentItem;
    if (item == null) return;

    final chapterName = state.subCategory?.title ?? item.subCategoryTitle;
    final parentName = widget.parentCategory?.name ?? state.category?.name ?? 'أَوْرَاد';

    ShareHelper.showShareModal(
      context,
      boundaryKey: _dhikrCardKey,
      categoryName: '$parentName • $chapterName',
      content: item.content,
      repeatCount: item.repeatCount,
      subCategory: chapterName,
      fadl: item.effectiveFadl,
      source: item.effectiveSource,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<DhikrBloc, DhikrState>(
      listener: (context, state) {
        // Show celebratory dialog when all items in the chapter are completed
        if (state.isSetCompleted) {
          final settings = context.read<SettingsCubit>().state;
          if (settings.hapticEnabled) {
            HapticFeedback.heavyImpact();
          }
          _showCompletionDialog(context, state);
        }
      },
      builder: (context, state) {
        final chapterTitle = state.subCategory?.title ??
            widget.subCategory?.title ??
            state.category?.name ??
            'الْأَذْكَارُ';

        return Directionality(
          textDirection: TextDirection.rtl,
          child: PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) async {
              if (didPop) return;
              final canExit = await _onWillPop(context, state);
              if (canExit && context.mounted) {
                Navigator.pop(context);
              }
            },
            child: Scaffold(
              appBar: AppBar(
                title: Text(
                  chapterTitle,
                  style: theme.appBarTheme.titleTextStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded),
                  onPressed: () async {
                    final canExit = await _onWillPop(context, state);
                    if (canExit && context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                ),
                actions: [
                  IconButton(
                    tooltip: 'مشاركة الذكر',
                    icon: const Icon(Icons.share_rounded),
                    onPressed: state.currentItem != null
                        ? () => _openShareModal(context, state)
                        : null,
                  ),
                  IconButton(
                    tooltip: 'إعادة ضبط الجلسة',
                    icon: const Icon(Icons.refresh_rounded),
                    onPressed: () {
                      context.read<DhikrBloc>().add(const ResetDhikrSession());
                    },
                  ),
                  const SizedBox(width: 4),
                ],
              ),
              body: SafeArea(
                child: switch (state.status) {
                  DhikrStatus.initial || DhikrStatus.loading => const Center(
                      child: CircularProgressIndicator(color: AppTheme.emeraldPrimary),
                    ),
                  DhikrStatus.error => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          state.errorMessage ?? 'حدث خطأ أثناء تحميل الأذكار',
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  DhikrStatus.loaded || DhikrStatus.completed => _DhikrContent(
                      state: state,
                      chapterTitle: chapterTitle,
                      dhikrCardKey: _dhikrCardKey,
                      onTapCounter: () => _onTapCounter(context, state),
                    ),
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCompletionDialog(BuildContext context, DhikrState state) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppTheme.goldAccent.withAlpha(isDark ? 50 : 30),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.goldAccent, width: 2),
                  ),
                  child: const Icon(
                    Icons.stars_rounded,
                    color: AppTheme.goldAccent,
                    size: 44,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'مُبَارَكٌ! تَمَّ خَتْمُ الْوِرْدِ',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.goldLight : AppTheme.emeraldPrimary,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '«تَقَبَّلَ اللَّهُ مِنَّا وَمِنْكُمُ الصَّالِحَاتِ»\nتم حفظ إنجازك بنجاح في سجل الإحصائيات وزيادة سلسلتك المباركة.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          context.read<DhikrBloc>().add(const ResetDhikrSession());
                          Navigator.pop(dialogContext);
                        },
                        child: const Text('إعادة القراءة'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.emeraldPrimary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          Navigator.pop(context);
                        },
                        child: const Text('العودة للأبواب'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DhikrContent extends StatelessWidget {
  final DhikrState state;
  final String chapterTitle;
  final GlobalKey dhikrCardKey;
  final VoidCallback onTapCounter;

  const _DhikrContent({
    required this.state,
    required this.chapterTitle,
    required this.dhikrCardKey,
    required this.onTapCounter,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final item = state.currentItem;
    final themeState = context.watch<ThemeCubit>().state;
    final font = themeState.fontFamily;
    final double scale = themeState.fontScale;

    if (item == null) {
      return const Center(child: Text('لا توجد بيانات'));
    }

    return Column(
      children: [
        // ── Overall Progress Bar ─────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'الذكر ${state.currentDhikrIndex + 1} من أصل ${state.totalItems}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppTheme.goldLight : AppTheme.emeraldPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(state.overallProgress * 100).toInt()}%',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: state.overallProgress,
                  minHeight: 6,
                  backgroundColor: isDark
                      ? AppTheme.darkSurfaceVariant
                      : AppTheme.lightSurfaceVariant,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppTheme.emeraldLight,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Scrollable Unified Dhikr Card ────────────────────────────────────
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: RepaintBoundary(
              key: dhikrCardKey,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                layoutBuilder: (currentChild, previousChildren) {
                  return Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      ...previousChildren,
                      if (currentChild != null) currentChild,
                    ],
                  );
                },
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.05, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: DhikrCard(
                  key: ValueKey<int>(item.id),
                  item: item,
                  chapterTitle: chapterTitle,
                  currentIndex: state.currentDhikrIndex,
                  totalItems: state.totalItems,
                  fontFamily: font,
                  fontScale: scale,
                ),
              ),
            ),
          ),
        ),

        // ── Counter Button & Navigation Controls ─────────────────────────────
        _BottomControls(
          state: state,
          onTapCounter: onTapCounter,
        ),
      ],
    );
  }
}

class _BottomControls extends StatelessWidget {
  final DhikrState state;
  final VoidCallback onTapCounter;

  const _BottomControls({
    required this.state,
    required this.onTapCounter,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final item = state.currentItem;
    final target = item?.repeatCount ?? 1;
    final current = state.currentCounter;
    final isDone = current >= target;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 80 : 25),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Previous Dhikr Button
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios_rounded),
                tooltip: 'الذكر السابق',
                onPressed: state.hasPrevious
                    ? () => context.read<DhikrBloc>().add(const PreviousDhikr())
                    : null,
              ),

              // Interactive Circular Counter Tap Button
              GestureDetector(
                onTap: onTapCounter,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: isDone
                          ? [Colors.green.shade600, Colors.green.shade800]
                          : isDark
                              ? [AppTheme.emeraldLight, AppTheme.emeraldPrimary]
                              : [AppTheme.emeraldPrimary, AppTheme.emeraldDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isDone ? Colors.green : AppTheme.emeraldPrimary)
                            .withAlpha(120),
                        blurRadius: 16,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$current',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                          ),
                        ),
                        Text(
                          'من $target',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Next Dhikr Button
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded),
                tooltip: 'الذكر التالي',
                onPressed: state.hasNext
                    ? () => context.read<DhikrBloc>().add(const NextDhikr())
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
