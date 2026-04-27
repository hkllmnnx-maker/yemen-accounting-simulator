import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../data/models/financial_accounting/financial_exercise.dart';
import '../data/models/financial_accounting/financial_lesson.dart';
import '../data/models/financial_accounting/journal_entry_answer.dart';
import '../data/models/financial_accounting/ledger_account.dart';
import '../data/models/financial_accounting/financial_statement.dart';
import '../data/repositories/database_service.dart';
import '../data/seed/financial_accounting_content.dart';
import '../data/seed/financial_accounts_catalog.dart';
import '../data/seed/financial_exercises_content.dart';

/// مُزوِّد إدارة حالة قسم "المحاسبة المالية من القيد إلى التحليل المالي".
///
/// يحتوي على:
/// - قائمة المستويات والتمارين.
/// - تتبّع التمارين/المستويات المنجَزة.
/// - تقييم محاولات المتدرّب.
/// - مخزن قيود اليومية الخاص بشاشة المحاكاة.
/// - بناء دفتر الأستاذ، ميزان المراجعة، القوائم المالية، النسب.
class FinancialAccountingProvider extends ChangeNotifier {
  // ====== التقدّم ======
  final Set<String> _completedExercises = {};
  final Set<String> _completedLessons = {};

  Set<String> get completedExercises => _completedExercises;
  Set<String> get completedLessons => _completedLessons;

  // ====== قيود يومية المحاكاة ======
  /// كل قيد عبارة عن JournalEntryAnswer (له تاريخ وبيان وأسطر).
  final List<JournalEntryAnswer> _simJournal = [];
  List<JournalEntryAnswer> get simJournal => List.unmodifiable(_simJournal);

  // ====== المستويات والتمارين ======
  List<FinancialLesson> get lessons => financialLessons;

  FinancialLesson? lessonById(String id) {
    for (final l in financialLessons) {
      if (l.id == id) return l;
    }
    return null;
  }

  List<FinancialExercise> exercisesOf(String lessonId) =>
      exercisesForLesson(lessonId);

  // ====== التحميل والحفظ ======
  Future<void> load() async {
    _completedExercises
      ..clear()
      ..addAll(DatabaseService.getFaCompletedExercises());
    _completedLessons
      ..clear()
      ..addAll(DatabaseService.getFaCompletedLessons());

    final raw = DatabaseService.getFaSimJournalRaw();
    _simJournal.clear();
    if (raw != null && raw.isNotEmpty) {
      try {
        final list = jsonDecode(raw) as List;
        for (final m in list) {
          final map = Map<String, dynamic>.from(m as Map);
          _simJournal.add(_journalFromMap(map));
        }
      } catch (_) {
        // تجاهل البيانات التالفة.
        _simJournal.clear();
      }
    }
    notifyListeners();
  }

  Future<void> _saveExercises() async {
    await DatabaseService.setFaCompletedExercises(_completedExercises.toList());
  }

  Future<void> _saveLessons() async {
    await DatabaseService.setFaCompletedLessons(_completedLessons.toList());
  }

  Future<void> _saveSimJournal() async {
    final list = _simJournal.map(_journalToMap).toList();
    await DatabaseService.setFaSimJournalRaw(jsonEncode(list));
  }

  // ====== تتبّع التقدّم ======
  bool isExerciseCompleted(String id) => _completedExercises.contains(id);
  bool isLessonCompleted(String id) => _completedLessons.contains(id);

  /// نسبة إنجاز مستوى محدد (تمارينه المنجزة من إجمالي تمارينه).
  double lessonProgress(String lessonId) {
    final exercises = exercisesForLesson(lessonId);
    if (exercises.isEmpty) {
      return _completedLessons.contains(lessonId) ? 1.0 : 0.0;
    }
    final done = exercises.where((e) => isExerciseCompleted(e.id)).length;
    return done / exercises.length;
  }

  /// نسبة إنجاز القسم بالكامل (مستويات منجزة + تمارين منجزة).
  double get sectionProgress {
    int total = 0;
    int done = 0;
    for (final l in financialLessons) {
      total++;
      if (isLessonCompleted(l.id)) done++;
      final exs = exercisesForLesson(l.id);
      total += exs.length;
      done += exs.where((e) => isExerciseCompleted(e.id)).length;
    }
    if (total == 0) return 0;
    return done / total;
  }

