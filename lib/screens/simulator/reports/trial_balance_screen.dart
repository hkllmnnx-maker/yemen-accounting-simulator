import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/account.dart';
import '../../../providers/accounting_provider.dart';

/// شاشة ميزان المراجعة - تعرض كل الحسابات ذات الأرصدة في جدول
/// مرن مع تمرير أفقي للعرض على شاشات صغيرة، وملخص للتوازن.
class TrialBalanceScreen extends StatelessWidget {
  const TrialBalanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final acc = context.watch<AccountingProvider>();
    final rows = <_Row>[];
    double totalDebit = 0;
    double totalCredit = 0;
    for (final a in acc.postableAccounts) {
      final bal = acc.accountBalance(a.id);
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

    final balanced = (totalDebit - totalCredit).abs() < 0.01;

    return Scaffold(
      appBar: AppBar(title: const Text('ميزان المراجعة')),
      body: SafeArea(
        child: Column(
          children: [
            // ملخص علوي للحالة
            Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: balanced
                      ? [
                          AppColors.success.withValues(alpha: 0.10),
                          AppColors.success.withValues(alpha: 0.04),
                        ]
                      : [
                          AppColors.error.withValues(alpha: 0.10),
                          AppColors.error.withValues(alpha: 0.04),
                        ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (balanced ? AppColors.success : AppColors.error)
                      .withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    balanced ? Icons.check_circle_rounded : Icons.error_rounded,
                    color: balanced ? AppColors.success : AppColors.error,
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          balanced ? 'الميزان متوازن' : 'الميزان غير متوازن',
                          style: TextStyle(
                            color: balanced
                                ? AppColors.success
                                : AppColors.error,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          balanced
                              ? 'مجموع المدين يساوي مجموع الدائن'
                              : 'الفرق: ${Formatters.number((totalDebit - totalCredit).abs(), decimals: 0)} ر.ي',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
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
                      color: AppColors.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${rows.length} حساب',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // جدول مرن - تمرير أفقي عند الحاجة
            Expanded(
              child: rows.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.balance_rounded,
                              size: 64,
                              color: AppColors.textLight,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'لا توجد حسابات بأرصدة بعد',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'ابدأ بإدخال قيود يومية لتظهر الأرصدة هنا',
                              style: TextStyle(
                                color: AppColors.textLight,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: MediaQuery.of(context).size.width,
                        ),
                        child: SizedBox(
                          width: 540,
                          child: Column(
                            children: [
                              _TableHeader(),
                              Expanded(
                                child: ListView.separated(
                                  itemCount: rows.length,
                                  separatorBuilder: (_, __) =>
                                      const Divider(height: 1),
                                  itemBuilder: (_, i) =>
                                      _TableRow(row: rows[i], index: i),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
            // الإجمالي
            if (rows.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: MediaQuery.of(context).size.width - 24,
                    ),
                    child: SizedBox(
                      width: 540,
                      child: Row(
                        children: [
                          const SizedBox(width: 60),
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
                            width: 110,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.debit.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(6),
                              ),
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
                          ),
                          const SizedBox(width: 6),
                          SizedBox(
                            width: 110,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.credit.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(6),
                              ),
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
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.10),
            AppColors.primary.withValues(alpha: 0.04),
          ],
        ),
        border: const Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: const Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              'الكود',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              'اسم الحساب',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          SizedBox(
            width: 110,
            child: Text(
              'مدين',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: AppColors.debit,
              ),
            ),
          ),
          SizedBox(width: 6),
          SizedBox(
            width: 110,
            child: Text(
              'دائن',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: AppColors.credit,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TableRow extends StatelessWidget {
  final _Row row;
  final int index;
  const _TableRow({required this.row, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: index.isEven ? Colors.white : AppColors.background,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              row.account.code,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              row.account.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12.5),
            ),
          ),
          SizedBox(
            width: 110,
            child: Text(
              row.debit == 0 ? '-' : Formatters.number(row.debit, decimals: 0),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: row.debit == 0 ? AppColors.textLight : AppColors.debit,
                fontWeight: row.debit == 0
                    ? FontWeight.normal
                    : FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 110,
            child: Text(
              row.credit == 0
                  ? '-'
                  : Formatters.number(row.credit, decimals: 0),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: row.credit == 0 ? AppColors.textLight : AppColors.credit,
                fontWeight: row.credit == 0
                    ? FontWeight.normal
                    : FontWeight.w600,
              ),
            ),
          ),
        ],
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
