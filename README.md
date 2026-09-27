# أَوْرَاد — Awrad (Islamic Dhikr Companion)

<div align="center">

![Awrad App Banner](https://img.shields.io/badge/Platform-Flutter%20%7C%20Android%20%7C%20iOS-008080?style=for-the-badge&logo=flutter)
![Offline First](https://img.shields.io/badge/Network-100%25%20Offline-success?style=for-the-badge)
![Tests](https://img.shields.io/badge/Tests-70%2F70%20Passing-brightgreen?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-gold?style=for-the-badge)

**تطبيق أذكار إسلامي متكامل يعمل 100% دون الحاجة إلى الاتصال بالإنترنت، مبني بأحدث تقنيات Flutter و Clean Architecture.**

[المميزات](#المميزات) • [البنية الهندسية](#البنية-الهندسية) • [طريقة التشغيل](#طريقة-التشغيل) • [الاختبارات](#الاختبارات)

</div>

---

## 📖 نظرة عامة (Overview)

**أَوْرَاد (Awrad)** هو تطبيق إسلامي مفتوح المصدر وموجه للأذكار اليومية والأدعية المأثورة من كتاب **حصن المسلم**. يتميز التطبيق بالعمل الكامل بدون إنترنت مع صفر اتصالات خارجية، مما يضمن الخصوصية التامة والسرعة الفائقة مع مراعاة أعلى معايير التصميم والتجربة البصرية.

---

## ✨ المميزات الرئيسية (Features)

- 🌙 **قاعدة بيانات موثقة 3 مستويات (3-Tier Hierarchy):**
  - تصنيف محكم للأبواب: *أقسام رئيسية (Parent Categories) ← فصول وأبواب (Sub-Categories) ← نصوص الأذكار (Dhikr Items)*.
  - فصل تام ودقيق بين **أذكار الصباح** و**أذكار المساء** مع مواءمة الحواشي والتخريج وتكرار كل ذكر.

- 📿 **المسبحة الإلكترونية الحرة (Electronic Tasbeeh):**
  - عداد تفاعلي سلس مع أهداف متغيرة (33، 99، 100، أو غير محدود).
  - ردود فعل لمسية ذكية (Haptic Feedback) وصوت نقر خفيف (متاح كخيار).
  - حفظ تلقائي للعدد الإجمالي والمستهدفات عبر الجلسات.

- ⏰ **محرك التنبيهات والأذكار اليومية (Offline Notifications):**
  - جدولة تنبيهات يومية متكررة لأذكار الصباح (06:00 ص) وأذكار المساء (04:30 م).
  - وضعان للجدولة: **المواعيد الموصى بها (افتراضي)** أو **أوقات مخصصة (Custom Time Picker)**.
  - إمكانية تفعيل/تعطيل كل تنبيه بشكل مستقل.
  - دعم الربط المباشر (Deep-Linking) عند النقر على الإشعار لفتح شاشة القراءة مباشرة.

- 📤 **محرك المشاركة (Sharing Engine):**
  - **مشاركة النص:** مشاركة نص الذكر مع فضله ومصدره منسقاً بشكل أنيق.
  - **مشاركة كصورة:** التقاط بطاقة الذكر بدقة فائقة كصورة PNG ومشاركتها عبر التطبيقات دون أي اتصال بشبكة.

- 🎨 **خيارات بصرية ومطبعية راقية (Typography & Theming):**
  - خطوط عربية أصيلة معدة ومضمنة محلياً (*Amiri, Scheherazade New, Lateef*).
  - تحكم مرن في تكبير وتصغير حجم الخط مع نافذة معاينة حيّة (Live Font Scaling).
  - دعم كامل للوضع الليلي والنهاري (Dark / Light Theme).

---

## 🏗️ البنية الهندسية (Clean Architecture)

تم بناء المشروع باتباع مبادئ **Clean Architecture** مع فصل تام للمسؤوليات وإدارة الحالة باستخدام **BLoC / Cubit**:

```
lib/
├── core/                  # الأدوات المساعدة، السمات، الخدمات العامة والثريد الزمني
│   ├── constants/         # الثوابت ومفاتيح التخزين
│   ├── errors/            # معالجة الأخطاء والإخفاقات
│   ├── services/          # خدمات التنبيهات (NotificationService) والصوت (SoundService)
│   ├── theme/             # سمات وألوان التطبيق (AppTheme)
│   └── utils/             # دوال التشكيل، التطبيع، والمشاركة
├── data/                  # طبقة البيانات والاتصال المحلي
│   ├── datasources/local/ # قاعدة بيانات SQLite ومحرك البذر (DatabaseSeeder)
│   ├── models/            # نماذج تحويل البيانات من JSON وإلى SQLite
│   └── repositories/      # تطبيقات المستودعات (DhikrRepositoryImpl, StatisticsRepositoryImpl)
├── domain/                # طبقة المجال (الكيانات والمستودعات المجردة)
│   ├── entities/          # الكيانات النقية (DhikrItem, SubCategory, ParentCategory)
│   └── repositories/      # واجهات المستودعات (DhikrRepository, StatisticsRepository)
└── presentation/          # واجهة المستخدم وإدارة الحالة
    ├── blocs/             # وحدات BLoC و Cubit (Dhikr, Category, Tasbeeh, Settings, Theme, Search)
    ├── screens/           # الشاشات الرئيسية والقراءة والإعدادات
    └── widgets/           # المكونات القابلة لإعادة الاستخدام (بطاقة الذكر، حوار الإتمام)
```

---

## 🚀 طريقة التثبيت والتشغيل (Getting Started)

### المتطلبات الأساسية
- Flutter SDK (نسخة 3.5.0 أو أحدث)
- Dart SDK (نسخة 3.5.0 أو أحدث)
- Android Studio / VS Code

### خطوات التشغيل
1. استنساخ المستودع:
   ```bash
   git clone https://github.com/USERNAME/awrad_app.git
   cd awrad_app
   ```
2. تثبيت الحزم والمكتبات:
   ```bash
   flutter pub get
   ```
3. تشغيل التطبيق على الجهاز أو المحاكي:
   ```bash
   flutter run
   ```

---

## 🧪 الاختبارات الآلية (Automated Tests)

يحتوي التطبيق على حزمة اختبارات شاملة تغطي كافة الوحدات (BLoC, Database Seeder, Widget Layouts, Font Scalability, Notifications):

```bash
flutter test
```

> **النتيجة:** 70 اختباراً ناجحاً بنسبة 100% دون أي أخطاء أو تحذيرات.

---

## 📄 الترخيص (License)

هذا المشروع مرخص تحت رخصة **MIT** - لك كامل الحرية في استخدامه وتطويره صدقةً جارية.
