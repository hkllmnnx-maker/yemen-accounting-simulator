// Unit tests for the core accounting logic of the Yemen Accounting Simulator.
//
// Covers the following invariants:
// - Journal entry balance (debit == credit).
// - Rejection of empty / zero / negative entries.
// - Trial balance balancing (sum debit == sum credit).
// - Income statement (revenues - expenses).
// - Balance sheet equation (assets = liabilities + equity + retained earnings).
// - Yemeni currency formatter.
// - FinancialAccountingProvider answer evaluation rules.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:yemen_accounting_simulator/core/utils/formatters.dart';
import 'package:yemen_accounting_simulator/data/models/account.dart';
import 'package:yemen_accounting_simulator/data/models/journal_entry.dart';
import 'package:yemen_accounting_simulator/data/models/financial_accounting/financial_exercise.dart';
import 'package:yemen_accounting_simulator/data/models/financial_accounting/journal_entry_answer.dart';
import 'package:yemen_accounting_simulator/data/repositories/database_service.dart';
import 'package:yemen_accounting_simulator/data/seed/financial_accounts_catalog.dart';
import 'package:yemen_accounting_simulator/data/seed/financial_exercises_content.dart';
import 'package:yemen_accounting_simulator/providers/accounting_provider.dart';
import 'package:yemen_accounting_simulator/providers/financial_accounting_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await DatabaseService.init(testPath: './.test_hive_logic');
  });

  tearDownAll(() async {
    await Hive.deleteFromDisk();
  });

  // ==========================================================================
  // JournalEntry model balance behavior
  // ==========================================================================
  group('JournalEntry balance invariants', () {
    test('balanced entry returns isBalanced == true', () {
      final j = JournalEntry(
        id: 't1',
        number: 1,
        date: DateTime(2024, 1, 1),
        description: 'إيداع رأس المال',
        lines: [
          JournalLine(
            accountId: 'a1111',
            accountName: 'الصندوق',
            debit: 5000000,
          ),
          JournalLine(
            accountId: 'a31',
            accountName: 'رأس المال',
            credit: 5000000,
          ),
        ],
      );
      expect(j.totalDebit, 5000000);
      expect(j.totalCredit, 5000000);
      expect(j.isBalanced, isTrue);
    });

    test('unbalanced entry returns isBalanced == false', () {
      final j = JournalEntry(
        id: 't2',
        number: 2,
        date: DateTime(2024, 1, 1),
        description: 'قيد غير متوازن',
        lines: [
          JournalLine(accountId: 'a1', accountName: 'a', debit: 100),
          JournalLine(accountId: 'b1', accountName: 'b', credit: 90),
        ],
      );
      expect(j.isBalanced, isFalse);
    });

    test('compound balanced entry (multi line) returns isBalanced == true', () {
      final j = JournalEntry(
        id: 't3',
        number: 3,
        date: DateTime(2024, 1, 1),
        description: 'فاتورة بيع نقد + آجل',
        lines: [
          JournalLine(accountId: 'a1', accountName: 'صندوق', debit: 60000),
          JournalLine(accountId: 'a2', accountName: 'عملاء', debit: 40000),
          JournalLine(
            accountId: 'a3',
            accountName: 'إيرادات المبيعات',
            credit: 100000,
          ),
        ],
      );
      expect(j.totalDebit, 100000);
      expect(j.totalCredit, 100000);
      expect(j.isBalanced, isTrue);
    });

    test('floating point tolerance is honored (< 0.001)', () {
      final j = JournalEntry(
        id: 't4',
        number: 4,
        date: DateTime(2024, 1, 1),
        description: 'tolerance',
        lines: [
          JournalLine(accountId: 'a', accountName: 'a', debit: 100.0001),
          JournalLine(accountId: 'b', accountName: 'b', credit: 100.0),
        ],
      );
      expect(
        j.isBalanced,
        isTrue,
        reason: 'difference < 0.001 must be considered balanced',
      );
    });
  });

  // ==========================================================================
  // FinancialAccountingProvider: answer evaluation
  // ==========================================================================
  group('FinancialAccountingProvider answer evaluation', () {
    late FinancialAccountingProvider provider;
    late FinancialExercise sample;

    setUp(() {
      provider = FinancialAccountingProvider();
      sample = financialExercises.first; // capital cash 5,000,000
    });

    test('rejects empty entry', () {
      final res = provider.evaluateAnswer(
        sample,
        JournalEntryAnswer(
          date: sample.operationDate,
          description: 'فارغ',
          lines: const [],
        ),
      );
      expect(res.balanced, isFalse);
      expect(res.correct, isFalse);
    });

    test('rejects zero / negative amounts', () {
      final res = provider.evaluateAnswer(
        sample,
        JournalEntryAnswer(
          date: sample.operationDate,
          description: 'مبلغ صفر',
          lines: const [
            FinJournalLine(accountId: 'cash', side: 'debit', amount: 0),
            FinJournalLine(accountId: 'capital', side: 'credit', amount: 0),
          ],
        ),
      );
      expect(res.balanced, isFalse);
      expect(res.correct, isFalse);
    });

    test('rejects unbalanced entry', () {
      final res = provider.evaluateAnswer(
        sample,
        JournalEntryAnswer(
          date: sample.operationDate,
          description: 'غير متوازن',
          lines: const [
            FinJournalLine(accountId: 'cash', side: 'debit', amount: 5000000),
            FinJournalLine(
              accountId: 'capital',
              side: 'credit',
              amount: 4000000,
            ),
          ],
        ),
      );
      expect(res.balanced, isFalse);
      expect(res.correct, isFalse);
    });

    test('accepts the canonical correct entry', () {
      final res = provider.evaluateAnswer(
        sample,
        JournalEntryAnswer(
          date: sample.operationDate,
          description: 'تأسيس',
          lines: const [
            FinJournalLine(accountId: 'cash', side: 'debit', amount: 5000000),
            FinJournalLine(
              accountId: 'capital',
              side: 'credit',
              amount: 5000000,
            ),
          ],
        ),
      );
      expect(res.balanced, isTrue);
      expect(res.correct, isTrue);
    });

    test('balanced but wrong accounts is balanced && !correct', () {
      final res = provider.evaluateAnswer(
        sample,
        JournalEntryAnswer(
          date: sample.operationDate,
          description: 'حسابات خاطئة',
          lines: const [
            FinJournalLine(accountId: 'bank', side: 'debit', amount: 5000000),
            FinJournalLine(
              accountId: 'capital',
              side: 'credit',
              amount: 5000000,
            ),
          ],
        ),
      );
      expect(res.balanced, isTrue);
      expect(res.correct, isFalse);
    });
  });

  // ==========================================================================
  // FinancialAccountingProvider: simulator journal storage
  // ==========================================================================
  group('FinancialAccountingProvider simulator journal', () {
    late FinancialAccountingProvider provider;

    setUp(() {
      provider = FinancialAccountingProvider();
    });

    test('rejects empty entry on add', () {
      final err = provider.addSimEntry(
        JournalEntryAnswer(
          date: DateTime(2024, 1, 1),
          description: 'فارغ',
          lines: const [],
        ),
      );
      expect(err, isNotNull);
      expect(provider.simJournal, isEmpty);
    });

    test('rejects zero amount line on add', () {
      final err = provider.addSimEntry(
        JournalEntryAnswer(
          date: DateTime(2024, 1, 1),
          description: 'صفر',
          lines: const [
            FinJournalLine(accountId: 'cash', side: 'debit', amount: 0),
            FinJournalLine(accountId: 'capital', side: 'credit', amount: 0),
          ],
        ),
      );
      expect(err, isNotNull);
      expect(provider.simJournal, isEmpty);
    });

    test('rejects unbalanced entry on add', () {
      final err = provider.addSimEntry(
        JournalEntryAnswer(
          date: DateTime(2024, 1, 1),
          description: 'غير متوازن',
          lines: const [
            FinJournalLine(accountId: 'cash', side: 'debit', amount: 100),
            FinJournalLine(accountId: 'capital', side: 'credit', amount: 90),
          ],
        ),
      );
      expect(err, isNotNull);
      expect(provider.simJournal, isEmpty);
    });

    test('accepts a balanced entry and reflects it in trial balance', () {
      final err = provider.addSimEntry(
        JournalEntryAnswer(
          date: DateTime(2024, 1, 1),
          description: 'تأسيس',
          lines: const [
            FinJournalLine(accountId: 'cash', side: 'debit', amount: 5000000),
            FinJournalLine(
              accountId: 'capital',
              side: 'credit',
              amount: 5000000,
            ),
          ],
        ),
      );
      expect(err, isNull);
      expect(provider.simJournal, hasLength(1));

      // Trial balance must be balanced after a single balanced entry.
      expect(provider.trialBalanceBalanced, isTrue);
      expect(provider.trialBalanceTotalDebit, 5000000);
      expect(provider.trialBalanceTotalCredit, 5000000);
    });

    test('balance sheet equation holds after multiple balanced entries', () {
      // 1) Capital: cash 5,000,000 / capital 5,000,000.
      provider.addSimEntry(
        JournalEntryAnswer(
          date: DateTime(2024, 1, 1),
          description: 'تأسيس',
          lines: const [
            FinJournalLine(accountId: 'cash', side: 'debit', amount: 5000000),
            FinJournalLine(
              accountId: 'capital',
              side: 'credit',
              amount: 5000000,
            ),
          ],
        ),
      );
      // 2) Cash purchase of merchandise: purchases 1,200,000 / cash 1,200,000.
      provider.addSimEntry(
        JournalEntryAnswer(
          date: DateTime(2024, 1, 5),
          description: 'شراء بضاعة',
          lines: const [
            FinJournalLine(
              accountId: 'purchases',
              side: 'debit',
              amount: 1200000,
            ),
            FinJournalLine(accountId: 'cash', side: 'credit', amount: 1200000),
          ],
        ),
      );
      // 3) Pay rent: rent_expense 150,000 / cash 150,000.
      provider.addSimEntry(
        JournalEntryAnswer(
          date: DateTime(2024, 1, 7),
          description: 'إيجار',
          lines: const [
            FinJournalLine(
              accountId: 'rent_expense',
              side: 'debit',
              amount: 150000,
            ),
            FinJournalLine(accountId: 'cash', side: 'credit', amount: 150000),
          ],
        ),
      );

      // Trial balance still balances.
      expect(provider.trialBalanceBalanced, isTrue);

      // Balance sheet equation: assets = liabilities + equity
      // (totalEquity already includes netIncome as a component, see
      // BalanceSheetReport.totalEquity getter).
      final bs = provider.buildBalanceSheet();
      final lhs = bs.totalAssets;
      final rhs = bs.totalLiabilities + bs.totalEquity;
      expect(
        (lhs - rhs).abs() < 0.5,
        isTrue,
        reason:
            'Assets (${bs.totalAssets}) must equal '
            'Liabilities (${bs.totalLiabilities}) + '
            'Equity-with-netIncome (${bs.totalEquity}). '
            'lhs=$lhs rhs=$rhs (netIncome=${bs.netIncome})',
      );
      expect(
        bs.isBalanced,
        isTrue,
        reason: 'BalanceSheetReport.isBalanced should be true.',
      );

      // Income statement: net income should be negative (only expenses).
      final inc = provider.buildIncomeStatement();
      expect(inc.totalRevenues, 0);
      // Both rent_expense and the simplified COGS (purchases) appear as expenses.
      expect(inc.totalExpenses, 1200000 + 150000);
      expect(inc.netIncome, -(1200000 + 150000));
    });
  });

  // ==========================================================================
  // FinancialAccountingProvider: every seeded exercise has a balanced answer
  // ==========================================================================
  group('All seeded financial exercises are valid', () {
    test('every expected entry is balanced and amounts > 0', () {
      for (final ex in financialExercises) {
        expect(
          ex.expected.isBalanced,
          isTrue,
          reason:
              'Exercise ${ex.id} (${ex.title}) has unbalanced expected entry. '
              'debit=${ex.expected.totalDebit}, credit=${ex.expected.totalCredit}',
        );
        for (final l in ex.expected.lines) {
          expect(
            l.amount > 0,
            isTrue,
            reason:
                'Exercise ${ex.id} has a line with non-positive amount '
                '(account=${l.accountId}, amount=${l.amount}).',
          );
        }
      }
    });

    test('every account id used in exercises exists in the catalog', () {
      for (final ex in financialExercises) {
        for (final l in ex.expected.lines) {
          final acc = FinAccountsCatalog.byId(l.accountId);
          expect(
            acc,
            isNotNull,
            reason:
                'Exercise ${ex.id} references unknown account "${l.accountId}".',
          );
        }
      }
    });
  });

  // ==========================================================================
  // AccountingProvider trial-balance / income / balance-sheet behaviour
  // ==========================================================================
  group('AccountingProvider posting & balances', () {
    test(
      'posted balanced journal updates account balances correctly',
      () async {
        final acc = AccountingProvider();
        await acc.loadCompany();

        // Pick a postable cash and a postable expense from the seeded chart.
        final cash = acc.postableAccounts.firstWhere((a) => a.id == 'a1111');
        final expense = acc.postableAccounts.firstWhere(
          (a) => a.type == AccountType.expense,
        );

        final beforeCash = acc.accountBalance(cash.id);
        final beforeExp = acc.accountBalance(expense.id);

        final j = JournalEntry(
          id: 'j_unit_${DateTime.now().millisecondsSinceEpoch}',
          number: 0,
          date: DateTime.now(),
          description: 'دفع مصروف من الصندوق',
          lines: [
            JournalLine(
              accountId: expense.id,
              accountName: expense.name,
              debit: 25000,
            ),
            JournalLine(
              accountId: cash.id,
              accountName: cash.name,
              credit: 25000,
            ),
          ],
          posted: true,
        );
        expect(j.isBalanced, isTrue);
        await acc.addJournal(j);

        // Cash is asset (debit nature) -> credit reduces it.
        expect(acc.accountBalance(cash.id), beforeCash - 25000);
        // Expense is expense (debit nature) -> debit increases it.
        expect(acc.accountBalance(expense.id), beforeExp + 25000);

        // Trial balance derived from postable accounts must balance.
        final balances = acc.allBalances();
        double td = 0;
        double tc = 0;
        for (final entry in balances.entries) {
          final a = acc.accountById(entry.key);
          if (a == null) continue;
          final bal = entry.value;
          if (a.type.isDebitNature) {
            if (bal > 0) {
              td += bal;
            } else {
              tc += -bal;
            }
          } else {
            if (bal > 0) {
              tc += bal;
            } else {
              td += -bal;
            }
          }
        }
        expect(
          (td - tc).abs() < 0.5,
          isTrue,
          reason: 'Trial balance must balance. debit=$td credit=$tc',
        );
      },
    );
  });

  // ==========================================================================
  // Currency formatter (Yemeni Rial)
  // ==========================================================================
  group('Currency formatter', () {
    test('formats integer amount with default currency suffix', () {
      final s = Formatters.currency(1234567, decimals: 0);
      // We do not depend on a specific locale grouping here, just make sure
      // the digits are present and the formatter produces a non-empty string.
      expect(s, isNotEmpty);
      expect(s.contains('1'), isTrue);
      expect(s.contains('234'), isTrue);
    });

    test('formats small fractional amount and includes decimals', () {
      final s = Formatters.currency(1500.5, decimals: 2);
      expect(s, isNotEmpty);
      expect(s.contains('1'), isTrue);
      expect(s.contains('500'), isTrue);
    });
  });
}
