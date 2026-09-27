import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../theme/app_theme.dart';

/// Helper utility for Dhikr sharing (formatted text & high-resolution PNG image).
/// Operates 100% offline using local device rendering and native share sheets.
class ShareHelper {
  ShareHelper._();

  /// Formats Dhikr text, Takhrij footnote, and Hadith benefits into a clean,
  /// structured Arabic text template suitable for social sharing and messaging.
  static String formatDhikrText({
    required String categoryName,
    required String content,
    required int repeatCount,
    String? subCategory,
    String? fadl,
    String? source,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('من تطبيق أَوْرَاد — حصن المسلم الموثق');
    buffer.writeln();
    if (subCategory != null && subCategory.trim().isNotEmpty) {
      buffer.writeln('﴿ $categoryName • ${subCategory.trim()} ﴾');
    } else {
      buffer.writeln('﴿ $categoryName ﴾');
    }
    buffer.writeln();
    buffer.writeln(content.trim());
    buffer.writeln();
    buffer.writeln('• عدد التكرار: $repeatCount ${repeatCount == 1 ? "مرة" : "مرات"}');

    if (fadl != null && fadl.trim().isNotEmpty) {
      buffer.writeln();
      buffer.writeln('• فضل الذكر: ${fadl.trim()}');
    }

    if (source != null && source.trim().isNotEmpty) {
      buffer.writeln();
      buffer.writeln('• المصدر والتخريج: ${source.trim()}');
    }

    buffer.writeln();
    buffer.write('اللهم اجعله صدقة جارية وعلمًا ينتفع به.');
    return buffer.toString();
  }

  /// Shares the Dhikr as structured Arabic text via the native share sheet.
  static Future<void> shareText({
    required String categoryName,
    required String content,
    required int repeatCount,
    String? subCategory,
    String? fadl,
    String? source,
  }) async {
    final text = formatDhikrText(
      categoryName: categoryName,
      content: content,
      repeatCount: repeatCount,
      subCategory: subCategory,
      fadl: fadl,
      source: source,
    );

    await Share.share(
      text,
      subject: 'أَوْرَاد — $categoryName',
    );
  }

  /// Captures the widget attached to [boundaryKey] as a high-resolution PNG,
  /// saves it to the local temporary directory, and returns the file path.
  static Future<String?> captureWidgetToPng(
    GlobalKey boundaryKey, {
    double pixelRatio = 3.0,
  }) async {
    try {
      final boundary = boundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;

      if (boundary == null) {
        debugPrint('[ShareHelper] RenderRepaintBoundary not found for key.');
        return null;
      }

      // If the boundary is still dirty, wait for frame completion
      if (boundary.debugNeedsPaint) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }

      final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        debugPrint('[ShareHelper] Failed to convert image to byte data.');
        return null;
      }

      final pngBytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${tempDir.path}/awrad_dhikr_$timestamp.png');

      await file.writeAsBytes(pngBytes, flush: true);
      return file.path;
    } catch (e, stack) {
      debugPrint('[ShareHelper] Error capturing widget to PNG: $e\n$stack');
      return null;
    }
  }

  /// Captures the widget at [boundaryKey] and opens the native share sheet
  /// to share the generated high-resolution PNG image.
  static Future<bool> shareWidgetAsImage({
    required GlobalKey boundaryKey,
    required String title,
    String? caption,
    double pixelRatio = 3.0,
  }) async {
    final filePath = await captureWidgetToPng(
      boundaryKey,
      pixelRatio: pixelRatio,
    );

    if (filePath == null) {
      return false;
    }

    try {
      final xFile = XFile(filePath, mimeType: 'image/png');
      await Share.shareXFiles(
        [xFile],
        text: caption ?? title,
        subject: title,
      );
      return true;
    } catch (e, stack) {
      debugPrint('[ShareHelper] Error invoking shareXFiles: $e\n$stack');
      return false;
    }
  }

  /// Displays an intuitive, elegant RTL bottom sheet letting the user choose
  /// between sharing as text or capturing a high-resolution designed card image.
  static Future<void> showShareModal(
    BuildContext context, {
    required GlobalKey boundaryKey,
    required String categoryName,
    required String content,
    required int repeatCount,
    String? subCategory,
    String? fadl,
    String? source,
  }) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Title header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.emeraldPrimary.withAlpha(isDark ? 50 : 25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.share_rounded,
                        color: AppTheme.emeraldPrimary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'مشاركة الذكر المبارك',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          subCategory != null && subCategory.trim().isNotEmpty
                              ? '﴿ $categoryName • $subCategory ﴾'
                              : '﴿ $categoryName ﴾',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? AppTheme.goldLight : AppTheme.emeraldPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Option 1: Share as Text
                _ShareOptionTile(
                  icon: Icons.text_snippet_outlined,
                  iconColor: AppTheme.emeraldPrimary,
                  title: 'مشاركة كنص',
                  subtitle: 'نسخ أو إرسال نص الذكر والتخريج والفضل بدقة',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    shareText(
                      categoryName: categoryName,
                      content: content,
                      repeatCount: repeatCount,
                      subCategory: subCategory,
                      fadl: fadl,
                      source: source,
                    );
                  },
                ),
                const SizedBox(height: 10),

                // Option 2: Share as High-Res Image Card
                _ShareOptionTile(
                  icon: Icons.image_outlined,
                  iconColor: AppTheme.goldAccent,
                  title: 'مشاركة كصورة مصممة (PNG)',
                  subtitle: 'توليد بطاقة مصممة بجودة عالية من محتوى الذكر',
                  onTap: () async {
                    Navigator.pop(sheetContext);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: isDark
                            ? AppTheme.darkSurfaceVariant
                            : AppTheme.emeraldPrimary,
                        content: const Row(
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('جاري تجهيز الصورة عالية الدقة...'),
                          ],
                        ),
                      ),
                    );

                    final success = await shareWidgetAsImage(
                      boundaryKey: boundaryKey,
                      title: 'أَوْرَاد — $categoryName',
                      caption: '﴿ $categoryName ﴾\nمن تطبيق أَوْرَاد (حصن المسلم)',
                    );

                    if (!success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تعذر تجهيز الصورة، يرجى المحاولة لاحقًا'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ShareOptionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ShareOptionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: isDark ? AppTheme.darkSurfaceVariant : AppTheme.lightSurfaceVariant,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(isDark ? 40 : 25),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isDark
                            ? AppTheme.darkTextSecondary
                            : AppTheme.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
