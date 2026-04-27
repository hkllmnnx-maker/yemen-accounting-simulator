import '../data/models/account.dart';
import '../data/models/invoice.dart';
import '../data/models/journal_entry.dart';
import '../data/models/voucher.dart';
import 'accounting_provider.dart';

/// محرّك القيود التلقائية - يُنشئ قيود من الفواتير والسندات
class AccountingEngine {
  static const String mainCashAccountId = 'a1111';
  static const String salesCashAccountId = 'a1112';
  static const String inventoryAccountId = 'a114';
  static const String salesRevenueAccountId = 'a41';
  static const String salesReturnsAccountId = 'a42';
  static const String cogsAccountId = 'a51';
  static const String purchaseReturnsAccountId = 'a57';

  /// إنشاء قيد من فاتورة بيع
  static JournalEntry journalFromInvoice(Invoice inv, AccountingProvider acc) {
    final lines = <JournalLine>[];
    final partner = acc.partnerById(inv.partnerId);
    final partnerAccountId = partner?.accountId ?? '';
    final partnerAccountName = partner?.name ?? inv.partnerName;
    final cashAcc = acc.accountById(mainCashAccountId);
    final salesAcc = acc.accountById(salesRevenueAccountId);
    final salesReturnAcc = acc.accountById(salesReturnsAccountId);
    final invAcc = acc.accountById(inventoryAccountId);
    final cogsAcc = acc.accountById(cogsAccountId);
    final purchRetAcc = acc.accountById(purchaseReturnsAccountId);

    // حساب تكلفة البضاعة من الأصناف
    double cogs = 0;
    for (final line in inv.lines) {
      final it = acc.itemById(line.itemId);
      cogs += (it?.cost ?? 0.0) * line.quantity;
    }

    final total = inv.total;
    final double cashPaid = inv.paymentType == InvoicePaymentType.cash
        ? total
        : (inv.paymentType == InvoicePaymentType.mixed ? inv.paidAmount : 0.0);
    final credit = total - cashPaid;

    switch (inv.kind) {
      case InvoiceKind.sale:
        // المدين: الصندوق + العميل (الآجل)
        if (cashPaid > 0) {
          lines.add(
            JournalLine(
              accountId: mainCashAccountId,
              accountName: cashAcc?.name ?? 'الصندوق',
              debit: cashPaid,
            ),
          );
        }
        if (credit > 0 && partnerAccountId.isNotEmpty) {
          lines.add(
            JournalLine(
              accountId: partnerAccountId,
              accountName: partnerAccountName,
              debit: credit,
            ),
          );
        }
        // الدائن: إيرادات المبيعات
        lines.add(
          JournalLine(
            accountId: salesRevenueAccountId,
            accountName: salesAcc?.name ?? 'إيرادات المبيعات',
            credit: total,
          ),
        );
        // قيد ثانوي لتكلفة البضاعة المباعة
        if (cogs > 0) {
          lines.add(
            JournalLine(
              accountId: cogsAccountId,
              accountName: cogsAcc?.name ?? 'تكلفة البضاعة المباعة',
              debit: cogs,
            ),
          );
          lines.add(
            JournalLine(
              accountId: inventoryAccountId,
              accountName: invAcc?.name ?? 'المخزون',
              credit: cogs,
            ),
          );
        }
        break;

      case InvoiceKind.purchase:
        // المدين: المخزون
        lines.add(
          JournalLine(
            accountId: inventoryAccountId,
            accountName: invAcc?.name ?? 'المخزون',
            debit: total,
          ),
        );
        // الدائن: الصندوق + المورد
        if (cashPaid > 0) {
          lines.add(
            JournalLine(
              accountId: mainCashAccountId,
              accountName: cashAcc?.name ?? 'الصندوق',
              credit: cashPaid,
            ),
          );
        }
        if (credit > 0 && partnerAccountId.isNotEmpty) {
          lines.add(
            JournalLine(
              accountId: partnerAccountId,
              accountName: partnerAccountName,
              credit: credit,
            ),
          );
        }
        break;

      case InvoiceKind.saleReturn:
        // المدين: مرتجعات المبيعات
        lines.add(
          JournalLine(
            accountId: salesReturnsAccountId,
            accountName: salesReturnAcc?.name ?? 'مرتجعات المبيعات',
            debit: total,
          ),
        );
        // الدائن: العميل أو الصندوق
        if (inv.paymentType == InvoicePaymentType.cash) {
          lines.add(
            JournalLine(
              accountId: mainCashAccountId,
              accountName: cashAcc?.name ?? 'الصندوق',
              credit: total,
            ),
          );
        } else {
          lines.add(
            JournalLine(
              accountId: partnerAccountId,
              accountName: partnerAccountName,
              credit: total,
            ),
          );
        }
        break;

      case InvoiceKind.purchaseReturn:
        // المدين: المورد أو الصندوق
        if (inv.paymentType == InvoicePaymentType.cash) {
          lines.add(
            JournalLine(
              accountId: mainCashAccountId,
              accountName: cashAcc?.name ?? 'الصندوق',
              debit: total,
            ),
          );
        } else {
          lines.add(
            JournalLine(
              accountId: partnerAccountId,
              accountName: partnerAccountName,
              debit: total,
            ),
          );
        }
        // الدائن: مرتجعات المشتريات
        lines.add(
          JournalLine(
            accountId: purchaseReturnsAccountId,
            accountName: purchRetAcc?.name ?? 'مرتجعات المشتريات',
            credit: total,
          ),
        );
        break;
    }

    return JournalEntry(
      id: 'je_inv_${inv.id}',
      number: 0,
      date: inv.date,
      description:
          '${_invoiceKindAr(inv.kind)} رقم ${inv.number} - ${inv.partnerName}',
      lines: lines,
      posted: true,
      source: _invoiceKindAr(inv.kind),
      sourceId: inv.id,
      currency: inv.currency,
    );
  }

