import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../blocs/settings/settings_cubit.dart';
import '../../blocs/settings/settings_state.dart';
import '../../blocs/theme/theme_cubit.dart';
import '../../blocs/theme/theme_state.dart';

/// Screen providing user customisation for theme mode, Arabic typography,
/// font scaling with live preview, and haptic/sound feedback toggles.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          children: [
            // ── Screen Header ───────────────────────────────────────────────
            Text(
              'الإِعْدَادَاتُ وَالْمَظْهَرُ',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.goldLight : AppTheme.emeraldPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'تخصيص مظهر التطبيق والخط والتنبيهات التفاعلية',
              style: theme.textTheme.bodyMedium,
            ),

            const SizedBox(height: 20),

            // ── Live Arabic Text Preview Card ───────────────────────────────
            BlocBuilder<ThemeCubit, ThemeState>(
              builder: (context, themeState) {
                final previewFont = AppTheme.resolveFontFamily(themeState.fontFamily);
                final previewScale = themeState.fontScale;

                return Card(
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? AppTheme.goldAccent.withAlpha(60)
                            : AppTheme.emeraldPrimary.withAlpha(50),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.preview_rounded,
                                    color: AppTheme.goldAccent,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      'معاينة الخط الحيّة',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.labelMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.goldAccent,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
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
                                '${(previewScale * 100).toInt()}%',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          '﴿ أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ ﴾',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: previewFont,
                            fontSize: 22 * previewScale,
                            fontWeight: FontWeight.bold,
                            height: 1.6,
                            color: isDark ? AppTheme.goldLight : AppTheme.emeraldPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '«سُبْحَانَ اللَّهِ وَبِحَمْدِهِ ، سُبْحَانَ اللَّهِ الْعَظِيمِ»',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: previewFont,
                            fontSize: 16 * previewScale,
                            height: 1.7,
                            color: isDark
                                ? AppTheme.darkTextPrimary
                                : AppTheme.lightTextPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // ── Section 1: Appearance & Theme Mode ──────────────────────────
            _SectionHeader(title: 'المظهر ووضع العرض', icon: Icons.palette_outlined),
            const SizedBox(height: 10),
            BlocBuilder<ThemeCubit, ThemeState>(
              builder: (context, themeState) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: SegmentedButton<ThemeMode>(
                      segments: const [
                        ButtonSegment<ThemeMode>(
                          value: ThemeMode.system,
                          label: Text('تلقائي'),
                          icon: Icon(Icons.brightness_auto_rounded),
                        ),
                        ButtonSegment<ThemeMode>(
                          value: ThemeMode.light,
                          label: Text('فاتح'),
                          icon: Icon(Icons.light_mode_rounded),
                        ),
                        ButtonSegment<ThemeMode>(
                          value: ThemeMode.dark,
                          label: Text('داكن'),
                          icon: Icon(Icons.dark_mode_rounded),
                        ),
                      ],
                      selected: {themeState.themeMode},
                      onSelectionChanged: (newSelection) {
                        context
                            .read<ThemeCubit>()
                            .setThemeMode(newSelection.first);
                      },
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // ── Section 2: Arabic Typography (Font Family) ───────────────────
            _SectionHeader(title: 'نوع الخط العربي', icon: Icons.text_fields_rounded),
            const SizedBox(height: 10),
            BlocBuilder<ThemeCubit, ThemeState>(
              builder: (context, themeState) {
                final fonts = [
                  (id: 'Amiri', name: 'خط الأميري', subtitle: 'خط نسخ كلاسيكي موثق بالحركات الكاملة'),
                  (id: 'ScheherazadeNew', name: 'خط شهرزاد الجديد', subtitle: 'خط عربي عثماني واضح وجليّ'),
                  (id: 'Lateef', name: 'خط لطيف', subtitle: 'طراز عربي تقليدي رشيق وأنيق'),
                  (id: 'System', name: 'خط النظام', subtitle: 'الخط التلقائي الافتراضي لجهازك'),
                ];

                return Card(
                  child: Column(
                    children: fonts.map((font) {
                      final isSelected =
                          themeState.fontFamily.toLowerCase() == font.id.toLowerCase();
                      return ListTile(
                        leading: Icon(
                          isSelected
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_off_rounded,
                          color: isSelected
                              ? (isDark ? AppTheme.goldLight : AppTheme.emeraldPrimary)
                              : (isDark
                                  ? AppTheme.darkTextSecondary
                                  : AppTheme.lightTextSecondary),
                        ),
                        title: Text(
                          font.name,
                          style: TextStyle(
                            fontFamily: AppTheme.resolveFontFamily(font.id),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 16,
                            color: isSelected
                                ? (isDark ? AppTheme.goldLight : AppTheme.emeraldPrimary)
                                : null,
                          ),
                        ),
                        subtitle: Text(
                          font.subtitle,
                          style: theme.textTheme.labelSmall,
                        ),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle_rounded,
                                color: isDark
                                    ? AppTheme.goldLight
                                    : AppTheme.emeraldPrimary,
                                size: 20,
                              )
                            : null,
                        onTap: () {
                          context.read<ThemeCubit>().setFontFamily(font.id);
                        },
                      );
                    }).toList(),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // ── Section 3: Font Scaling Slider ──────────────────────────────
            _SectionHeader(title: 'حجم الخط والتكبير', icon: Icons.format_size_rounded),
            const SizedBox(height: 10),
            BlocBuilder<ThemeCubit, ThemeState>(
              builder: (context, themeState) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'نسبة تكبير النصوص:',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${(themeState.fontScale * 100).toInt()}%',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppTheme.goldLight
                                    : AppTheme.emeraldPrimary,
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          value: themeState.fontScale,
                          min: 0.8,
                          max: 1.4,
                          divisions: 12,
                          label: '${(themeState.fontScale * 100).toInt()}%',
                          activeColor: isDark ? AppTheme.goldAccent : AppTheme.emeraldPrimary,
                          onChanged: (val) {
                            context.read<ThemeCubit>().setFontScale(val);
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'صغير (80%)',
                              style: theme.textTheme.labelSmall,
                            ),
                            Text(
                              'كبير (140%)',
                              style: theme.textTheme.labelSmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Center(
                          child: TextButton.icon(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () => context.read<ThemeCubit>().setFontScale(1.0),
                            icon: const Icon(Icons.refresh_rounded, size: 14),
                            label: const Text('إعادة الضبط إلى 100%'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // ── Section 4: Sound & Haptics Toggles ──────────────────────────
            _SectionHeader(title: 'التفاعل الصوتي واللمسي', icon: Icons.vibration_rounded),
            const SizedBox(height: 10),
            BlocBuilder<SettingsCubit, SettingsState>(
              builder: (context, settingsState) {
                return Card(
                  child: Column(
                    children: [
                      SwitchListTile(
                        secondary: const Icon(Icons.volume_up_rounded, color: AppTheme.emeraldLight),
                        title: const Text('مؤثرات الصوت'),
                        subtitle: const Text('تشغيل نقرة صوتية عند التسبيح في المسبحة وقراءة الأذكار'),
                        value: settingsState.soundEnabled,
                        activeThumbColor: AppTheme.emeraldPrimary,
                        onChanged: (val) {
                          context.read<SettingsCubit>().setSoundEnabled(val);
                        },
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        secondary: const Icon(Icons.vibration_rounded, color: AppTheme.goldAccent),
                        title: const Text('الاهتزاز التفاعلي (Haptic)'),
                        subtitle: const Text('اهتزاز خفيف باللمس واهتزاز مميز عند إتمام الهدف'),
                        value: settingsState.hapticEnabled,
                        activeThumbColor: AppTheme.emeraldPrimary,
                        onChanged: (val) {
                          context.read<SettingsCubit>().setHapticEnabled(val);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // ── Section 5: Offline Daily Notifications & Reminders ──────────
            const _SectionHeader(
              title: 'التنبيهات والأذكار اليومية',
              icon: Icons.notifications_active_rounded,
            ),
            const SizedBox(height: 10),
            BlocBuilder<SettingsCubit, SettingsState>(
              builder: (context, settingsState) {
                final morningHour = settingsState.useDefaultSlots
                    ? DefaultValues.morningNotificationHour
                    : settingsState.morningHour;
                final morningMinute = settingsState.useDefaultSlots
                    ? DefaultValues.morningNotificationMinute
                    : settingsState.morningMinute;

                final eveningHour = settingsState.useDefaultSlots
                    ? DefaultValues.eveningNotificationHour
                    : settingsState.eveningHour;
                final eveningMinute = settingsState.useDefaultSlots
                    ? DefaultValues.eveningNotificationMinute
                    : settingsState.eveningMinute;

                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Master notifications switch
                      SwitchListTile(
                        secondary: const Icon(Icons.alarm_rounded, color: AppTheme.goldAccent),
                        title: const Text('تفعيل تنبيهات الأذكار'),
                        subtitle: const Text('تنبيهات محلية بدون إنترنت لأذكار الصباح والمساء'),
                        value: settingsState.notificationsEnabled,
                        activeThumbColor: AppTheme.emeraldPrimary,
                        onChanged: (val) {
                          context.read<SettingsCubit>().setNotificationsEnabled(val);
                        },
                      ),
                      if (settingsState.notificationsEnabled) ...[
                        const Divider(height: 1),

                        // Mode Selector: Recommended vs Custom Slots
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                          child: Text(
                            'وضع جدولة المواعيد',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppTheme.goldLight : AppTheme.emeraldPrimary,
                            ),
                          ),
                        ),
                        RadioGroup<bool>(
                          groupValue: settingsState.useDefaultSlots,
                          onChanged: (val) {
                            if (val != null) {
                              context.read<SettingsCubit>().setUseDefaultSlots(val);
                            }
                          },
                          child: Column(
                            children: [
                              RadioListTile<bool>(
                                title: const Text('المواعيد الموصى بها (افتراضي)'),
                                subtitle: const Text('الصباح (06:00 ص) • المساء (04:30 م)'),
                                value: true,
                                activeColor: AppTheme.emeraldPrimary,
                              ),
                              RadioListTile<bool>(
                                title: const Text('تحديد أوقات مخصصة'),
                                subtitle: const Text('ضبط وقت مستقل لكل من أذكار الصباح والمساء'),
                                value: false,
                                activeColor: AppTheme.emeraldPrimary,
                              ),
                            ],
                          ),
                        ),

                        const Divider(height: 1),

                        // Morning Dhikr Reminder Tile
                        _ReminderSlotTile(
                          icon: Icons.wb_sunny_rounded,
                          title: 'أذكار الصباح',
                          subtitle: 'حان وقت ورد الصباح المبارك',
                          enabled: settingsState.morningNotificationEnabled,
                          timeDisplay: formatArabicTime(morningHour, morningMinute),
                          isCustomMode: !settingsState.useDefaultSlots,
                          onToggle: (val) {
                            context.read<SettingsCubit>().setMorningEnabled(val);
                          },
                          onPickTime: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay(
                                hour: settingsState.morningHour,
                                minute: settingsState.morningMinute,
                              ),
                            );
                            if (picked != null && context.mounted) {
                              context.read<SettingsCubit>().setMorningTime(
                                    picked.hour,
                                    picked.minute,
                                  );
                            }
                          },
                        ),

                        const Divider(height: 1),

                        // Evening Dhikr Reminder Tile
                        _ReminderSlotTile(
                          icon: Icons.nights_stay_rounded,
                          title: 'أذكار المساء',
                          subtitle: 'حان وقت ورد المساء المبارك',
                          enabled: settingsState.eveningNotificationEnabled,
                          timeDisplay: formatArabicTime(eveningHour, eveningMinute),
                          isCustomMode: !settingsState.useDefaultSlots,
                          onToggle: (val) {
                            context.read<SettingsCubit>().setEveningEnabled(val);
                          },
                          onPickTime: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay(
                                hour: settingsState.eveningHour,
                                minute: settingsState.eveningMinute,
                              ),
                            );
                            if (picked != null && context.mounted) {
                              context.read<SettingsCubit>().setEveningTime(
                                    picked.hour,
                                    picked.minute,
                                  );
                            }
                          },
                        ),
                        const SizedBox(height: 6),
                      ],
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 28),

            // ── App Info & Offline Guarantee ────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.white.withAlpha(20) : const Color(0xFFE8E5DD),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.wifi_off_rounded,
                        size: 20,
                        color: AppTheme.emeraldLight,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'تطبيق أَوْرَاد (Awrad) — يعمل 100% دون إنترنت',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'جميع الأذكار مأخوذة من حصن المسلم الموثق بالروايات الصحيحة.\nالإصدار 1.0.0 (Phase 2 Complete)',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelSmall?.copyWith(height: 1.5),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isDark ? AppTheme.goldLight : AppTheme.emeraldPrimary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.goldLight : AppTheme.emeraldPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

/// Formats 24-hour [hour] and [minute] into Arabic 12-hour format with 'ص' and 'م'.
String formatArabicTime(int hour, int minute) {
  final period = hour >= 12 ? 'م' : 'ص';
  final h12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
  final hStr = h12.toString().padLeft(2, '0');
  final mStr = minute.toString().padLeft(2, '0');
  return '$hStr:$mStr $period';
}

/// Interactive reminder slot tile for Morning and Evening reminders.
class _ReminderSlotTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool enabled;
  final String timeDisplay;
  final bool isCustomMode;
  final ValueChanged<bool> onToggle;
  final VoidCallback onPickTime;

  const _ReminderSlotTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.timeDisplay,
    required this.isCustomMode,
    required this.onToggle,
    required this.onPickTime,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: enabled
                  ? AppTheme.emeraldPrimary.withAlpha(25)
                  : Colors.grey.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: enabled
                  ? (isDark ? AppTheme.goldLight : AppTheme.emeraldPrimary)
                  : Colors.grey,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: enabled
                            ? (isDark
                                ? AppTheme.goldAccent.withAlpha(30)
                                : AppTheme.emeraldLight.withAlpha(25))
                            : Colors.grey.withAlpha(15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        timeDisplay,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: enabled
                              ? (isDark
                                  ? AppTheme.goldLight
                                  : AppTheme.emeraldDark)
                              : Colors.grey,
                        ),
                      ),
                    ),
                    if (isCustomMode && enabled)
                      InkWell(
                        onTap: onPickTime,
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.edit_calendar_rounded,
                                size: 14,
                                color: isDark
                                    ? AppTheme.goldLight
                                    : AppTheme.emeraldPrimary,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                'تغيير الوقت',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: isDark
                                      ? AppTheme.goldLight
                                      : AppTheme.emeraldPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Switch(
            value: enabled,
            activeThumbColor: AppTheme.emeraldPrimary,
            onChanged: onToggle,
          ),
        ],
      ),
    );
  }
}

