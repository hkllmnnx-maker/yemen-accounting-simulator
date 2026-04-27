import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/financial_accounting_provider.dart';

/// شاشة ميزان المراجعة - يُحسب تلقائيًا من قيود اليومية المرحّلة.
class FaTrialBalanceScreen extends StatelessWidget {
  const FaTrialBalanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fa = context.watch<FinancialAccountingProvider>();
    final rows = fa.buildTrialBalance();
    final totalDebit = fa.trialBalanceTotalDebit;
    final totalCredit = fa.trialBalanceTotalCredit;
    final balanced = fa.trialBalanceBalanced;

    if (rows.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'لا توجد بيانات لإنشاء ميزان المراجعة بعد.\nأدخل قيودًا في تبويب اليومية أولًا.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // Status banner
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: balanced
                ? AppColors.successLight
                : AppColors.errorLight,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: balanced ? AppColors.success : AppColors.error),
          ),
          child: Row(
            children: [
              Icon(
                balanced ? Icons.check_circle : Icons.error,
                color: balanced ? AppColors.success : AppColors.error,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  balanced
                      ? 'ميزان المراجعة متوازن: مجموع المدين = مجموع الدائن.'
                      : 'الميزان غير متوازن. راجع قيودك للعثور على الخطأ.',
                  style: TextStyle(
                    color:
                        balanced ? AppColors.success : AppColors.error,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Table
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8, horizontal: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                          flex: 4,
                          child: Text('الحساب',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12))),
                      Expanded(
                          flex: 3,
                          child: Text('مدين',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: AppColors.debit))),
                      Expanded(
                          flex: 3,
                          child: Text('دائن',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: AppColors.credit))),
                    ],
                  ),
                ),
                // Rows
                for (final r in rows)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 4, horizontal: 6),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Text(
                            r.accountName,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            r.debitBalance > 0
                                ? Formatters.currency(r.debitBalance)
                                : '-',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 11.5,
                                color: AppColors.debit,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            r.creditBalance > 0
                                ? Formatters.currency(r.creditBalance)
                                : '-',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 11.5,
                                color: AppColors.credit,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                const Divider(),
                // Totals
                Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8, horizontal: 6),
                  decoration: BoxDecoration(
                    color: balanced
                        ? AppColors.success.withValues(alpha: 0.08)
                        : AppColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                          flex: 4,
                          child: Text('الإجمالي',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13))),
                      Expanded(
                        flex: 3,
                        child: Text(
                          Formatters.currency(totalDebit),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: AppColors.debit),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          Formatters.currency(totalCredit),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: AppColors.credit),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!balanced) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.errorLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'الفرق: ${Formatters.currency((totalDebit - totalCredit).abs())} ر.ي',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}