  /// إنشاء قيد من سند قبض/صرف
  static JournalEntry journalFromVoucher(Voucher v, AccountingProvider acc) {
    final lines = <JournalLine>[];
    final partner = acc.partnerById(v.partnerId);
    final partnerAccountId = partner?.accountId ?? '';

    if (v.kind == VoucherKind.receipt) {
      // سند قبض: الصندوق مدين، العميل دائن
      lines.add(
        JournalLine(
          accountId: v.cashAccountId,
          accountName: v.cashAccountName,
          debit: v.amount,
        ),
      );
      lines.add(
        JournalLine(
          accountId: partnerAccountId,
          accountName: partner?.name ?? v.partnerName,
          credit: v.amount,
        ),
      );
    } else {
      // سند صرف: المورد مدين، الصندوق دائن
      lines.add(
        JournalLine(
          accountId: partnerAccountId,
          accountName: partner?.name ?? v.partnerName,
          debit: v.amount,
        ),
      );
      lines.add(
        JournalLine(
          accountId: v.cashAccountId,
          accountName: v.cashAccountName,
          credit: v.amount,
        ),
      );
    }

    return JournalEntry(
      id: 'je_v_${v.id}',
      number: 0,
      date: v.date,
      description: v.kind == VoucherKind.receipt
          ? 'سند قبض رقم ${v.number} من ${v.partnerName}'
          : 'سند صرف رقم ${v.number} لـ ${v.partnerName}',
      lines: lines,
      posted: true,
      source: v.kind == VoucherKind.receipt ? 'سند قبض' : 'سند صرف',
      sourceId: v.id,
      currency: v.currency,
    );
  }

  static String _invoiceKindAr(InvoiceKind k) {
    switch (k) {
      case InvoiceKind.sale:
        return 'فاتورة بيع';
      case InvoiceKind.purchase:
        return 'فاتورة شراء';
      case InvoiceKind.saleReturn:
        return 'مرتجع بيع';
      case InvoiceKind.purchaseReturn:
        return 'مرتجع شراء';
    }
  }
}

/// مساعد لمعرفة الحسابات النقدية المتاحة
class CashAccountsHelper {
  static List<Account> cashAndBankAccounts(AccountingProvider acc) {
    return acc.accounts
        .where(
          (a) => a.isPostable && (a.parentId == 'a111' || a.parentId == 'a112'),
        )
        .toList();
  }
}
