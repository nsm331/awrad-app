/// Metadata and mapping utility for Hisn al-Muslim thematic parent categories.
/// Groups 130+ specific chapter titles into 11 coherent parental themes plus
/// the all-inclusive "جميع الأذكار" category, while excluding introductory content.
library;

/// Represents the definition and metadata of a parent category.
class ParentCategoryDefinition {
  final int id;
  final String name;
  final String nameTransliteration;
  final String nameTranslation;
  final String iconName;
  final int orderIndex;

  const ParentCategoryDefinition({
    required this.id,
    required this.name,
    required this.nameTransliteration,
    required this.nameTranslation,
    required this.iconName,
    required this.orderIndex,
  });
}

/// Utility for resolving chapters into parent categories.
class HisnCategoryMapper {
  HisnCategoryMapper._();

  /// The virtual all-inclusive category ID.
  static const int allDhikrCategoryId = 0;

  /// The list of the 12 canonical parent categories in Awrad.
  static const List<ParentCategoryDefinition> parentCategories = [
    ParentCategoryDefinition(
      id: 0,
      name: 'جميع الأذكار',
      nameTransliteration: 'Jami al-Adhkar',
      nameTranslation: 'All Remembrances',
      iconName: 'all_inclusive',
      orderIndex: 0,
    ),
    ParentCategoryDefinition(
      id: 1,
      name: 'اليوم والليلة',
      nameTransliteration: 'Al-Yawm wa Al-Laylah',
      nameTranslation: 'Day & Night',
      iconName: 'nights_stay',
      orderIndex: 1,
    ),
    ParentCategoryDefinition(
      id: 2,
      name: 'البيت والأهل',
      nameTransliteration: 'Al-Bayt wa Al-Ahl',
      nameTranslation: 'Home & Family',
      iconName: 'home',
      orderIndex: 2,
    ),
    ParentCategoryDefinition(
      id: 3,
      name: 'الوضوء والصلاة',
      nameTransliteration: 'Al-Wudu wa Al-Salah',
      nameTranslation: 'Ablution & Prayer',
      iconName: 'mosque',
      orderIndex: 3,
    ),
    ParentCategoryDefinition(
      id: 4,
      name: 'الطعام والشراب',
      nameTransliteration: 'Al-Ta\'am wa Al-Sharab',
      nameTranslation: 'Food & Drink',
      iconName: 'restaurant',
      orderIndex: 4,
    ),
    ParentCategoryDefinition(
      id: 5,
      name: 'السفر والتنقل',
      nameTransliteration: 'Al-Safar wa Al-Tanaqqul',
      nameTranslation: 'Travel & Transit',
      iconName: 'flight_takeoff',
      orderIndex: 5,
    ),
    ParentCategoryDefinition(
      id: 6,
      name: 'الفرح والخوف والكرب',
      nameTransliteration: 'Al-Farah wa Al-Khawf wa Al-Karb',
      nameTranslation: 'Joy, Fear & Tribulation',
      iconName: 'sentiment_very_satisfied',
      orderIndex: 6,
    ),
    ParentCategoryDefinition(
      id: 7,
      name: 'الحج والعمرة',
      nameTransliteration: 'Al-Hajj wa Al-Umrah',
      nameTranslation: 'Hajj & Umrah',
      iconName: 'explore',
      orderIndex: 7,
    ),
    ParentCategoryDefinition(
      id: 8,
      name: 'المرض والجنائز',
      nameTransliteration: 'Al-Marad wa Al-Jana\'iz',
      nameTranslation: 'Illness & Funerals',
      iconName: 'healing',
      orderIndex: 8,
    ),
    ParentCategoryDefinition(
      id: 9,
      name: 'التعامل والآداب',
      nameTransliteration: 'Al-Ta\'amul wa Al-Adab',
      nameTranslation: 'Social Etiquette & Manners',
      iconName: 'people',
      orderIndex: 9,
    ),
    ParentCategoryDefinition(
      id: 10,
      name: 'الطبيعة والأنواء',
      nameTransliteration: 'Al-Tabi\'ah wa Al-Anwa\'',
      nameTranslation: 'Nature & Weather',
      iconName: 'wb_cloudy',
      orderIndex: 10,
    ),
    ParentCategoryDefinition(
      id: 11,
      name: 'التسابيح والاستغفار',
      nameTransliteration: 'Al-Tasabih wa Al-Istighfar',
      nameTranslation: 'Praise & Forgiveness',
      iconName: 'stars',
      orderIndex: 11,
    ),
  ];