  Future<void> markLessonCompleted(String id) async {
    if (_completedLessons.add(id)) {
      await _saveLessons();
      notifyListeners();
    }
  }

  Future<void> markExerciseCompleted(String id) async {
    if (_completedExercises.add(id)) {
      await _saveExercises();
      notifyListeners();
    }
  }

  // ====== تقييم محاولات المتدرّب ======
  /// يقارن محاولة المتدرّب بالقيد الصحيح.
  /// نتساهل في ترتيب الأسطر، لكن يجب توافق:
  /// - الحسابات على كل جانب
  /// - الأطراف (مدين/دائن)
  /// - المبالغ بدقة 0.01
  /// - توازن القيد
  JournalCheckResult evaluateAnswer(
    FinancialExercise exercise,
    JournalEntryAnswer answer,
  ) {
    final issues = <String>[];

    // 1) لا يوجد أسطر.
    if (answer.lines.isEmpty) {
      return const JournalCheckResult(
        balanced: false,
        correct: false,
        message: 'لا يمكن حفظ قيد فارغ. أضف أسطر القيد أولًا.',
      );
    }

    // 2) أي مبلغ صفر أو سالب.
    for (final l in answer.lines) {
      if (l.amount <= 0) {
        return const JournalCheckResult(
          balanced: false,
          correct: false,
          message: 'لا يُسمح بمبلغ صفر أو سالب في أي طرف من القيد.',
        );
      }
    }

    // 3) التوازن.
    if (!answer.isBalanced) {
      return JournalCheckResult(
        balanced: false,
        correct: false,
        message:
            'القيد غير متوازن. مجموع المدين ${answer.totalDebit.toStringAsFixed(2)} '
            'لا يساوي مجموع الدائن ${answer.totalCredit.toStringAsFixed(2)}.',
      );
    }

    // 4) مطابقة الأطراف مع القيد المتوقّع.
    final expected = exercise.expected;
    if (answer.totalDebit - expected.totalDebit != 0) {
      issues.add(
        'إجمالي المبالغ في قيدك ${answer.totalDebit.toStringAsFixed(2)} ر.ي بينما المتوقّع ${expected.totalDebit.toStringAsFixed(2)} ر.ي.',
      );
    }

    final expSet = _toMatchSet(expected.lines);
    final ansSet = _toMatchSet(answer.lines);

    final missing = expSet.difference(ansSet);
    final extra = ansSet.difference(expSet);

    for (final m in missing) {
      issues.add('ينقص في قيدك: $m');
    }
    for (final e in extra) {
      issues.add('سطر زائد أو غير صحيح: $e');
    }

    if (missing.isEmpty && extra.isEmpty && issues.isEmpty) {
      return const JournalCheckResult(
        balanced: true,
        correct: true,
        message: 'أحسنت! قيدك متوازن ومطابق للحل الصحيح.',
      );
    }

    return JournalCheckResult(
      balanced: true,
      correct: false,
      message:
          'القيد متوازن لكنه لا يطابق الحل الصحيح. راجع الملاحظات أدناه ثم حاول مجددًا.',
      issues: issues,
    );
  }

  /// تحويل أطراف القيد إلى مجموعة قابلة للمقارنة دون اعتبار للترتيب.
  Set<String> _toMatchSet(List<FinJournalLine> lines) {
    return lines
        .map((l) => '${l.accountId}|${l.side}|${l.amount.toStringAsFixed(2)}')
        .toSet();
  }

  // ====== عمليات يومية المحاكاة ======
  /// إضافة قيد إلى يومية المحاكاة. يرفض القيد غير المتوازن.
  String? addSimEntry(JournalEntryAnswer entry) {
    if (entry.lines.isEmpty) return 'لا يمكن حفظ قيد بدون حسابات.';
    for (final l in entry.lines) {
      if (l.amount <= 0) {
        return 'لا يسمح بمبلغ صفر أو سالب.';
      }
    }
    if (!entry.isBalanced) {
      return 'القيد غير متوازن: مجموع المدين لا يساوي مجموع الدائن.';
    }
    _simJournal.add(entry);
    _saveSimJournal();
    notifyListeners();
    return null;
  }

  /// حذف قيد من يومية المحاكاة بترتيبه.
  void removeSimEntry(int index) {
    if (index < 0 || index >= _simJournal.length) return;
    _simJournal.removeAt(index);
    _saveSimJournal();
    notifyListeners();
  }

