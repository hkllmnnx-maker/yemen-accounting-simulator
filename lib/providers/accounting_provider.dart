import 'package:flutter/foundation.dart';
import '../data/models/account.dart';
import '../data/models/journal_entry.dart';
import '../data/models/partner.dart';
import '../data/models/item.dart';
import '../data/models/invoice.dart';
import '../data/models/voucher.dart';
import '../data/models/company.dart';
import '../data/repositories/database_service.dart';

/// مزوّد إدارة بيانات النظام المحاسبي
class AccountingProvider extends ChangeNotifier {
  // ============ Company ============
  CompanySettings _company = CompanySettings();
  CompanySettings get company => _company;

  Future<void> loadCompany() async {
    _company = DatabaseService.getCompany();
    notifyListeners();
  }

  Future<void> saveCompany(CompanySettings c) async {
    _company = c;
    await DatabaseService.saveCompany(c);
    notifyListeners();
  }

  // ============ Accounts ============
  List<Account> get accounts =>
      DatabaseService.accountsBoxRef.values.cast<Account>().toList()
        ..sort((a, b) => a.code.compareTo(b.code));

  Account? accountById(String id) =>
      DatabaseService.accountsBoxRef.get(id) as Account?;

  List<Account> get postableAccounts =>
      accounts.where((a) => a.isPostable).toList();

  List<Account> children(String? parentId) =>
      accounts.where((a) => a.parentId == parentId).toList();

  Future<void> addAccount(Account a) async {
    await DatabaseService.accountsBoxRef.put(a.id, a);
    notifyListeners();
  }

  Future<void> updateAccount(Account a) async {
    await DatabaseService.accountsBoxRef.put(a.id, a);
    notifyListeners();
  }

  Future<void> deleteAccount(String id) async {
    await DatabaseService.accountsBoxRef.delete(id);
    notifyListeners();
  }

  // رصيد حساب (مدين - دائن من القيود المرحّلة + الافتتاحي)
  double accountBalance(String accountId) {
    final acc = accountById(accountId);
    if (acc == null) return 0;
    double total = acc.openingBalance;
    final isDebitNature = acc.type.isDebitNature;
    final allJournals = DatabaseService.journalsBoxRef.values
        .cast<JournalEntry>();
    for (final j in allJournals) {
      if (!j.posted) continue;
      for (final l in j.lines) {
        if (l.accountId == accountId) {
          if (isDebitNature) {
            total += l.debit - l.credit;
          } else {
            total += l.credit - l.debit;
          }
        }
      }
    }
    return total;
  }

  /// حساب أرصدة كل الحسابات القابلة للترحيل في تمريرة واحدة.
  /// أكفأ بكثير من استدعاء [accountBalance] لكل حساب على حدة.
  Map<String, double> _computeAllBalances() {
    final result = <String, double>{};
    // تهيئة الأرصدة الافتتاحية لكل الحسابات.
    for (final a in accounts) {
      result[a.id] = a.openingBalance;
    }
    // المرور على القيود المرحّلة مرّة واحدة.
    final allJournals = DatabaseService.journalsBoxRef.values
        .cast<JournalEntry>();
    for (final j in allJournals) {
      if (!j.posted) continue;
      for (final l in j.lines) {
        final acc = accountById(l.accountId);
        if (acc == null) continue;
        final delta = acc.type.isDebitNature
            ? l.debit - l.credit
            : l.credit - l.debit;
        result[l.accountId] = (result[l.accountId] ?? 0) + delta;
      }
    }
    return result;
  }

  // ============ Journals ============
  List<JournalEntry> get journals =>
      DatabaseService.journalsBoxRef.values.cast<JournalEntry>().toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  JournalEntry? journalById(String id) =>
      DatabaseService.journalsBoxRef.get(id) as JournalEntry?;

  Future<JournalEntry> addJournal(JournalEntry j) async {
    if (j.number == 0) {
      j.number = DatabaseService.nextCounter('journal');
    }
    await DatabaseService.journalsBoxRef.put(j.id, j);
    notifyListeners();
    return j;
  }