  /// Canonical mapping of all 134 Hisn al-Muslim JSON keys to Parent Category IDs (1..11).
  /// Keys not in this map or returning `null` (such as "المقدمة") are excluded.
  static final Map<String, int> _chapterToParentId = {
    // ── 1. اليوم والليلة (Day & Night) ───────────────────────────────────────
    'أذكار الاستيقاظ من النوم': 1,
    'أذكار الصباح والمساء': 1,
    'أذكار الصباح': 1,
    'أذكار المساء': 1,
    'أذكار النوم': 1,
    'الدعاء إذا تقلب ليلاً': 1,
    'دعاء القلق والفزع في النوم ومن بلي بالوحشة': 1,
    'ما يفعل من رأى الرؤيا أو الحلم': 1,

    // ── 2. البيت والأهل (Home & Family) ──────────────────────────────────────
    'دعاء لبس الثوب': 2,
    'دعاء لبس الثوب الجديد': 2,
    'الدعاء لمن لبس ثوباً جديداً': 2,
    'ما يقول إذا وضع الثوب': 2,
    'دعاء دخول الخلاء': 2,
    'دعاء الخروج من الخلاء': 2,
    'الذكر عند الخروج من المنزل': 2,
    'الذكر عند الدخول المنزل': 2,
    'تهنئة المولود له وجوابه': 2,
    'ما يعوذ به الأولاد': 2,
    'الدعاء للمتزوج': 2,
    'دعاء المتزوج لنفسه ودعاء شراء الدابة': 2,
    'الدعاء قبل إتيان الزوجة': 2,
    'ما يقول عند الذبح أو النحر': 2,

    // ── 3. الوضوء والصلاة (Ablution & Prayer) ────────────────────────────────
    'الذكر قبل الوضوء': 3,
    'الذكر بعد الفراغ من الوضوء': 3,
    'دعاء الذهاب إلى المسجد': 3,
    'دعاء دخول المسجد': 3,
    'دعاء الخروج من المسجد': 3,
    'أذكار الأذان': 3,
    'دعاء الاستفتاح': 3,
    'دعاء الركوع': 3,
    'دعاء الرفع من الركوع': 3,
    'دعاء السجود': 3,
    'دعاء الجلسة بين السجدتين': 3,
    'دعاء سجود التلاوة': 3,
    'التشهد': 3,
    'الصلاة على النبي صلى الله عليه وسلم بعد التشهد': 3,
    'الدعاء بعد التشهد الأخير وقبل السلام': 3,
    'الأذكار بعد السلام من الصلاة': 3,
    'دعاء صلاة الاستخارة': 3,
    'دعاء قنوت الوتر': 3,
    'الذكر عقب السلام من الوتر': 3,
    'دعاء الوسوسة في الصلاة والقراءة': 3,

    // ── 4. الطعام والشراب (Food & Drink) ─────────────────────────────────────
    'الدعاء عند إفطار الصائم': 4,
    'الدعاء قبل الطعام': 4,
    'الدعاء عند الفراغ من الطعام': 4,
    'دعاء الضيف لصاحب الطعام': 4,
    'الدعاء لمن سقاه أو إذا أراد ذلك': 4,
    'الدعاء إذا أفطر عند أهل بيت': 4,
    'دعاء الصائم إذا حضر الطعام ولم يفطر': 4,
    'ما يقول الصائم إذا سابه أحد': 4,
    'الدعاء عند رؤية باكورة الثمر': 4,

    // ── 5. السفر والتنقل (Travel & Transit) ──────────────────────────────────
    'دعاء ركوب الدابة': 5,
    'دعاء السفر': 5,
    'دعاء دخول القرية أو البلدة': 5,
    'دعاء دخول السوق': 5,
    'الدعاء إذا تعس المركوب': 5,
    'دعاء المسافر للمقيم': 5,
    'دعاء المقيم للمسافر': 5,
    'التكبير والتسبيح في سير السفر': 5,
    'دعاء المسافر إذا أسحر': 5,
    'الدعاء إذا نزل منزلا في سفر أو غيره': 5,
    'ذكر الرجوع من السفر': 5,

    // ── 6. الفرح والخوف (Joy & Fear) ─────────────────────────────────────────
    'دعاء الهم والحزن': 6,
    'دعاء الكرب': 6,
    'دعاء لقاء العدو وذي السلطان': 6,
    'دعاء من خاف ظلم السلطان': 6,
    'الدعاء على العدو': 6,
    'ما يقول من خاف قوماً': 6,
    'دعاء من أصابه شك في الإيمان': 6,
    'الدعاء قضاء الدين': 6,
    'دعاء من استصعب عليه أمر': 6,
    'دعاء طرد الشيطان ووساوسه': 6,
    'الدعاء حينما يقع مالا يرضاه أو غلب على أمره': 6,
    'دعاء الغضب': 6,
    'دعاء من رأى مبتلى': 6,
    'ما يعصم به من الدجال': 6,
    'دعاء الخوف من الشرك': 6,
    'دعاء كراهية الطيرة': 6,
    'ما يقول ويفعل من أتاه أمر يسره أو يكرهه': 6,
    'ما يقول عند التعجب والأمر السار': 6,
    'ما يفعل من أتاه أمر يسره': 6,
    'دعاء من خشي أن يصيب شيئاً بعينه': 6,
    'ما يقال عند الفزع': 6,
    'ما يقول لرد كيد مردة الشياطين': 6,

    // ── 7. الحج والعمرة (Hajj & Umrah) ───────────────────────────────────────
    'كيف يلبي المحرم في الحج أو العمرة': 7,
    'كيف يلبي المحرم': 7,
    'التكبيرة إذا أتي الركن الأسود': 7,
    'التكبير إذا أتى الركن الأسود': 7,
    'الدعاء بين الركن اليماني والحجر الأسود': 7,
    'دعاء الوقوف على الصفا والمروة': 7,
    'الدعاء يوم عرفة': 7,
    'دعاء يوم عرفة': 7,
    'الذكر عند المشعر الحرام': 7,
    'التكبيرة عند رمي الجمار مع كل حصاة': 7,
    'التكبير عند رمي الجمار مع كل حصاة': 7,
    'التكبير عند رمي الجمار': 7,

    // ── 8. المرض والجنائز (Illness & Funerals) ────────────────────────────────
    'الدعاء للمريض في عيادته': 8,
    'فضل عيادة المريض': 8,
    'دعاء المريض الذي يئس من حياته': 8,
    'تلقين المحتضر': 8,
    'دعاء من أصيب بمصيبة': 8,
    'الدعاء عند إغماض الميت': 8,
    'الدعاء للميت في الصلاة عليه': 8,
    'الدعاء للفرط في الصلاة عليه': 8,
    'دعاء التعزية': 8,
    'الدعاء عند إدخال الميت القبر': 8,
    'الدعاء بعد دفن الميت': 8,
    'دعاء زيارة القبور': 8,
    'ما يقول من أحس وجعاً في جسده': 8,

    // ── 9. التعامل والآداب (Social Conduct & Manners) ─────────────────────────
    'دعاء العطاس': 9,
    'ما يقالُ للكافر إذا عطس فحمد الله': 9,
    'ما يقال في المجلس': 9,
    'كفارة المجلس ومايختم به المجالس': 9,
    'كفارة المجلس': 9,
    'الدعاء لمن قال غفر الله لك': 9,
    'الدعاء لمن صنع إليك معروفاً': 9,
    'الدعاء لمن قال إني أحبك في الله': 9,
    'الدعاء لمن عرض عليك ماله': 9,
    'الدعاء لمن أقرض عند القضاء': 9,
    'الدعاء لمن قال بارك الله فيك': 9,
    'إفشاء السلام': 9,
    'كيف يرد السلام على الكافر إذا سلم': 9,
    'دعاء صياح الديك ونهيق الحمار': 9,
    'دعاء نباح الكلاب بالليل': 9,
    'الدعاء لمن سببته': 9,
    'ما يقول المسلم إذا مدح المسلم': 9,
    'ما يقول المسلم إذا زكي': 9,
    'من أنواع الخير والآداب الجامعة': 9,

    // ── 10. الطبيعة (Nature & Weather) ────────────────────────────────────────
    'دعاء الريح': 10,
    'دعاء الرعد': 10,
    'من أدعية الاستسقاء': 10,
    'الدعاء إذا نزل المطر': 10,
    'الذكر بعد نزول المطر': 10,
    'من أدعية الاستصحاء': 10,
    'دعاء رؤية الهلال': 10,

    // ── 11. التسابيح والاستغفار (Praise & Forgiveness) ────────────────────────
    'فضل الذكر': 11,
    'ما يقول ويفعل من أذنب ذنباً': 11,
    'فضل الصلاة على النبي صلى الله عليه وسلم': 11,
    'الاستغفار والتوبة': 11,
    'فضل التسبيح والتحميد ، والتهليل ، والتكبير': 11,
    'فضل التسبيح والتحميد': 11,
    'كيف كان النبي صلى الله عليه وسلم يسبح ؟': 11,
    'كيف كان النبي يسبح': 11,
  };