  /// مسح كل قيود المحاكاة (مع تأكيد من المتصل).
  Future<void> clearSimJournal() async {
    _simJournal.clear();
    await DatabaseService.clearFaSimJournal();
    notifyListeners();
  }

  // ====== بناء دفتر الأستاذ ======
  /// كشف حساب لكل حساب فعّل في القيود.
  List<LedgerAccountStatement> buildLedger() {
    final byAccount = <String, List<LedgerEntry>>{};
    for (final j in _simJournal) {
      for (final l in j.lines) {
        byAccount
            .putIfAbsent(l.accountId, () => [])
            .add(
              LedgerEntry(
                date: j.date,
                description: j.description,
                debit: l.isDebit ? l.amount : 0,
                credit: l.isCredit ? l.amount : 0,
              ),
            );
      }
    }
    final result = <LedgerAccountStatement>[];
    byAccount.forEach((accountId, entries) {
      final acc = FinAccountsCatalog.byId(accountId);
      if (acc == null) return;
      // ترتيب حسب التاريخ.
      entries.sort((a, b) => a.date.compareTo(b.date));
      result.add(
        LedgerAccountStatement(
          accountId: acc.id,
          accountName: acc.name,
          accountType: acc.type,
          entries: entries,
        ),
      );
    });
    // ترتيب الحسابات: أصول، التزامات، حقوق ملكية، إيرادات، مصروفات.
    result.sort((a, b) => a.accountType.index - b.accountType.index);
    return result;
  }

  // ====== ميزان المراجعة ======
  List<TrialBalanceRow> buildTrialBalance() {
    final ledger = buildLedger();
    return ledger
        .map((l) {
          final diff = l.totalDebit - l.totalCredit;
          double debit = 0;
          double credit = 0;
          // الجانب الطبيعي يحدّد عمود الرصيد.
          if (diff > 0) {
            debit = diff;
          } else if (diff < 0) {
            credit = -diff;
          }
          return TrialBalanceRow(
            accountId: l.accountId,
            accountName: l.accountName,
            accountType: l.accountType,
            debitBalance: debit,
            creditBalance: credit,
          );
        })
        .where((r) => r.debitBalance > 0 || r.creditBalance > 0)
        .toList();
  }

  double get trialBalanceTotalDebit =>
      buildTrialBalance().fold<double>(0, (s, r) => s + r.debitBalance);
  double get trialBalanceTotalCredit =>
      buildTrialBalance().fold<double>(0, (s, r) => s + r.creditBalance);
  bool get trialBalanceBalanced =>
      (trialBalanceTotalDebit - trialBalanceTotalCredit).abs() < 0.01;

  // ====== قائمة الدخل ======
  IncomeStatement buildIncomeStatement() {
    final ledger = buildLedger();
    final revenues = <FinancialStatementLine>[];
    final expenses = <FinancialStatementLine>[];

    for (final l in ledger) {
      // معاملة خاصة لمردودات المبيعات (تخفّض الإيرادات => تُعرَض ضمن مصروفات تخفيض الإيراد).
      // ومعاملة الخصم المسموح به كمصروف، الخصم المكتسب كإيراد.
      switch (l.accountType) {
        case FinAccountType.revenue:
          // الإيراد = الجانب الطبيعي دائن => الرصيد الموجب على الدائن.
          final amount = l.totalCredit - l.totalDebit;
          if (amount > 0) {
            revenues.add(
              FinancialStatementLine(label: l.accountName, amount: amount),
            );
          }
          break;
        case FinAccountType.expense:
          final amount = l.totalDebit - l.totalCredit;
          if (amount > 0) {
            expenses.add(
              FinancialStatementLine(label: l.accountName, amount: amount),
            );
          }
          break;
        default:
          break;
      }
    }

    // معاملة المشتريات: تُحوَّل إلى تكلفة بضاعة مباعة بتبسيط
    // (جميع المشتريات تُعتبر مباعة في هذا التطبيق التعليمي).
    final purchasesEntry = ledger.firstWhere(
      (l) => l.accountId == 'purchases',
      orElse: () => const LedgerAccountStatement(
        accountId: 'purchases',
        accountName: 'المشتريات',
        accountType: FinAccountType.asset,
        entries: [],
      ),
    );
    final purchasesAmount =
        purchasesEntry.totalDebit - purchasesEntry.totalCredit;
    if (purchasesAmount > 0) {
      expenses.add(
        FinancialStatementLine(
          label: 'تكلفة البضاعة المباعة (المشتريات)',
          amount: purchasesAmount,
        ),
      );
    }

    return IncomeStatement(revenues: revenues, expenses: expenses);
  }

