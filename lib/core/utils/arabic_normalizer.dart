/// Arabic text normalization utilities for offline search and comparison.
///
/// Strips Tashkeel (diacritics), Tatweel (kashida), and normalizes letter
/// variants (Alif variants, Taa Marbuta, Alif Maqsura, Hamzas) so users
/// can search unvocalized Arabic words seamlessly.
library;

abstract final class ArabicNormalizer {
  /// Regular expression matching all Arabic diacritic marks (Tashkeel)
  /// and typographical symbols:
  ///  - Fathatan (\u064B), Dammatan (\u064C), Kasratan (\u064D)
  ///  - Fatha (\u064E), Damma (\u064F), Kasra (\u0650)
  ///  - Shadda (\u0651), Sukun (\u0652)
  ///  - Maddah (\u0653), Hamza Above (\u0654), Hamza Below (\u0655)
  ///  - Dagger Alif (\u0670), Tatweel/Kashida (\u0640)
  static final RegExp _diacriticsRegex = RegExp(
    r'[\u064B-\u0655\u0670\u0640]',
  );

  /// Removes all Tashkeel / diacritical vowel marks from [text].
  static String stripTashkeel(String text) {
    if (text.isEmpty) return text;
    return text.replaceAll(_diacriticsRegex, '');
  }

  /// Normalizes Arabic text by removing Tashkeel and standardizing letter forms:
  ///  - 'أ', 'إ', 'آ', 'ٱ' -> 'ا'
  ///  - 'ة' -> 'ه'
  ///  - 'ى' -> 'ي'
  ///  - 'ؤ' -> 'و'
  ///  - 'ئ' -> 'ي'
  static String normalize(String text) {
    if (text.isEmpty) return text;

    var cleaned = stripTashkeel(text);

    // Normalize letter variants
    cleaned = cleaned
        .replaceAll(RegExp(r'[أإآٱ]'), 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .replaceAll('ؤ', 'و')
        .replaceAll('ئ', 'ي');

    // Remove extraneous whitespace
    return cleaned.trim().toLowerCase();
  }

  /// Returns `true` if [source] contains [query] after normalizing both.
  static bool containsNormalized(String source, String query) {
    final normSource = normalize(source);
    final normQuery = normalize(query);
    if (normQuery.isEmpty) return true;
    return normSource.contains(normQuery);
  }
}
