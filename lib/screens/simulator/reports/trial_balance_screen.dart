import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/account.dart';
import '../../../providers/accounting_provider.dart';

class TrialBalanceScreen extends StatelessWidget {
  const TrialBalanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final acc = context.watch<AccountingProvider>();
    final rows = <_Row>[];
    double totalDebit = 0;
    double totalCredit = 0;
    final balances = acc.allBalances();
    for (final a in acc.postableAccounts) {
      final bal = balances[a.id] ?? 0;
      if (bal == 0) continue;
      double debit = 0, credit = 0;
      if (a.type.isDebitNature) {
        if (bal > 0) {
          debit = bal;
        } else {
          credit = -bal;
        }
      } else {
        if (bal > 0) {
          credit = bal;
        } else {
          debit = -bal;
        }
      }
      totalDebit += debit;
      totalCredit += credit;
      rows.add(_Row(a, debit, credit));
    }
    rows.sort((a, b) => a.account.code.compareTo(b.account.code));

    return Scaffold(
      appBar: AppBar(title: const Text('ميزان المراجعة')),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: AppColors.primary.withValues(alpha: 0.06),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: const Row(
                children: [
                  SizedBox(
                    width: 50,
                    child: Text(
                      'الكود',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'اسم الحساب',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 80,
                    child: Text(
                      'مدين',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: AppColors.debit,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 80,
                    child: Text(
                      'دائن',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: AppColors.credit,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: rows.isEmpty
                  ? const Center(child: Text('لا توجد حسابات بأرصدة بعد'))
                  : ListView.separated(
                      itemCount: rows.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final r = rows[i];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 50,
                                child: Text(
                                  r.account.code,
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  r.account.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              SizedBox(
                                width: 80,
                                child: Text(
                                  r.debit == 0
                                      ? '-'
                                      : Formatters.number(r.debit, decimals: 0),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: AppColors.debit,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 80,
                                child: Text(
                                  r.credit == 0
                                      ? '-'
                                      : Formatters.number(
                                          r.credit,
                                          decimals: 0,
                                        ),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: AppColors.credit,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 50),
                      const Expanded(
                        child: Text(
                          'الإجمالي',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: Text(
                          Formatters.number(totalDebit, decimals: 0),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.debit,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: Text(
                          Formatters.number(totalCredit, decimals: 0),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.credit,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (totalDebit - totalCredit).abs() < 0.01
                          ? AppColors.successLight
                          : AppColors.errorLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          (totalDebit - totalCredit).abs() < 0.01
                              ? Icons.check_circle
                              : Icons.error,
                          color: (totalDebit - totalCredit).abs() < 0.01
                              ? AppColors.success
                              : AppColors.error,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            (totalDebit - totalCredit).abs() < 0.01
                                ? 'الميزان متوازن: المدين = الدائن'
                                : 'الميزان غير متوازن! الفرق ${Formatters.number((totalDebit - totalCredit).abs(), decimals: 0)}',
                            style: TextStyle(
                              color: (totalDebit - totalCredit).abs() < 0.01
                                  ? AppColors.success
                                  : AppColors.error,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row {
  final Account account;
  final double debit;
  final double credit;
  _Row(this.account, this.debit, this.credit);
}
