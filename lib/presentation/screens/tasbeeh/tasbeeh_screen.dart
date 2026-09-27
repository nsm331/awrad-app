import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/sound_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../blocs/settings/settings_cubit.dart';
import '../../blocs/tasbeeh/tasbeeh_cubit.dart';
import '../../blocs/tasbeeh/tasbeeh_state.dart';
import '../../blocs/theme/theme_cubit.dart';
import '../../blocs/theme/theme_state.dart';

/// Screen providing the Free & Guided Electronic Tasbeeh (المسبحة الإلكترونية).
/// Features a large tactile interactive tap area, smooth AnimatedSwitcher counter,
/// target progress ring, sound & haptic integration, and reset confirmation dialog.
class TasbeehScreen extends StatelessWidget {
  const TasbeehScreen({super.key});

  void _onTapCounter(BuildContext context) {
    final settings = context.read<SettingsCubit>().state;
    final cubit = context.read<TasbeehCubit>();

    final targetReached = cubit.increment();

    // Haptic feedback respecting Phase 2 global settings
    if (settings.hapticEnabled) {
      if (targetReached) {
        HapticFeedback.heavyImpact();
      } else {
        HapticFeedback.lightImpact();
      }
    }

    // Audio click feedback respecting Phase 2 global settings
    if (settings.soundEnabled) {
      SoundService.instance.playClickSound();
    }

    // Celebration dialog when reaching a target cycle
    if (targetReached) {
      _showTargetReachedDialog(context);
    }
  }

