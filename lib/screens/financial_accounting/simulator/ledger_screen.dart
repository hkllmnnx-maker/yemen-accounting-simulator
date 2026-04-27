import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/financial_accounting/financial_exercise.dart';
import '../../../data/models/financial_accounting/ledger_account.dart';
import '../../../providers/financial_accounting_provider.dart';

/// شاشة دفتر الأستاذ - تعرض كشف حساب لكل حساب نشط في القيود.
class FaLedgerScreen extends StatelessWidget {
  const FaLedgerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fa = context.watch<FinancialAccountingProvider>();
    final ledger = fa.buildLedger();

    if (ledger.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.receipt_long, size: 80, color: AppColors.textLight),
              SizedBox(height: 12),
              Text(
                'لا توجد قيود لاستخراج دفتر الأستاذ منها',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'أدخل قيودًا في تبويب "اليومية" أولاً، '
                'ثم سيظهر دفتر الأستاذ تلقائيًا.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.textLight),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        for (final account in ledger) _AccountTSheet(account: account),
      ],
    );
  }
}

class _AccountTSheet extends StatelessWidget {
  final LedgerAccountStatement account;
  const _AccountTSheet({required this.account});

  Color get _typeColor {
    switch (account.accountType) {
      case FinAccountType.asset:
        return AppColors.assets;
      case FinAccountType.liability:
        return AppColors.liabilities;
      case FinAccountType.equity:
        return AppColors.equity;
      case FinAccountType.revenue:
        return AppColors.revenue;
      case FinAccountType.expense:
        return AppColors.expenses;
    }
  }

  @override
  Widget build(BuildContext context) {
    final balanceData = account.balanceWithSide;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 8,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _typeColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account.accountName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        account.accountType.arabicName,
                        style: TextStyle(fontSize: 10.5, color: _typeColor),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _typeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'الرصيد ${balanceData['side']}',
                        style: TextStyle(fontSize: 10, color: _typeColor),
                      ),
                      Text(
                        Formatters.currency(
                          (balanceData['amount'] as double).abs(),
                        ),
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: _typeColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            // T-Account header
            Row(
              children: const [
                Expanded(
                  child: Text(
                    'مدين',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.debit,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'دائن',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.credit,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 8),
            // Entries
            for (final e in account.entries)
              Row(
                children: [
                  // مدين
                  Expanded(
                    child: e.debit > 0
                        ? _LedgerCell(
                            date: e.date,
                            description: e.description,
                            amount: e.debit,
                            color: AppColors.debit,
                          )
                        : const SizedBox.shrink(),
                  ),
                  Container(width: 1, height: 24, color: AppColors.divider),
                  // دائن
                  Expanded(
                    child: e.credit > 0
                        ? _LedgerCell(
                            date: e.date,
                            description: e.description,
                            amount: e.credit,
                            color: AppColors.credit,
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            const Divider(height: 12),
            // Totals
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.debit.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'إجمالي المدين: ${Formatters.currency(account.totalDebit)}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.debit,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.credit.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'إجمالي الدائن: ${Formatters.currency(account.totalCredit)}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.credit,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LedgerCell extends StatelessWidget {
  final DateTime date;
  final String description;
  final double amount;
  final Color color;
  const _LedgerCell({
    required this.date,
    required this.description,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Formatters.date(date),
            style: const TextStyle(fontSize: 10, color: AppColors.textLight),
          ),
          Text(
            description.isEmpty ? '-' : description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            Formatters.currency(amount),
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