  Future<void> postJournal(String id) async {
    final j = journalById(id);
    if (j == null) return;
    j.posted = true;
    await DatabaseService.journalsBoxRef.put(id, j);
    notifyListeners();
  }

  Future<void> deleteJournal(String id) async {
    await DatabaseService.journalsBoxRef.delete(id);
    notifyListeners();
  }

  // ============ Partners ============
  List<Partner> get partners =>
      DatabaseService.partnersBoxRef.values.cast<Partner>().toList()
        ..sort((a, b) => a.code.compareTo(b.code));

  List<Partner> get customers =>
      partners.where((p) => p.kind == PartnerKind.customer).toList();
  List<Partner> get suppliers =>
      partners.where((p) => p.kind == PartnerKind.supplier).toList();

  Partner? partnerById(String id) =>
      DatabaseService.partnersBoxRef.get(id) as Partner?;

  Future<void> addPartner(Partner p) async {
    // إنشاء حساب فرعي تلقائيًا
    final parentCode = p.kind == PartnerKind.customer ? '113' : '21';
    final parentId = p.kind == PartnerKind.customer ? 'a113' : 'a21';
    final accId = '${parentId}_${p.code}';
    final acc = Account(
      id: accId,
      code: '$parentCode${p.code}',
      name: p.name,
      type: p.kind == PartnerKind.customer
          ? AccountType.asset
          : AccountType.liability,
      parentId: parentId,
      currency: p.currency,
      openingBalance: p.openingBalance,
    );
    await DatabaseService.accountsBoxRef.put(acc.id, acc);
    p.accountId = acc.id;
    await DatabaseService.partnersBoxRef.put(p.id, p);
    notifyListeners();
  }

  Future<void> updatePartner(Partner p) async {
    await DatabaseService.partnersBoxRef.put(p.id, p);
    final acc = accountById(p.accountId);
    if (acc != null) {
      acc.name = p.name;
      await DatabaseService.accountsBoxRef.put(acc.id, acc);
    }
    notifyListeners();
  }

  Future<void> deletePartner(String id) async {
    final p = partnerById(id);
    if (p != null) {
      await DatabaseService.accountsBoxRef.delete(p.accountId);
    }
    await DatabaseService.partnersBoxRef.delete(id);
    notifyListeners();
  }

  // مديونية عميل (موجب = مديونية، سالب = رصيد له لدينا)
  double partnerBalance(String partnerId) {
    final p = partnerById(partnerId);
    if (p == null) return 0;
    return accountBalance(p.accountId);
  }

  // ============ Items ============
  List<Item> get items =>
      DatabaseService.itemsBoxRef.values.cast<Item>().toList()
        ..sort((a, b) => a.code.compareTo(b.code));

  Item? itemById(String id) => DatabaseService.itemsBoxRef.get(id) as Item?;

  Future<void> addItem(Item it) async {
    await DatabaseService.itemsBoxRef.put(it.id, it);
    notifyListeners();
  }

  Future<void> updateItem(Item it) async {
    await DatabaseService.itemsBoxRef.put(it.id, it);
    notifyListeners();
  }

  Future<void> deleteItem(String id) async {
    await DatabaseService.itemsBoxRef.delete(id);
    notifyListeners();
  }

  // ============ Invoices ============
  List<Invoice> get invoices =>
      DatabaseService.invoicesBoxRef.values.cast<Invoice>().toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  List<Invoice> get salesInvoices => invoices
      .where(
        (i) => i.kind == InvoiceKind.sale || i.kind == InvoiceKind.saleReturn,
      )
      .toList();

  List<Invoice> get purchaseInvoices => invoices
      .where(
        (i) =>
            i.kind == InvoiceKind.purchase ||
            i.kind == InvoiceKind.purchaseReturn,
      )
      .toList();

  Future<Invoice> addInvoice(Invoice inv) async {
    if (inv.number == 0) {
      inv.number = DatabaseService.nextCounter('invoice');
    }
    await DatabaseService.invoicesBoxRef.put(inv.id, inv);
    // تحديث المخزون
    for (final l in inv.lines) {
      final it = itemById(l.itemId);
      if (it != null) {
        switch (inv.kind) {
          case InvoiceKind.sale:
            it.quantity -= l.quantity;
            break;
          case InvoiceKind.purchase:
            it.quantity += l.quantity;
            break;
          case InvoiceKind.saleReturn:
            it.quantity += l.quantity;
            break;
          case InvoiceKind.purchaseReturn:
            it.quantity -= l.quantity;
            break;
        }
        await DatabaseService.itemsBoxRef.put(it.id, it);
      }
    }
    notifyListeners();
    return inv;
  }