  // ====== قائمة المركز المالي ======
  BalanceSheetReport buildBalanceSheet() {
    final ledger = buildLedger();
    final assets = <FinancialStatementLine>[];
    final liabilities = <FinancialStatementLine>[];
    final equity = <FinancialStatementLine>[];

    for (final l in ledger) {
      // المشتريات تُستهلك في قائمة الدخل، فلا تظهر في الميزانية إلا إذا تبقّى منها مخزون،
      // ولأجل التبسيط لا نضيفها هنا.
      if (l.accountId == 'purchases') continue;

      switch (l.accountType) {
        case FinAccountType.asset:
          final balance = l.totalDebit - l.totalCredit;
          if (balance != 0) {
            assets.add(
              FinancialStatementLine(label: l.accountName, amount: balance),
            );
          }
          break;
        case FinAccountType.liability:
          final balance = l.totalCredit - l.totalDebit;
          if (balance != 0) {
            liabilities.add(
              FinancialStatementLine(label: l.accountName, amount: balance),
            );
          }
          break;
        case FinAccountType.equity:
          final balance = l.totalCredit - l.totalDebit;
          if (balance != 0) {
            equity.add(
              FinancialStatementLine(label: l.accountName, amount: balance),
            );
          }
          break;
        default:
          break;
      }
    }

    final income = buildIncomeStatement();
    return BalanceSheetReport(
      assets: assets,
      liabilities: liabilities,
      equity: equity,
      netIncome: income.netIncome,
    );
  }

  // ====== قائمة التدفقات النقدية المبسّطة ======
  SimpleCashFlowStatement buildCashFlow() {
    final inflows = <FinancialStatementLine>[];
    final outflows = <FinancialStatementLine>[];

    double totalIn = 0;
    double totalOut = 0;
    for (final j in _simJournal) {
      for (final l in j.lines) {
        if (l.accountId == 'cash' || l.accountId == 'bank') {
          if (l.isDebit) {
            totalIn += l.amount;
            inflows.add(
              FinancialStatementLine(label: j.description, amount: l.amount),
            );
          } else {
            totalOut += l.amount;
            outflows.add(
              FinancialStatementLine(label: j.description, amount: l.amount),
            );
          }
        }
      }
    }

    // تجميع غير ضروري - نعرض التفاصيل كما هي.
    // المتغيرات `totalIn` و`totalOut` للتوافق مع منطق سابق.
    debugPrint('CashFlow inflows=$totalIn outflows=$totalOut');
    return SimpleCashFlowStatement(inflows: inflows, outflows: outflows);
  }

