import 'financial_exercise.dart';

/// محاولة المتدرّب لحل تمرين قيد يومية.
class JournalEntryAnswer {
  /// تاريخ القيد كما أدخله المتدرّب.
  final DateTime date;

  /// البيان الذي كتبه المتدرّب.
  final String description;

  /// أسطر القيد (الحسابات والمدين/الدائن والمبالغ).
  final List<FinJournalLine> lines;

  const JournalEntryAnswer({
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

  bool get isBalanced =>
      (totalDebit - totalCredit).abs() < 0.001 && totalDebit > 0;
}

/// نتيجة تقييم محاولة المتدرّب.
class JournalCheckResult {
  /// هل القيد متوازن؟ (إجمالي مدين = إجمالي دائن).
  final bool balanced;

  /// هل القيد يطابق القيد الصحيح المتوقّع (نفس الحسابات/الأطراف/المبالغ)؟
  final bool correct;

  /// رسالة عربية واضحة توضّح حالة الحل.
  final String message;

  /// قائمة ملاحظات تفصيلية (أخطاء أو تنبيهات).
  final List<String> issues;

  const JournalCheckResult({
    required this.balanced,
    required this.correct,
    required this.message,
    this.issues = const [],
  });
}