  Future<void> deleteInvoice(String id) async {
    final inv = DatabaseService.invoicesBoxRef.get(id) as Invoice?;
    if (inv == null) return;
    // عكس تأثير المخزون
    for (final l in inv.lines) {
      final it = itemById(l.itemId);
      if (it != null) {
        switch (inv.kind) {
          case InvoiceKind.sale:
            it.quantity += l.quantity;
            break;
          case InvoiceKind.purchase:
            it.quantity -= l.quantity;
            break;
          case InvoiceKind.saleReturn:
            it.quantity -= l.quantity;
            break;
          case InvoiceKind.purchaseReturn:
            it.quantity += l.quantity;
            break;
        }
        await DatabaseService.itemsBoxRef.put(it.id, it);
      }
    }
    if (inv.journalEntryId != null) {
      await DatabaseService.journalsBoxRef.delete(inv.journalEntryId);
    }
    await DatabaseService.invoicesBoxRef.delete(id);
    notifyListeners();
  }

  // ============ Vouchers ============
  List<Voucher> get vouchers =>
      DatabaseService.vouchersBoxRef.values.cast<Voucher>().toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  List<Voucher> get receiptVouchers =>
      vouchers.where((v) => v.kind == VoucherKind.receipt).toList();
  List<Voucher> get paymentVouchers =>
      vouchers.where((v) => v.kind == VoucherKind.payment).toList();

  Future<Voucher> addVoucher(Voucher v) async {
    if (v.number == 0) {
      v.number = DatabaseService.nextCounter('voucher');
    }
    await DatabaseService.vouchersBoxRef.put(v.id, v);
    notifyListeners();
    return v;
  }

  Future<void> deleteVoucher(String id) async {
    final v = DatabaseService.vouchersBoxRef.get(id) as Voucher?;
    if (v?.journalEntryId != null) {
      await DatabaseService.journalsBoxRef.delete(v!.journalEntryId);
    }
    await DatabaseService.vouchersBoxRef.delete(id);
    notifyListeners();
  }

  // ============ Reports helpers ============
  /// إجمالي المبيعات
  double get totalSales => salesInvoices
      .where((i) => i.kind == InvoiceKind.sale)
      .fold(0.0, (s, i) => s + i.total);

  /// إجمالي المشتريات
  double get totalPurchases => purchaseInvoices
      .where((i) => i.kind == InvoiceKind.purchase)
      .fold(0.0, (s, i) => s + i.total);

  /// إجمالي تكلفة البضاعة المباعة (مبسط: تكلفة المبيعات - تكلفة المرتجعات)
  /// ملاحظة: يستخدم التكلفة الحالية للصنف من المخزون.
  double get totalCogs {
    double soldCost = 0;
    double returnedCost = 0;
    for (final inv in invoices) {
      if (inv.kind == InvoiceKind.sale) {
        for (final l in inv.lines) {
          final it = itemById(l.itemId);
          soldCost += (it?.cost ?? 0) * l.quantity;
        }
      } else if (inv.kind == InvoiceKind.saleReturn) {
        for (final l in inv.lines) {
          final it = itemById(l.itemId);
          returnedCost += (it?.cost ?? 0) * l.quantity;
        }
      }
    }
    return soldCost - returnedCost;
  }

  /// أرصدة الحسابات (للتقارير) - تستخدم تمريرة واحدة لكل القيود.
  Map<String, double> allBalances() {
    final all = _computeAllBalances();
    final result = <String, double>{};
    for (final a in accounts) {
      if (a.isPostable) {
        result[a.id] = all[a.id] ?? 0;
      }
    }
    return result;
  }

  Future<void> resetAll() async {
    await DatabaseService.resetAll();
    await loadCompany();
    notifyListeners();
  }
}
