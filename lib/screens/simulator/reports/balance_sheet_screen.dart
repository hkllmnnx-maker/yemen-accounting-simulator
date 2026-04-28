import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/account.dart';
import '../../../providers/accounting_provider.dart';

/// قائمة المركز المالي (الميزانية العمومية)
/// تعرض الأصول والالتزامات وحقوق الملكية مع تأكيد التوازن.
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

    for (final a in acc.postableAccounts) {
      final bal = acc.accountBalance(a.id);
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

    final balanced = (totalAssets - (totalLiabs + totalEquity)).abs() < 0.5;

    return Scaffold(
      appBar: AppBar(title: const Text('المركز المالي')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(10),
          children: [
            // بانر الميزانية
            _BalanceBanner(
              totalAssets: totalAssets,
              totalLiabs: totalLiabs,
              totalEquity: totalEquity,
              balanced: balanced,
            ),
            const SizedBox(height: 12),
            _Sect(
              title: 'الأصول',
              icon: Icons.account_balance_rounded,
              color: AppColors.assets,
              items: assets,
              total: totalAssets,
            ),
            _Sect(
              title: 'الالتزامات',
              icon: Icons.assignment_late_rounded,
              color: AppColors.liabilities,
              items: liabs,
              total: totalLiabs,
            ),
            _Sect(
              title: 'حقوق الملكية',
              icon: Icons.account_circle_rounded,
              color: AppColors.equity,
              items: equities,
              total: totalEquity,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _BalanceBanner extends StatelessWidget {
  final double totalAssets;
  final double totalLiabs;
  final double totalEquity;
  final bool balanced;

  const _BalanceBanner({
    required this.totalAssets,
    required this.totalLiabs,
    required this.totalEquity,
    required this.balanced,
  });

  @override
  Widget build(BuildContext context) {
    final color = balanced ? AppColors.success : AppColors.error;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.10),
            color.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                balanced ? Icons.check_circle_rounded : Icons.error_rounded,
                color: color,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  balanced ? 'الميزانية متوازنة' : 'الميزانية غير متوازنة',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // معادلة الميزانية مرئيًا
          LayoutBuilder(
            builder: (context, c) {
              final compact = c.maxWidth < 360;
              if (compact) {
                return Column(
                  children: [
                    _eqBox('الأصول', totalAssets, AppColors.assets),
                    const SizedBox(height: 4),
                    const Text('=', style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 4),
                    _eqBox('الالتزامات', totalLiabs, AppColors.liabilities),
                    const SizedBox(height: 4),
                    const Text('+', style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 4),
                    _eqBox('حقوق الملكية', totalEquity, AppColors.equity),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(
                    child: _eqBox('الأصول', totalAssets, AppColors.assets),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      '=',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _eqBox(
                      'الالتزامات',
                      totalLiabs,
                      AppColors.liabilities,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      '+',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _eqBox(
                      'حقوق الملكية',
                      totalEquity,
                      AppColors.equity,
                    ),
                  ),
                ],
              );
            },
          ),
          if (!balanced) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'الفرق: ${Formatters.number((totalAssets - (totalLiabs + totalEquity)).abs(), decimals: 0)} ر.ي',
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
    );
  }

  Widget _eqBox(String label, double value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            child: Text(
              Formatters.number(value, decimals: 0),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Sect extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<_Item> items;
  final double total;
  const _Sect({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.20), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    Formatters.currency(total, decimals: 0),
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Center(
                  child: Text(
                    'لا توجد بنود في هذا القسم',
                    style: TextStyle(color: AppColors.textLight, fontSize: 12),
                  ),
                ),
              )
            else
              ...items.map(
                (it) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          it.name,
                          style: const TextStyle(fontSize: 13),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        Formatters.currency(it.amount, decimals: 0),
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
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

class _Item {
  final String name;
  final double amount;
  _Item(this.name, this.amount);
}
