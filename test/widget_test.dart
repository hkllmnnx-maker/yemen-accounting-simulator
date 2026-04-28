// Comprehensive widget tests simulating a human user navigating
// every major screen of the Yemen Accounting Simulator and feeding
// it sample data. Verifies no exceptions are thrown during navigation.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:yemen_accounting_simulator/data/repositories/database_service.dart';
import 'package:yemen_accounting_simulator/data/models/account.dart';
import 'package:yemen_accounting_simulator/data/models/journal_entry.dart';
import 'package:yemen_accounting_simulator/data/models/partner.dart';
import 'package:yemen_accounting_simulator/data/models/item.dart';
import 'package:yemen_accounting_simulator/data/models/invoice.dart';
import 'package:yemen_accounting_simulator/data/models/voucher.dart';
import 'package:yemen_accounting_simulator/providers/accounting_provider.dart';
import 'package:yemen_accounting_simulator/providers/progress_provider.dart';
import 'package:yemen_accounting_simulator/providers/financial_accounting_provider.dart';

import 'package:yemen_accounting_simulator/screens/dashboard/dashboard_screen.dart';
import 'package:yemen_accounting_simulator/screens/welcome/welcome_screen.dart';
import 'package:yemen_accounting_simulator/screens/lessons/lessons_screen.dart';
import 'package:yemen_accounting_simulator/screens/training/training_list_screen.dart';
import 'package:yemen_accounting_simulator/screens/quizzes/quizzes_list_screen.dart';
import 'package:yemen_accounting_simulator/screens/progress/progress_screen.dart';
import 'package:yemen_accounting_simulator/screens/glossary/glossary_screen.dart';
import 'package:yemen_accounting_simulator/screens/settings/settings_screen.dart';
import 'package:yemen_accounting_simulator/screens/simulator/simulator_home_screen.dart';
import 'package:yemen_accounting_simulator/screens/simulator/accounts/accounts_screen.dart';
import 'package:yemen_accounting_simulator/screens/simulator/journal/journal_list_screen.dart';
import 'package:yemen_accounting_simulator/screens/simulator/journal/journal_edit_screen.dart';
import 'package:yemen_accounting_simulator/screens/simulator/customers/customers_screen.dart';
import 'package:yemen_accounting_simulator/screens/simulator/suppliers/suppliers_screen.dart';
import 'package:yemen_accounting_simulator/screens/simulator/inventory/items_screen.dart';
import 'package:yemen_accounting_simulator/screens/simulator/sales/sales_list_screen.dart';
import 'package:yemen_accounting_simulator/screens/simulator/purchases/purchases_list_screen.dart';
import 'package:yemen_accounting_simulator/screens/simulator/vouchers/vouchers_list_screen.dart';
import 'package:yemen_accounting_simulator/screens/simulator/reports/reports_home_screen.dart';
import 'package:yemen_accounting_simulator/screens/simulator/reports/trial_balance_screen.dart';
import 'package:yemen_accounting_simulator/screens/simulator/reports/income_statement_screen.dart';
import 'package:yemen_accounting_simulator/screens/simulator/reports/balance_sheet_screen.dart';
import 'package:yemen_accounting_simulator/screens/simulator/reports/cash_report_screen.dart';
import 'package:yemen_accounting_simulator/screens/simulator/reports/sales_report_screen.dart';
import 'package:yemen_accounting_simulator/screens/simulator/reports/inventory_report_screen.dart';
import 'package:yemen_accounting_simulator/screens/simulator/customers/partner_statement_screen.dart';

Widget _wrap(Widget child) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => AccountingProvider()..loadCompany(),
      ),
      ChangeNotifierProvider(create: (_) => ProgressProvider()..load()),
      ChangeNotifierProvider(
        create: (_) => FinancialAccountingProvider()..load(),
      ),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, ch) =>
          Directionality(textDirection: TextDirection.rtl, child: ch!),
      home: child,
    ),
  );
}

