import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/account.dart';
import '../../../providers/accounting_provider.dart';

class BalanceSheetScreen extends StatelessWidget {
  const BalanceSheetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final acc = context.watch<AccountingProvider>();
    final assets = <_Item>[];
    final liabs = <_Item>[];
    final equities = <_Item>[];
    double totalAssets = 0, totalLiabs = 0, totalEquity = 0;
    double totalRev = 0, totalExp = 0;
    final balances = acc.allBalances();

    for (final a in acc.postableAccounts) {
      final bal = balances[a.id] ?? 0;
      if (bal == 0) continue;
      switch (a.type) {
        case AccountType.asset:
          totalAssets += bal;
          assets.add(_Item(a.name, bal));
          break;
        case AccountType.liability:
          totalLiabs += bal;
          liabs.add(_Item(a.name, bal));
          break;
        case AccountType.equity:
          totalEquity += bal;
          equities.add(_Item(a.name, bal));
          break;
        case AccountType.revenue:
          totalRev += bal;
          break;
        case AccountType.expense:
          totalExp += bal;
          break;
      }
    }
    final retainedEarnings = totalRev - totalExp;
    if (retainedEarnings != 0) {
      equities.add(_Item('صافي الربح/الخسارة للفترة', retainedEarnings));
      totalEquity += retainedEarnings;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('المركز المالي')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            _Sect(
              title: 'الأصول',
              color: AppColors.assets,
              items: assets,
              total: totalAssets,
            ),
            _Sect(
              title: 'الالتزامات',
              color: AppColors.liabilities,
              items: liabs,
              total: totalLiabs,
            ),
            _Sect(
              title: 'حقوق الملكية',
              color: AppColors.equity,
              items: equities,
              total: totalEquity,
            ),
            const SizedBox(height: 12),
            Card(
              color: AppColors.primary.withValues(alpha: 0.05),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    const Text(
                      'معادلة الميزانية',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'الأصول = الالتزامات + حقوق الملكية',
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${Formatters.currency(totalAssets, decimals: 0)} = ${Formatters.currency(totalLiabs + totalEquity, decimals: 0)}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color:
                            (totalAssets - (totalLiabs + totalEquity)).abs() <
                                0.5
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            (totalAssets - (totalLiabs + totalEquity)).abs() <
                                0.5
                            ? AppColors.successLight
                            : AppColors.errorLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        (totalAssets - (totalLiabs + totalEquity)).abs() < 0.5
                            ? '✓ الميزانية متوازنة'
                            : '✗ الميزانية غير متوازنة - الفرق: ${Formatters.number((totalAssets - (totalLiabs + totalEquity)).abs(), decimals: 0)}',
                        style: TextStyle(
                          color:
                              (totalAssets - (totalLiabs + totalEquity)).abs() <
                                  0.5
                              ? AppColors.success
                              : AppColors.error,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
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

class _Sect extends StatelessWidget {
  final String title;
  final Color color;
  final List<_Item> items;
  final double total;
  const _Sect({
    required this.title,
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
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Text(
                  Formatters.currency(total, decimals: 0),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const Divider(),
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  'لا توجد بنود',
                  style: TextStyle(color: AppColors.textLight, fontSize: 12),
                ),
              )
            else
              ...items.map(
                (it) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          it.name,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      Text(
                        Formatters.currency(it.amount, decimals: 0),
                        style: const TextStyle(fontSize: 12.5),
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

class _Item {
  final String name;
  final double amount;
  _Item(this.name, this.amount);
}