  /// Returns whether a chapter name should be completely excluded from regular Dhikr items
  /// (e.g. "المقدمة" introductory treatise).
  static bool shouldExclude(String chapterName) {
    final trimmed = chapterName.trim();
    return trimmed == 'المقدمة' || trimmed.contains('المقدمة');
  }

  /// Resolves a raw chapter name from `hisn_muslim.json` into its parent category ID.
  /// Returns `null` if the chapter is excluded (e.g. "المقدمة").
  static int? resolveParentCategoryId(String chapterName) {
    final trimmed = chapterName.trim();

    // Explicitly exclude introduction
    if (shouldExclude(trimmed)) {
      return null;
    }

    // Direct lookup
    if (_chapterToParentId.containsKey(trimmed)) {
      return _chapterToParentId[trimmed];
    }

    // Keyword heuristics fallback if slight punctuation differences occur
    if (trimmed.contains('صباح') ||
        trimmed.contains('مساء') ||
        trimmed.contains('استيقاظ') ||
        trimmed.contains('النوم')) {
      return 1;
    }
    if (trimmed.contains('ثوب') ||
        trimmed.contains('منزل') ||
        trimmed.contains('خلاء') ||
        trimmed.contains('مولود') ||
        trimmed.contains('زوج') ||
        trimmed.contains('ولد')) {
      return 2;
    }
    if (trimmed.contains('وضوء') ||
        trimmed.contains('مسجد') ||
        trimmed.contains('أذان') ||
        trimmed.contains('صلاة') ||
        trimmed.contains('سجود') ||
        trimmed.contains('ركوع') ||
        trimmed.contains('تشهد') ||
        trimmed.contains('وتر')) {
      return 3;
    }
    if (trimmed.contains('طعام') ||
        trimmed.contains('شراب') ||
        trimmed.contains('أفطر') ||
        trimmed.contains('صائم') ||
        trimmed.contains('ثمر')) {
      return 4;
    }
    if (trimmed.contains('سفر') ||
        trimmed.contains('دابة') ||
        trimmed.contains('سوق') ||
        trimmed.contains('مركوب')) {
      return 5;
    }
    if (trimmed.contains('كرب') ||
        trimmed.contains('هم') ||
        trimmed.contains('حزن') ||
        trimmed.contains('عدو') ||
        trimmed.contains('فزع') ||
        trimmed.contains('غضب') ||
        trimmed.contains('شيطان') ||
        trimmed.contains('دين')) {
      return 6;
    }
    if (trimmed.contains('حج') ||
        trimmed.contains('عمرة') ||
        trimmed.contains('طواف') ||
        trimmed.contains('عرفة') ||
        trimmed.contains('جمار')) {
      return 7;
    }
    if (trimmed.contains('مريض') ||
        trimmed.contains('ميت') ||
        trimmed.contains('قبر') ||
        trimmed.contains('جنازة') ||
        trimmed.contains('مصيبة')) {
      return 8;
    }
    if (trimmed.contains('سلام') ||
        trimmed.contains('مجلس') ||
        trimmed.contains('عطاس') ||
        trimmed.contains('معروف')) {
      return 9;
    }
    if (trimmed.contains('مطر') ||
        trimmed.contains('ريح') ||
        trimmed.contains('رعد') ||
        trimmed.contains('هلال') ||
        trimmed.contains('استسقاء')) {
      return 10;
    }
    if (trimmed.contains('تسبيح') ||
        trimmed.contains('استغفار') ||
        trimmed.contains('توبة') ||
        trimmed.contains('حمد') ||
        trimmed.contains('تهليل')) {
      return 11;
    }

    // Default to Social Conduct & General Ethics
    return 9;
  }
}
