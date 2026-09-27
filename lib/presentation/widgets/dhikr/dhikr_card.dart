import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/dhikr_item.dart';

/// Unified single-card layout widget for displaying a Dhikr item.
///
/// Merges the main Dhikr text with Tashkeel, optional Fadl / word explanations,
/// and Hadith source / Takhrij into ONE single cohesive card container with internal
/// scrolling to prevent overflows across all font scale factors.
class DhikrCard extends StatelessWidget {
  /// The active Dhikr item to display.
  final DhikrItem item;

  /// Optional chapter or category title.
  final String? chapterTitle;

  /// Zero-based index of the current Dhikr in the session.
  final int currentIndex;

  /// Total count of Dhikr items in the active session.
  final int totalItems;

  /// Selected Arabic font family (defaults to Amiri / theme default).
  final String? fontFamily;

  /// Font scaling factor (0.8 to 1.4).
  final double fontScale;

  const DhikrCard({
    super.key,
    required this.item,
    this.chapterTitle,
    this.currentIndex = 0,
    this.totalItems = 1,
    this.fontFamily,
    this.fontScale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final font = fontFamily ?? theme.textTheme.bodyMedium?.fontFamily;

    final String fadlText = item.effectiveFadl;
    final String sourceText = item.effectiveSource;
    final bool hasFadl = fadlText.isNotEmpty;
    final bool hasSource = sourceText.isNotEmpty;
    final bool hasFadlOrSource = hasFadl || hasSource;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? AppTheme.goldAccent.withAlpha(50)
              : AppTheme.emeraldPrimary.withAlpha(40),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 80 : 20),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Card Header: App Title & Progress Badge ──────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.auto_stories_rounded,
                          size: 16,
                          color: AppTheme.goldAccent,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'أَوْرَاد — حِصْنُ الْمُسْلِمِ',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppTheme.goldLight : AppTheme.emeraldPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.goldAccent.withAlpha(isDark ? 40 : 25),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppTheme.goldAccent.withAlpha(80),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      '${currentIndex + 1} / $totalItems',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isDark ? AppTheme.goldLight : AppTheme.emeraldDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Header divider
              Divider(
                height: 1,
                thickness: 0.8,
                color: isDark ? Colors.white12 : Colors.black12,
              ),
              const SizedBox(height: 14),

              // ── Sub-category Chapter Title Badge (if available) ───────────
              if (chapterTitle != null && chapterTitle!.trim().isNotEmpty) ...[
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppTheme.darkSurfaceVariant
                          : AppTheme.lightSurfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? AppTheme.goldAccent.withAlpha(50)
                            : AppTheme.emeraldPrimary.withAlpha(30),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      chapterTitle!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppTheme.goldLight : AppTheme.emeraldPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ── 1. Dhikr Body (Arabic text with Tashkeel) ─────────────────
              SelectableText(
                item.content,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: font,
                  fontSize: (22 * fontScale).toDouble(),
                  height: 1.8,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                ),
              ),

              // ── 2. Subtle Divider (Rendered ONLY if Fadl or Source exists) ─
              if (hasFadlOrSource) ...[
                const SizedBox(height: 20),
                Divider(
                  height: 1,
                  thickness: 0.8,
                  color: isDark ? Colors.white12 : Colors.black12,
                ),
                const SizedBox(height: 16),
              ],

              // ── 3. Fadl & Meaning (Rendered only if non-empty) ────────────
              if (hasFadl) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppTheme.goldAccent.withAlpha(25)
                        : AppTheme.goldAccent.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.goldAccent.withAlpha(isDark ? 65 : 45),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.stars_rounded,
                        size: 18,
                        color: AppTheme.goldAccent,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SelectableText(
                          fadlText,
                          style: TextStyle(
                            fontFamily: font,
                            fontSize: (13.5 * fontScale).toDouble(),
                            height: 1.6,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppTheme.goldLight : const Color(0xFF6B4E00),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasSource) const SizedBox(height: 14),
              ],

              // ── 4. Source & Takrij (Preceded by book icon) ────────────────
              if (hasSource) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.menu_book_rounded,
                      size: 15,
                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: SelectableText(
                        sourceText,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: font,
                          fontSize: (12 * fontScale).toDouble(),
                          height: 1.5,
                          color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
