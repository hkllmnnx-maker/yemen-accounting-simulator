import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/financial_accounting/financial_statement.dart';
import '../../../providers/financial_accounting_provider.dart';

/// شاشة القوائم المالية: قائمة الدخل، قائمة المركز المالي،
/// وقائمة التدفقات النقدية المبسّطة - تُحسب آنيًا من القيود.
class FaFinancialStatementsScreen extends StatelessWidget {
  const FaFinancialStatementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fa = context.watch<FinancialAccountingProvider>();
    final income = fa.buildIncomeStatement();
    final bs = fa.buildBalanceSheet();
    final cf = fa.buildCashFlow();

    if (fa.simJournal.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'لا توجد قيود لإنتاج القوائم المالية بعد.\n'
            'أدخل قيودًا في تبويب اليومية أولاً.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _IncomeStatementCard(income: income),
        const SizedBox(height: 12),
        _BalanceSheetCard(bs: bs),
        const SizedBox(height: 12),
        _CashFlowCard(cf: cf),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _IncomeStatementCard extends StatelessWidget {
  final IncomeStatement income;
  const _IncomeStatementCard({required this.income});

  @override
  Widget build(BuildContext context) {
    final isProfit = income.netIncome >= 0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Header(
              icon: Icons.show_chart,
              title: 'قائمة الدخل',
              color: AppColors.revenue,
            ),
            const Divider(height: 16),
            // Revenues
            const _SubHeader(label: 'الإيرادات', color: AppColors.revenue),
            for (final l in income.revenues)
              _Line(label: l.label, amount: l.amount),
            const SizedBox(height: 4),
            _TotalLine(
              label: 'إجمالي الإيرادات',
              amount: income.totalRevenues,
              color: AppColors.revenue,
            ),
            const SizedBox(height: 10),
            // Expenses
            const _SubHeader(label: 'المصروفات', color: AppColors.expenses),
            for (final l in income.expenses)
              _Line(label: l.label, amount: l.amount),
            const SizedBox(height: 4),
            _TotalLine(
              label: 'إجمالي المصروفات',
              amount: income.totalExpenses,
              color: AppColors.expenses,
            ),
            const Divider(),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isProfit ? AppColors.successLight : AppColors.errorLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    isProfit ? Icons.trending_up : Icons.trending_down,
                    color: isProfit ? AppColors.success : AppColors.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isProfit ? 'صافي الربح' : 'صافي الخسارة',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                        color: isProfit ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ),
                  Text(
                    Formatters.currency(income.netIncome.abs()),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isProfit ? AppColors.success : AppColors.error,
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

class _BalanceSheetCard extends StatelessWidget {
  final BalanceSheetReport bs;
  const _BalanceSheetCard({required this.bs});

  @override
  Widget build(BuildContext context) {
    final balanced = bs.isBalanced;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Header(
              icon: Icons.account_balance,
              title: 'قائمة المركز المالي',
              color: AppColors.assets,
            ),
            const Divider(height: 16),
            // Assets
            const _SubHeader(label: 'الأصول', color: AppColors.assets),
            for (final l in bs.assets) _Line(label: l.label, amount: l.amount),
            _TotalLine(
              label: 'إجمالي الأصول',
              amount: bs.totalAssets,
              color: AppColors.assets,
            ),
            const SizedBox(height: 10),
            // Liabilities
            const _SubHeader(label: 'الالتزامات', color: AppColors.liabilities),
            for (final l in bs.liabilities)
              _Line(label: l.label, amount: l.amount),
            _TotalLine(
              label: 'إجمالي الالتزامات',
              amount: bs.totalLiabilities,
              color: AppColors.liabilities,
            ),
            const SizedBox(height: 10),
            // Equity
            const _SubHeader(label: 'حقوق الملكية', color: AppColors.equity),
            for (final l in bs.equity) _Line(label: l.label, amount: l.amount),
            _Line(
              label: bs.netIncome >= 0
                  ? 'صافي ربح الفترة'
                  : 'صافي خسارة الفترة',
              amount: bs.netIncome,
              valueColor: bs.netIncome >= 0
                  ? AppColors.success
                  : AppColors.error,
            ),
            _TotalLine(
              label: 'إجمالي حقوق الملكية',
              amount: bs.totalEquity,
              color: AppColors.equity,
            ),
            const Divider(),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: balanced ? AppColors.successLight : AppColors.errorLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        balanced ? Icons.check_circle : Icons.error,
                        color: balanced ? AppColors.success : AppColors.error,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          balanced ? 'القائمة متوازنة' : 'القائمة غير متوازنة',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: balanced
                                ? AppColors.success
                                : AppColors.error,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'الأصول: ${Formatters.currency(bs.totalAssets)}\n'
                    'الالتزامات + حقوق الملكية: ${Formatters.currency(bs.totalLiabilitiesAndEquity)}',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                      height: 1.5,
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

class _CashFlowCard extends StatelessWidget {
  final SimpleCashFlowStatement cf;
  const _CashFlowCard({required this.cf});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Header(
              icon: Icons.account_balance_wallet,
              title: 'قائمة التدفقات النقدية المبسّطة',
              color: AppColors.info,
            ),
            const Divider(height: 16),
            const _SubHeader(
              label: 'تدفقات نقدية داخلة',
              color: AppColors.success,
            ),
            if (cf.inflows.isEmpty)
              const Padding(
                padding: EdgeInsets.all(6),
                child: Text(
                  '-',
                  style: TextStyle(fontSize: 12, color: AppColors.textLight),
                ),
              )
            else
              for (final l in cf.inflows)
                _Line(
                  label: l.label,
                  amount: l.amount,
                  valueColor: AppColors.success,
                ),
            _TotalLine(
              label: 'إجمالي التدفقات الداخلة',
              amount: cf.totalInflows,
              color: AppColors.success,
            ),
            const SizedBox(height: 8),
            const _SubHeader(
              label: 'تدفقات نقدية خارجة',
              color: AppColors.error,
            ),
            if (cf.outflows.isEmpty)
              const Padding(
                padding: EdgeInsets.all(6),
                child: Text(
                  '-',
                  style: TextStyle(fontSize: 12, color: AppColors.textLight),
                ),
              )
            else
              for (final l in cf.outflows)
                _Line(
                  label: l.label,
                  amount: l.amount,
                  valueColor: AppColors.error,
                ),
            _TotalLine(
              label: 'إجمالي التدفقات الخارجة',
              amount: cf.totalOutflows,
              color: AppColors.error,
            ),
            const Divider(),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cf.netCashFlow >= 0
                    ? AppColors.successLight
                    : AppColors.errorLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    cf.netCashFlow >= 0
                        ? Icons.trending_up
                        : Icons.trending_down,
                    color: cf.netCashFlow >= 0
                        ? AppColors.success
                        : AppColors.error,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'صافي التدفق النقدي',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Text(
                    Formatters.currency(cf.netCashFlow.abs()),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                      color: cf.netCashFlow >= 0
                          ? AppColors.success
                          : AppColors.error,
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

class _Header extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  const _Header({required this.icon, required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _SubHeader extends StatelessWidget {
  final String label;
  final Color color;
  const _SubHeader({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 12.5,
          ),
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  final String label;
  final double amount;
  final Color? valueColor;
  const _Line({required this.label, required this.amount, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            Formatters.currency(amount),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalLine extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  const _TotalLine({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(4),
        border: Border(top: BorderSide(color: color.withValues(alpha: 0.4))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12.5,
              ),
            ),
          ),
          Text(
            Formatters.currency(amount),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
