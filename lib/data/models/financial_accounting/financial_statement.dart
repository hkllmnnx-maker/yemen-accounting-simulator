/// نماذج القوائم المالية والتحليل المالي المستخدمة داخل قسم
/// "المحاسبة المالية من القيد إلى التحليل المالي".
library;

class FinancialStatementLine {
  final String label;
  final double amount;

  /// هل هذا السطر إجمالي/صافٍ يُعرض بصورة مميّزة؟
  final bool isTotal;

  /// هل يمثل قيمة سالبة (مثل الإهلاك أو المردودات) لأغراض العرض؟
  final bool isNegative;

  const FinancialStatementLine({
    required this.label,
    required this.amount,
    this.isTotal = false,
    this.isNegative = false,
  });
}

/// قائمة الدخل: الإيرادات - المصروفات = صافي الربح/الخسارة.
class IncomeStatement {
  final List<FinancialStatementLine> revenues;
  final List<FinancialStatementLine> expenses;

  const IncomeStatement({required this.revenues, required this.expenses});

  double get totalRevenues => revenues.fold<double>(0, (s, l) => s + l.amount);
  double get totalExpenses => expenses.fold<double>(0, (s, l) => s + l.amount);
  double get netIncome => totalRevenues - totalExpenses;
}

/// قائمة المركز المالي: الأصول = الالتزامات + حقوق الملكية.
class BalanceSheetReport {
  final List<FinancialStatementLine> assets;
  final List<FinancialStatementLine> liabilities;
  final List<FinancialStatementLine> equity;

  /// صافي ربح/خسارة الفترة (يُضاف إلى حقوق الملكية).
  final double netIncome;

  const BalanceSheetReport({
    required this.assets,
    required this.liabilities,
    required this.equity,
    required this.netIncome,
  });

  double get totalAssets => assets.fold<double>(0, (s, l) => s + l.amount);
  double get totalLiabilities =>
      liabilities.fold<double>(0, (s, l) => s + l.amount);

  /// إجمالي حقوق الملكية = رأس المال وما شابهه + صافي الربح.
  double get totalEquity =>
      equity.fold<double>(0, (s, l) => s + l.amount) + netIncome;

  double get totalLiabilitiesAndEquity => totalLiabilities + totalEquity;

  bool get isBalanced => (totalAssets - totalLiabilitiesAndEquity).abs() < 0.5;
}

/// قائمة تدفقات نقدية مبسّطة (افتراضية - تعتمد على حركات النقدية فقط).
class SimpleCashFlowStatement {
  final List<FinancialStatementLine> inflows; // تدفقات داخلة
  final List<FinancialStatementLine> outflows; // تدفقات خارجة
  final double openingCash; // الرصيد الافتتاحي (افتراضي = 0)

  const SimpleCashFlowStatement({
    required this.inflows,
    required this.outflows,
    this.openingCash = 0,
  });

  double get totalInflows => inflows.fold<double>(0, (s, l) => s + l.amount);
  double get totalOutflows => outflows.fold<double>(0, (s, l) => s + l.amount);
  double get netCashFlow => totalInflows - totalOutflows;
  double get endingCash => openingCash + netCashFlow;
}

/// نسبة مالية مع شرحها.
class FinancialRatio {
  final String name;
  final double value;
  final String unit; // 'مرة' أو '%'
  final String formula;
  final String interpretation;

  const FinancialRatio({
    required this.name,
    required this.value,
    required this.unit,
    required this.formula,
    required this.interpretation,
  });
}
