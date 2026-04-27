import 'financial_exercise.dart';

/// حركة في دفتر الأستاذ لحساب معيّن.
class LedgerEntry {
  final DateTime date;
  final String description;
  final double debit;
  final double credit;

  const LedgerEntry({
    required this.date,
    required this.description,
    required this.debit,
    required this.credit,
  });
}

/// كشف حساب (دفتر أستاذ) لحساب واحد.
class LedgerAccountStatement {
  final String accountId;
  final String accountName;
  final FinAccountType accountType;
  final List<LedgerEntry> entries;

  const LedgerAccountStatement({
    required this.accountId,
    required this.accountName,
    required this.accountType,
    required this.entries,
  });

  double get totalDebit =>
      entries.fold<double>(0, (s, e) => s + e.debit);
  double get totalCredit =>
      entries.fold<double>(0, (s, e) => s + e.credit);

  /// الرصيد قياسًا على طبيعة الحساب.
  /// موجب = الجانب الطبيعي (مدين للأصول/المصروفات، دائن للبقية).
  double get balance {
    final diff = totalDebit - totalCredit;
    switch (accountType) {
      case FinAccountType.asset:
      case FinAccountType.expense:
        return diff;
      case FinAccountType.liability:
      case FinAccountType.equity:
      case FinAccountType.revenue:
        return -diff;
    }
  }

  /// الرصيد كقيمة موجبة + وصف الجانب.
  /// يُعيد خريطة فيها {amount, side} (مدين/دائن).
  Map<String, dynamic> get balanceWithSide {
    final diff = totalDebit - totalCredit;
    if (diff > 0) {
      return {'amount': diff, 'side': 'مدين'};
    } else if (diff < 0) {
      return {'amount': -diff, 'side': 'دائن'};
    }
    return {'amount': 0.0, 'side': '-'};
  }
}

/// سطر في ميزان المراجعة.
class TrialBalanceRow {
  final String accountId;
  final String accountName;
  final FinAccountType accountType;
  final double debitBalance;
  final double creditBalance;

  const TrialBalanceRow({
    required this.accountId,
    required this.accountName,
    required this.accountType,
    required this.debitBalance,
    required this.creditBalance,
  });
}