  void _showTargetReachedDialog(BuildContext context) {
    final cubit = context.read<TasbeehCubit>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: Row(
            children: [
              const Icon(Icons.stars_rounded, color: AppTheme.goldAccent, size: 28),
              const SizedBox(width: 8),
              Text(
                'تَقَبَّلَ اللَّهُ طَاعَتَكُمْ',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.goldLight : AppTheme.emeraldPrimary,
                ),
              ),
            ],
          ),
          content: Text(
            'أتممت دورة التسبيح المباركة (${cubit.state.target} مرة) بنجاح.\nهل ترغب في متابعة العد أم تصفير العداد للبدء من جديد؟',
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('متابعة العد'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.emeraldPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                cubit.reset();
                Navigator.pop(dialogContext);
              },
              child: const Text('تصفير ودورة جديدة'),
            ),
          ],
        );
      },
    );
  }

  void _confirmReset(BuildContext context) {
    final cubit = context.read<TasbeehCubit>();
    final theme = Theme.of(context);

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.restart_alt_rounded, color: Colors.orangeAccent),
              const SizedBox(width: 8),
              Text(
                'إعادة ضبط العداد',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'هل أنت متأكد من رغبتك في تصفير عداد الدورة الحالية؟\n\n(ملاحظة: مجموع التسبيحات الكلي محفوظ ولن يتأثر)',
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
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
                cubit.reset();
                Navigator.pop(dialogContext);
              },
              child: const Text('تصفير العداد'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<TasbeehCubit, TasbeehState>(
          builder: (context, state) {
            return Column(
              children: [
                const SizedBox(height: 12),

                // ── Preset Adhkar Horizontal Carousel ───────────────────────
                SizedBox(
                  height: 48,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: kPresetTasbeehAdhkar.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final isSelected = state.selectedDhikrIndex == index;
                      final dhikr = kPresetTasbeehAdhkar[index];
                      return ChoiceChip(
                        label: Text(dhikr),
                        selected: isSelected,
                        onSelected: (_) =>
                            context.read<TasbeehCubit>().selectDhikr(index),
                        selectedColor: isDark
                            ? AppTheme.emeraldPrimary
                            : AppTheme.emeraldLight,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                  ? AppTheme.darkTextPrimary
                                  : AppTheme.lightTextPrimary),
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                        backgroundColor: isDark
                            ? AppTheme.darkSurfaceVariant
                            : AppTheme.lightSurfaceVariant,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // ── Target Mode Selector & Reset Button ─────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Target cycle pills
                      Row(
                        children: [
                          _TargetChip(
                            label: '٣٣',
                            isSelected: state.target == 33,
                            onTap: () =>
                                context.read<TasbeehCubit>().setTarget(33),
                          ),
                          const SizedBox(width: 8),
                          _TargetChip(
                            label: '١٠٠',
                            isSelected: state.target == 100,
                            onTap: () =>
                                context.read<TasbeehCubit>().setTarget(100),
                          ),
                          const SizedBox(width: 8),
                          _TargetChip(
                            label: 'عَدٌّ حُرّ',
                            isSelected: state.target == 0,
                            onTap: () =>
                                context.read<TasbeehCubit>().setTarget(0),
                          ),
                        ],
                      ),

                      // Reset Button with quick dialog
                      IconButton.filledTonal(
                        onPressed: state.count > 0
                            ? () => _confirmReset(context)
                            : null,
                        icon: const Icon(Icons.refresh_rounded),
                        tooltip: 'تصفير العداد',
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // ── Active Dhikr Phrase Card ────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: BlocBuilder<ThemeCubit, ThemeState>(
                    builder: (context, themeState) {
                      final font =
                          AppTheme.resolveFontFamily(themeState.fontFamily);
                      final scale = themeState.fontScale;

                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
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
                        child: Text(
                          state.currentDhikr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: font,
                            fontSize: 24 * scale,
                            height: 1.5,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppTheme.goldLight
                                : AppTheme.emeraldPrimary,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 28),

                // ── Large Tactile Circular Tap Button with Smooth Increment ─
                _InteractiveTasbeehButton(
                  state: state,
                  onTap: () => _onTapCounter(context),
                ),

                const Spacer(),

                // ── Lifetime Total Counter Banner ────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withAlpha(20)
                            : const Color(0xFFE8E5DD),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.all_inclusive_rounded,
                              color: AppTheme.goldAccent,
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'مجموع التسبيحات المباركة:',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${state.totalCount}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppTheme.goldLight
                                : AppTheme.emeraldPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Interactive circular Tasbeeh button with tactile scale-down animation on press,
/// smooth animated progress ring, and AnimatedSwitcher scale pulse on counter increments.
class _InteractiveTasbeehButton extends StatefulWidget {
  final TasbeehState state;
  final VoidCallback onTap;

  const _InteractiveTasbeehButton({
    required this.state,
    required this.onTap,
  });

  @override
  State<_InteractiveTasbeehButton> createState() =>
      _InteractiveTasbeehButtonState();
}

class _InteractiveTasbeehButtonState extends State<_InteractiveTasbeehButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final state = widget.state;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeInOut,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Smoothly Animated Circular Progress Ring (when target > 0)
            if (state.target > 0)
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: state.progress),
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                builder: (context, animatedProgress, _) {
                  return SizedBox(
                    width: 250,
                    height: 250,
                    child: CircularProgressIndicator(
                      value: animatedProgress,
                      strokeWidth: 9,
                      strokeCap: StrokeCap.round,
                      backgroundColor: isDark
                          ? AppTheme.darkSurfaceVariant
                          : const Color(0xFFE2DDD2),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(AppTheme.goldAccent),
                    ),
                  );
                },
              ),

            // Inner Large Interactive Circular Tap Disc
            Container(
              width: 216,
              height: 216,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: isDark
                      ? [
                          AppTheme.emeraldLight,
                          AppTheme.emeraldDark,
                        ]
                      : [
                          AppTheme.emeraldLight,
                          AppTheme.emeraldPrimary,
                        ],
                  center: const Alignment(-0.25, -0.25),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.emeraldPrimary
                        .withAlpha(isDark ? 90 : 110),
                    blurRadius: 28,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Smooth Increment AnimatedSwitcher
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(
                        scale: Tween<double>(begin: 0.82, end: 1.0).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutBack,
                          ),
                        ),
                        child: FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                      );
                    },
                    child: Text(
                      '${state.count}',
                      key: ValueKey<int>(state.count),
                      style: theme.textTheme.displayLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 54,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Target subtitle or free count label
                  Text(
                    state.target > 0
                        ? 'الهدف: ${state.target}'
                        : 'عَدٌّ حُرٌّ',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.goldLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Tap hint pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(35),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'المس للعد',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white.withAlpha(220),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TargetChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TargetChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppTheme.goldAccent : AppTheme.emeraldPrimary)
              : (isDark
                  ? AppTheme.darkSurfaceVariant
                  : AppTheme.lightSurfaceVariant),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: isSelected
                ? Colors.white
                : (isDark
                    ? AppTheme.darkTextPrimary
                    : AppTheme.lightTextPrimary),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