  // ====== التحليل المالي ======
  /// قائمة النسب الأساسية الناتجة عن المحاكاة.
  List<FinancialRatio> buildRatios() {
    final bs = buildBalanceSheet();
    final inc = buildIncomeStatement();

    // الأصول المتداولة: الصندوق + البنك + العملاء + المخزون + المواد + الإيجار المدفوع مقدّماً.
    final currentAssetIds = {
      'cash',
      'bank',
      'accounts_receivable',
      'notes_receivable',
      'inventory',
      'supplies',
      'prepaid_rent',
    };
    final currentLiabIds = {
      'accounts_payable',
      'notes_payable',
      'salaries_payable',
    };

    // استخدم ledger للحصول على أرصدة دقيقة لكل حساب على حدة.
    final ledger = buildLedger();
    double currentAssets = 0;
    for (final l in ledger) {
      final balance = l.totalDebit - l.totalCredit;
      if (currentAssetIds.contains(l.accountId) && balance > 0) {
        currentAssets += balance;
      }
    }

    double currentLiabilities = 0;
    for (final l in ledger) {
      final balance = l.totalCredit - l.totalDebit;
      if (currentLiabIds.contains(l.accountId) && balance > 0) {
        currentLiabilities += balance;
      }
    }

    final totalAssets = bs.totalAssets;
    final totalLiab = bs.totalLiabilities;
    final netIncome = inc.netIncome;
    final netSales = inc.totalRevenues;

    final ratios = <FinancialRatio>[];

    // 1) نسبة التداول
    if (currentLiabilities > 0) {
      final v = currentAssets / currentLiabilities;
      ratios.add(
        FinancialRatio(
          name: 'نسبة التداول',
          value: double.parse(v.toStringAsFixed(2)),
          unit: 'مرة',
          formula: 'الأصول المتداولة ÷ الالتزامات المتداولة',
          interpretation: v >= 2
              ? 'سيولة جيدة جدًا، المنشأة قادرة على سداد ديونها قصيرة الأجل.'
              : v >= 1
              ? 'سيولة مقبولة، يفضّل تحسينها لتقترب من 2.'
              : 'سيولة ضعيفة، قد تواجه المنشأة صعوبة في سداد التزاماتها.',
        ),
      );
    } else {
      ratios.add(
        const FinancialRatio(
          name: 'نسبة التداول',
          value: 0,
          unit: 'مرة',
          formula: 'الأصول المتداولة ÷ الالتزامات المتداولة',
          interpretation:
              'لا توجد التزامات متداولة، لذا لا يمكن حساب النسبة بشكل ذي معنى.',
        ),
      );
    }

    // 2) هامش الربح الصافي
    if (netSales > 0) {
      final v = netIncome / netSales * 100;
      ratios.add(
        FinancialRatio(
          name: 'هامش الربح الصافي',
          value: double.parse(v.toStringAsFixed(2)),
          unit: '%',
          formula: '(صافي الربح ÷ صافي المبيعات) × 100%',
          interpretation: v >= 15
              ? 'هامش ربح ممتاز.'
              : v >= 5
              ? 'هامش ربح مقبول.'
              : v >= 0
              ? 'هامش ربح ضعيف، راجع المصروفات والتسعير.'
              : 'المنشأة تحقّق خسارة، يلزم اتخاذ إجراءات عاجلة.',
        ),
      );
    }

    // 3) العائد على الأصول (ROA)
    if (totalAssets > 0) {
      final v = netIncome / totalAssets * 100;
      ratios.add(
        FinancialRatio(
          name: 'العائد على الأصول (ROA)',
          value: double.parse(v.toStringAsFixed(2)),
          unit: '%',
          formula: '(صافي الربح ÷ إجمالي الأصول) × 100%',
          interpretation: v >= 10
              ? 'كفاءة عالية في استخدام الأصول.'
              : v >= 3
              ? 'كفاءة مقبولة في استخدام الأصول.'
              : 'الأصول لا تحقّق عائدًا كافيًا، حسّن الإنتاجية.',
        ),
      );
    }

    // 4) نسبة المديونية
    if (totalAssets > 0) {
      final v = totalLiab / totalAssets * 100;
      ratios.add(
        FinancialRatio(
          name: 'نسبة المديونية',
          value: double.parse(v.toStringAsFixed(2)),
          unit: '%',
          formula: '(إجمالي الالتزامات ÷ إجمالي الأصول) × 100%',
          interpretation: v <= 40
              ? 'هيكل تمويل صحي، الاعتماد على الديون منخفض.'
              : v <= 60
              ? 'مستوى مديونية متوسط، تابع باستمرار.'
              : 'مستوى مديونية مرتفع، ارتفاع المخاطرة المالية.',
        ),
      );
    }

    return ratios;
  }

  // ====== تحويلات JSON لقيود المحاكاة ======
  Map<String, dynamic> _journalToMap(JournalEntryAnswer a) => {
    'date': a.date.toIso8601String(),
    'description': a.description,
    'lines': a.lines
        .map(
          (l) => {'accountId': l.accountId, 'side': l.side, 'amount': l.amount},
        )
        .toList(),
  };

  JournalEntryAnswer _journalFromMap(Map<String, dynamic> m) {
    final lines = ((m['lines'] as List?) ?? const []).map((e) {
      final lm = Map<String, dynamic>.from(e as Map);
      return FinJournalLine(
        accountId: lm['accountId'] as String,
        side: lm['side'] as String,
        amount: (lm['amount'] as num).toDouble(),
      );
    }).toList();
    return JournalEntryAnswer(
      date: DateTime.parse(m['date'] as String),
      description: (m['description'] as String?) ?? '',
      lines: lines,
    );
  }
}