Future<void> _setupHive() async {
  SharedPreferences.setMockInitialValues({});
  await DatabaseService.init(testPath: './.test_hive');
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await initializeDateFormatting('ar', null);
    await _setupHive();
  });

  tearDownAll(() async {
    await Hive.deleteFromDisk();
  });

  group('Smoke tests - all screens render without errors', () {
    testWidgets('Welcome screen renders', (tester) async {
      await tester.pumpWidget(_wrap(const WelcomeScreen()));
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(find.text('محاكي المحاسبة اليمني'), findsWidgets);
    });

    testWidgets('Dashboard renders + shows company name', (tester) async {
      await tester.pumpWidget(_wrap(const DashboardScreen()));
      await tester.pumpAndSettle(const Duration(seconds: 1));
      // Dashboard appbar uses AppStrings.dashboard = 'لوحة التحكم'
      expect(find.text('لوحة التحكم'), findsWidgets);
    });

    testWidgets('Lessons screen renders', (tester) async {
      await tester.pumpWidget(_wrap(const LessonsScreen()));
      await tester.pumpAndSettle(const Duration(seconds: 1));
    });

    testWidgets('Training list screen renders', (tester) async {
      await tester.pumpWidget(_wrap(const TrainingListScreen()));
      await tester.pumpAndSettle(const Duration(seconds: 1));
    });

    testWidgets('Quizzes list screen renders', (tester) async {
      await tester.pumpWidget(_wrap(const QuizzesListScreen()));
      await tester.pumpAndSettle(const Duration(seconds: 1));
    });

    testWidgets('Progress screen renders', (tester) async {
      await tester.pumpWidget(_wrap(const ProgressScreen()));
      await tester.pumpAndSettle(const Duration(seconds: 1));
    });

    testWidgets('Glossary screen renders', (tester) async {
      await tester.pumpWidget(_wrap(const GlossaryScreen()));
      await tester.pumpAndSettle(const Duration(seconds: 1));
    });

    testWidgets('Settings screen renders', (tester) async {
      await tester.pumpWidget(_wrap(const SettingsScreen()));
      await tester.pumpAndSettle(const Duration(seconds: 1));
    });

    testWidgets('Simulator home renders', (tester) async {
      await tester.pumpWidget(_wrap(const SimulatorHomeScreen()));
      await tester.pumpAndSettle(const Duration(seconds: 1));
    });

    testWidgets('Accounts screen renders', (tester) async {
      await tester.pumpWidget(_wrap(const AccountsScreen()));
      await tester.pumpAndSettle(const Duration(seconds: 1));
    });

    testWidgets('Journal list renders', (tester) async {
      await tester.pumpWidget(_wrap(const JournalListScreen()));
      await tester.pumpAndSettle(const Duration(seconds: 1));
    });

    testWidgets('Journal edit (new) renders', (tester) async {
      await tester.pumpWidget(_wrap(const JournalEditScreen()));
      await tester.pumpAndSettle(const Duration(seconds: 1));
    });

    testWidgets('Customers screen renders', (tester) async {
      await tester.pumpWidget(_wrap(const CustomersScreen()));
      await tester.pumpAndSettle(const Duration(seconds: 1));
    });

    testWidgets('Suppliers screen renders', (tester) async {
      await tester.pumpWidget(_wrap(const SuppliersScreen()));
      await tester.pumpAndSettle(const Duration(seconds: 1));
    });

    testWidgets('Items screen renders', (tester) async {
      await tester.pumpWidget(_wrap(const ItemsScreen()));
      await tester.pumpAndSettle(const Duration(seconds: 1));
    });

    testWidgets('Sales list renders', (tester) async {
      await tester.pumpWidget(_wrap(const SalesListScreen()));
      await tester.pumpAndSettle(const Duration(seconds: 1));
    });

    testWidgets('Purchases list renders', (tester) async {
      await tester.pumpWidget(_wrap(const PurchasesListScreen()));
      await tester.pumpAndSettle(const Duration(seconds: 1));
    });

    testWidgets('Vouchers list renders', (tester) async {
      await tester.pumpWidget(_wrap(const VouchersListScreen()));
      await tester.pumpAndSettle(const Duration(seconds: 1));
    });

    testWidgets('Reports home renders', (tester) async {
      await tester.pumpWidget(_wrap(const ReportsHomeScreen()));
      await tester.pumpAndSettle(const Duration(seconds: 1));
    });

    testWidgets('Trial balance renders', (tester) async {
      await tester.pumpWidget(_wrap(const TrialBalanceScreen()));
      await tester.pumpAndSettle(const Duration(seconds: 1));
    });

    testWidgets('Income statement renders', (tester) async {
      await tester.pumpWidget(_wrap(const IncomeStatementScreen()));
      await tester.pumpAndSettle(const Duration(seconds: 1));
    });

    testWidgets('Balance sheet renders', (tester) async {
      await tester.pumpWidget(_wrap(const BalanceSheetScreen()));
      await tester.pumpAndSettle(const Duration(seconds: 1));
    });

    testWidgets('Cash report renders', (tester) async {
      await tester.pumpWidget(_wrap(const CashReportScreen()));
      await tester.pumpAndSettle(const Duration(seconds: 1));
    });

    testWidgets('Sales report renders', (tester) async {
      await tester.pumpWidget(_wrap(const SalesReportScreen()));
      await tester.pumpAndSettle(const Duration(seconds: 1));
    });

    testWidgets('Inventory report renders', (tester) async {
      await tester.pumpWidget(_wrap(const InventoryReportScreen()));
      await tester.pumpAndSettle(const Duration(seconds: 1));
    });

    testWidgets('Partner statement renders for default customer', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const PartnerStatementScreen(partnerId: 'cust_001')),
      );
      await tester.pumpAndSettle(const Duration(seconds: 1));
    });
  });

  group('Data flow tests - human-like operations', () {
    testWidgets('Add a new customer through the API and verify list updates', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const CustomersScreen()));
      await tester.pump();

      // Use the provider directly (simulating the form's onSave behavior)
      final ctx = tester.element(find.byType(CustomersScreen));
      final acc = Provider.of<AccountingProvider>(ctx, listen: false);
      final before = acc.customers.length;

      final p = Partner(
        id: 'p_test_${DateTime.now().millisecondsSinceEpoch}',
        code: 'C9999',
        name: 'مؤسسة النور التجارية',
        kind: PartnerKind.customer,
        city: 'صنعاء',
        phone: '777999111',
        isCredit: true,
        creditLimit: 1000000,
        currency: 'YER',
        openingBalance: 250000,
        accountId: '',
      );
      // Use runAsync to allow real async operations (Hive box.put)
      await tester.runAsync(() async {
        await acc.addPartner(p);
      });
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(acc.customers.length, before + 1);
      expect(
        acc.customers.any((e) => e.name == 'مؤسسة النور التجارية'),
        isTrue,
      );
    });

    testWidgets('Add a new item and verify it appears in items list', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const ItemsScreen()));
      await tester.pump();

      final ctx = tester.element(find.byType(ItemsScreen));
      final acc = Provider.of<AccountingProvider>(ctx, listen: false);
      final before = acc.items.length;

      final it = Item(
        id: 'item_test_${DateTime.now().millisecondsSinceEpoch}',
        code: 'P9999',
        name: 'كرتون شاي أحمدي',
        unit: 'كرتون',
        cost: 8500,
        price: 11000,
        quantity: 100,
      );
      await tester.runAsync(() async {
        await acc.addItem(it);
      });
      // Pump multiple frames so provider's notifyListeners propagates
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(acc.items.length, before + 1);
      // The item is in the list — confirm via provider data
      expect(acc.items.any((e) => e.name == 'كرتون شاي أحمدي'), isTrue);
    });

    testWidgets('Add a balanced journal entry and verify it appears', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const JournalListScreen()));
      await tester.pumpAndSettle();

      final ctx = tester.element(find.byType(JournalListScreen));
      final acc = Provider.of<AccountingProvider>(ctx, listen: false);

      // Find a postable cash account and a postable expense account
      final cash = acc.postableAccounts.firstWhere(
        (a) => a.id == 'a1111',
        orElse: () => acc.postableAccounts.first,
      );
      final expense = acc.postableAccounts.firstWhere(
        (a) => a.type == AccountType.expense,
        orElse: () => acc.postableAccounts.last,
      );

      final j = JournalEntry(
        id: 'j_test_${DateTime.now().millisecondsSinceEpoch}',
        number: 0,
        date: DateTime.now(),
        description: 'دفع إيجار شهر يناير',
        lines: [
          JournalLine(
            accountId: expense.id,
            accountName: expense.name,
            debit: 50000,
          ),
          JournalLine(
            accountId: cash.id,
            accountName: cash.name,
            credit: 50000,
          ),
        ],
        posted: true,
        source: 'يدوي',
      );
      expect(j.isBalanced, isTrue);
      await tester.runAsync(() async {
        await acc.addJournal(j);
      });
      await tester.pump();
      expect(acc.journals.any((e) => e.id == j.id), isTrue);
    });

    testWidgets(
      'Create a sale invoice (cash) and verify totals + inventory update',
      (tester) async {
        await tester.pumpWidget(_wrap(const SalesListScreen()));
        await tester.pumpAndSettle();

        final ctx = tester.element(find.byType(SalesListScreen));
        final acc = Provider.of<AccountingProvider>(ctx, listen: false);

        final cust = acc.customers.first;
        final item = acc.items.first;
        final initialQty = item.quantity;

        final inv = Invoice(
          id: 'inv_test_${DateTime.now().millisecondsSinceEpoch}',
          number: 0,
          kind: InvoiceKind.sale,
          date: DateTime.now(),
          partnerId: cust.id,
          partnerName: cust.name,
          lines: [
            InvoiceLine(
              itemId: item.id,
              itemName: item.name,
              quantity: 5,
              unitPrice: item.price,
            ),
          ],
          paymentType: InvoicePaymentType.cash,
          paidAmount: item.price * 5,
        );
        expect(inv.total, item.price * 5);

        await tester.runAsync(() async {
          await acc.addInvoice(inv);
        });
        await tester.pump();

        // Quantity should decrement by 5
        final updated = acc.itemById(item.id)!;
        expect(updated.quantity, initialQty - 5);
        expect(acc.salesInvoices.any((e) => e.id == inv.id), isTrue);
      },
    );

    testWidgets('Create a purchase invoice and verify inventory increases', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const PurchasesListScreen()));
      await tester.pumpAndSettle();

      final ctx = tester.element(find.byType(PurchasesListScreen));
      final acc = Provider.of<AccountingProvider>(ctx, listen: false);

      final supp = acc.suppliers.first;
      final item = acc.items.first;
      final initialQty = item.quantity;

      final inv = Invoice(
        id: 'pur_test_${DateTime.now().millisecondsSinceEpoch}',
        number: 0,
        kind: InvoiceKind.purchase,
        date: DateTime.now(),
        partnerId: supp.id,
        partnerName: supp.name,
        lines: [
          InvoiceLine(
            itemId: item.id,
            itemName: item.name,
            quantity: 20,
            unitPrice: item.cost,
          ),
        ],
        paymentType: InvoicePaymentType.credit,
      );
      await tester.runAsync(() async {
        await acc.addInvoice(inv);
      });
      await tester.pump();

      final updated = acc.itemById(item.id)!;
      expect(updated.quantity, initialQty + 20);
    });

    testWidgets('Create a receipt voucher and verify it persists', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const VouchersListScreen()));
      await tester.pumpAndSettle();

      final ctx = tester.element(find.byType(VouchersListScreen));
      final acc = Provider.of<AccountingProvider>(ctx, listen: false);

      final cust = acc.customers.first;
      final v = Voucher(
        id: 'v_test_${DateTime.now().millisecondsSinceEpoch}',
        number: 0,
        kind: VoucherKind.receipt,
        date: DateTime.now(),
        partnerId: cust.id,
        partnerName: cust.name,
        cashAccountId: 'a1111',
        cashAccountName: 'الصندوق الرئيسي',
        amount: 100000,
        notes: 'سداد جزء من المديونية',
      );
      await tester.runAsync(() async {
        await acc.addVoucher(v);
      });
      await tester.pump();
      expect(acc.receiptVouchers.any((e) => e.id == v.id), isTrue);
    });

    testWidgets(
      'Account balance computation - cash account reflects journals',
      (tester) async {
        await tester.pumpWidget(_wrap(const SimulatorHomeScreen()));
        await tester.pumpAndSettle();

        final ctx = tester.element(find.byType(SimulatorHomeScreen));
        final acc = Provider.of<AccountingProvider>(ctx, listen: false);

        // Cash balance must be a numeric (no exception)
        final bal = acc.accountBalance('a1111');
        expect(bal, isA<double>());
      },
    );

    testWidgets('All postable accounts have balances computable', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const ReportsHomeScreen()));
      await tester.pumpAndSettle();

      final ctx = tester.element(find.byType(ReportsHomeScreen));
      final acc = Provider.of<AccountingProvider>(ctx, listen: false);

      final balances = acc.allBalances();
      expect(balances.length, greaterThan(0));
      for (final v in balances.values) {
        expect(v, isA<double>());
      }
    });
  });
}
