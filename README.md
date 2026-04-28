# محاكي المحاسبة اليمني / Yemen Accounting Simulator

تطبيق تعليمي تفاعلي للمحاسبين المبتدئين في اليمن، مبني بـ Flutter.
An interactive educational application for accounting beginners in Yemen, built with Flutter.

## المميزات / Features

- **لوحة تحكم شاملة** مع إحصائيات سريعة عن التدريبات والدروس والإنجازات.
- **محاكي محاسبي متكامل**: دليل الحسابات، اليومية، العملاء، الموردين، الأصناف، المبيعات، المشتريات، السندات.
- **تقارير محاسبية**: ميزان المراجعة، قائمة الدخل، المركز المالي، تقرير النقدية، تقرير المبيعات، تقرير المخزون، كشف حساب شريك.
- **قسم المحاسبة المالية** مع مستويات وتمارين عملية.
- **18 تدريب عملي** + قسم دروس + اختبارات + قاموس مصطلحات.
- **تتبع التقدم** مع شارات وإنجازات.
- **واجهة عربية كاملة** مع دعم RTL واستخدام `google_fonts` لخط Cairo.
- **تخزين محلي** عبر Hive + shared_preferences.

## متطلبات التشغيل / Prerequisites

- Flutter SDK 3.35.4 (Dart 3.9.2)
- Java OpenJDK 17 (لبناء APK)
- Android SDK API 35

## التثبيت والتشغيل / Setup

```bash
git clone https://github.com/hkllmnnx-maker/yemen-accounting-simulator.git
cd yemen-accounting-simulator
flutter pub get
```

## معاينة الويب / Web Preview

```bash
flutter build web --release
python3 -m http.server 5060 --directory build/web --bind 0.0.0.0
# ثم افتح http://localhost:5060
```

## بناء APK / Build APK

### Debug APK
```bash
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk
```

### Release APK
```bash
flutter build apk --release
```

### في حال نفاذ الذاكرة (Gradle OOM)
عدِّل `android/gradle.properties`:
```properties
org.gradle.jvmargs=-Xmx4G -XX:MaxMetaspaceSize=4G -XX:ReservedCodeCacheSize=512m
```

## الاختبارات / Tests

```bash
flutter analyze        # فحص الكود الثابت
flutter test           # 34 اختبار (smoke + data flow)
```

## المراجعة البصرية / Visual Audit

راجع `VISUAL_AUDIT_REPORT.md` للحصول على تقرير شامل عن مراجعة الواجهة على
أحجام شاشات متعددة (360×640، 390×844، 430×932، 1280×800). اللقطات في
`visual_audit_screenshots/`.

## بنية المشروع / Project Structure

```
lib/
├── main.dart
├── providers/         # AccountingProvider, FinancialAccountingProvider, ProgressProvider
├── screens/           # welcome, dashboard, simulator, reports, lessons, training, …
├── models/            # Hive data models
├── widgets/           # AppDrawer, shared widgets
├── theme/             # AppTheme + colors
└── utils/             # constants & helpers

test/
└── widget_test.dart   # 34 widget + data flow tests

android/, ios/, web/, linux/, macos/, windows/  # Flutter platform folders
```

## الإصدارات / Releases

- APK جاهز: `release_outputs/محاكي_المحاسبة_اليمني-debug.apk`
- راجع `APK_DOWNLOAD.md` و `APK_BUILD_REPORT.md` للتفاصيل.

## الترخيص / License

تطبيق تعليمي – جميع الحقوق محفوظة.
