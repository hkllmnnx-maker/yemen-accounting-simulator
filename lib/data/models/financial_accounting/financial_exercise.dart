/// نماذج تمارين قسم "المحاسبة المالية من القيد إلى التحليل المالي".
///
/// كل تمرين يحاكي عملية واقعية من بيئة يمنية، ويتضمن:
/// - سيناريو واقعي.
/// - تاريخ العملية.
/// - وصف العملية.
/// - المطلوب من المتدرّب.
/// - القيد الصحيح المتوقّع (مع البيانات والمبالغ).
/// - شرح/تصحيح يُعرض بعد المحاولة.

/// تصنيف الحساب وفقًا للمعادلة المحاسبية.
enum FinAccountType {
  asset, // أصل
  liability, // خصم / التزام
  equity, // حقوق ملكية
  revenue, // إيراد
  expense, // مصروف
}

extension FinAccountTypeArabic on FinAccountType {
  String get arabicName {
    switch (this) {
      case FinAccountType.asset:
        return 'أصول';
      case FinAccountType.liability:
        return 'التزامات';
      case FinAccountType.equity:
        return 'حقوق ملكية';
      case FinAccountType.revenue:
        return 'إيرادات';
      case FinAccountType.expense:
        return 'مصروفات';
    }
  }

  /// الطبيعة الافتراضية لرصيد الحساب: مدين/دائن.
  String get normalSide {
    switch (this) {
      case FinAccountType.asset:
      case FinAccountType.expense:
        return 'مدين';
      case FinAccountType.liability:
      case FinAccountType.equity:
      case FinAccountType.revenue:
        return 'دائن';
    }
  }
}

/// كتالوج الحسابات المتاحة داخل تمارين القسم.
/// نستخدم نفس الأسماء على نطاق التمارين لضمان توحيد التحقق.
class FinAccount {
  final String id;
  final String name;
  final FinAccountType type;

  const FinAccount({
    required this.id,
    required this.name,
    required this.type,
  });
}

/// طرف واحد ضمن قيد محاسبي (مدين أو دائن).
class FinJournalLine {
  /// معرّف الحساب من كتالوج التمارين.
  final String accountId;

  /// الطرف: 'debit' أو 'credit'.
  final String side;

  /// المبلغ بالريال اليمني.
  final double amount;

  const FinJournalLine({
    required this.accountId,
    required this.side,
    required this.amount,
  });

  bool get isDebit => side == 'debit';
  bool get isCredit => side == 'credit';
}

/// القيد المتوقّع لتمرين معيّن.
class FinExpectedEntry {
  /// تاريخ القيد.
  final DateTime date;

  /// بيان مختصر يصف العملية.
  final String description;

  /// أطراف القيد (الأطراف المدينة والدائنة).
  final List<FinJournalLine> lines;

  const FinExpectedEntry({
    required this.date,
    required this.description,
    required this.lines,
  });

  double get totalDebit => lines
      .where((l) => l.isDebit)
      .fold<double>(0, (sum, l) => sum + l.amount);

  double get totalCredit => lines
      .where((l) => l.isCredit)
      .fold<double>(0, (sum, l) => sum + l.amount);

  bool get isBalanced => (totalDebit - totalCredit).abs() < 0.001;
}

/// تمرين عملي داخل القسم.
class FinancialExercise {
  /// معرّف فريد للتمرين.
  final String id;

  /// المستوى الذي يتبعه التمرين (نفس `FinancialLesson.id`).
  final String lessonId;

  /// عنوان التمرين.
  final String title;

  /// وصف السيناريو الواقعي (قصة قصيرة).
  final String scenario;

  /// تاريخ افتراضي للعملية.
  final DateTime operationDate;

  /// نص العملية الفعلية المطلوب تسجيلها (وصف العملية).
  final String operationText;

  /// المطلوب من المتدرّب (تعليمات صريحة).
  final String requirement;

  /// تلميحات قبل المحاولة.
  final List<String> hints;

  /// أخطاء شائعة في هذا التمرين.
  final List<String> commonMistakes;

  /// شرح القيد الصحيح بعد الحل.
  final String solutionExplanation;

  /// القيد الصحيح المتوقّع.
  final FinExpectedEntry expected;

  /// نقاط XP عند الحل الصحيح من المحاولة الأولى.
  final int xpReward;

  const FinancialExercise({
    required this.id,
    required this.lessonId,
    required this.title,
    required this.scenario,
    required this.operationDate,
    required this.operationText,
    required this.requirement,
    required this.hints,
    required this.commonMistakes,
    required this.solutionExplanation,
    required this.expected,
    this.xpReward = 8,
  });
}
