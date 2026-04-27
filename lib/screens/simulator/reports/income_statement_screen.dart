import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/account.dart';
import '../../../providers/accounting_provider.dart';

class IncomeStatementScreen extends StatelessWidget {
  const IncomeStatementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final acc = context.watch<AccountingProvider>();
    double totalRevenue = 0;
    double totalExpense = 0;
    final revs = <_Item>[];
    final exps = <_Item>[];

    for (final a in acc.postableAccounts) {
      final bal = acc.accountBalance(a.id);
      if (bal == 0) continue;
      if (a.type == AccountType.revenue) {
        totalRevenue += bal;
        revs.add(_Item(a.name, bal));
      } else if (a.type == AccountType.expense) {
        totalExpense += bal;
        exps.add(_Item(a.name, bal));
      }
    }
    final net = totalRevenue - totalExpense;

    return Scaffold(
      appBar: AppBar(title: const Text('قائمة الدخل')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            _Section(
              title: 'الإيرادات',
              icon: Icons.trending_up,
              color: AppColors.success,
              items: revs,
              total: totalRevenue,
            ),
            const SizedBox(height: 12),
            _Section(
              title: 'المصروفات',
              icon: Icons.trending_down,
              color: AppColors.error,
              items: exps,
              total: totalExpense,
            ),
            const SizedBox(height: 16),
            Card(
              color: net >= 0 ? AppColors.successLight : AppColors.errorLight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      net >= 0 ? Icons.celebration : Icons.warning,
                      color: net >= 0 ? AppColors.success : AppColors.error,
                      size: 36,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      net >= 0 ? 'صافي الربح' : 'صافي الخسارة',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      Formatters.currency(net.abs(), decimals: 0),
                      style: TextStyle(
                        color: net >= 0 ? AppColors.success : AppColors.error,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<_Item> items;
  final double total;
  const _Section({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const Divider(),
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                    child: Text('لا توجد قيم',
                        style: TextStyle(color: AppColors.textLight))),
              )
            else
              ...items.map((it) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                            child: Text(it.name,
                                style: const TextStyle(fontSize: 13))),
                        Text(
                          Formatters.currency(it.amount, decimals: 0),
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  )),
            const Divider(),
            Row(
              children: [
                Text('إجمالي $title',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                const Spacer(),
                Text(
                  Formatters.currency(total, decimals: 0),
                  style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Item {
  final String name;
  final double amount;
  _Item(this.name, this.amount);
}
