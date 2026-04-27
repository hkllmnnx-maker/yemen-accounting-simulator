import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/invoice.dart';
import '../../../providers/accounting_provider.dart';

class SalesReportScreen extends StatelessWidget {
  const SalesReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final acc = context.watch<AccountingProvider>();
    final sales = acc.invoices
        .where((i) => i.kind == InvoiceKind.sale)
        .toList();
    final returns = acc.invoices
        .where((i) => i.kind == InvoiceKind.saleReturn)
        .toList();
    final totalSales = sales.fold<double>(0, (s, i) => s + i.total);
    final totalReturns = returns.fold<double>(0, (s, i) => s + i.total);
    final cogs = acc.totalCogs;
    final grossProfit = totalSales - totalReturns - cogs;

    return Scaffold(
      appBar: AppBar(title: const Text('تقرير المبيعات')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            _stat(
              'إجمالي المبيعات',
              totalSales,
              AppColors.success,
              Icons.trending_up,
            ),
            _stat(
              'مرتجعات المبيعات',
              totalReturns,
              AppColors.warning,
              Icons.undo,
            ),
            _stat(
              'تكلفة البضاعة المباعة',
              cogs,
              AppColors.error,
              Icons.shopping_cart,
            ),
            const SizedBox(height: 8),
            Card(
              color: AppColors.primary.withValues(alpha: 0.05),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: grossProfit >= 0
                            ? AppColors.success.withValues(alpha: 0.15)
                            : AppColors.error.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        grossProfit >= 0 ? Icons.attach_money : Icons.money_off,
                        color: grossProfit >= 0
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'مجمل الربح',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Text(
                      Formatters.currency(grossProfit, decimals: 0),
                      style: TextStyle(
                        color: grossProfit >= 0
                            ? AppColors.success
                            : AppColors.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'آخر فواتير البيع',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            ...sales
                .take(20)
                .map(
                  (s) => Card(
                    child: ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        backgroundColor: AppColors.success.withValues(
                          alpha: 0.15,
                        ),
                        foregroundColor: AppColors.success,
                        child: Text(
                          '${s.number}',
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                      title: Text(
                        s.partnerName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      subtitle: Text(
                        '${Formatters.date(s.date)} • ${s.lines.length} أصناف',
                        style: const TextStyle(fontSize: 11),
                      ),
                      trailing: Text(
                        Formatters.currency(s.total, decimals: 0),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  ),
                ),
            if (sales.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    'لا توجد فواتير بيع بعد',
                    style: TextStyle(color: AppColors.textLight),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, double value, Color color, IconData icon) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          foregroundColor: color,
          child: Icon(icon),
        ),
        title: Text(label, style: const TextStyle(fontSize: 13)),
        trailing: Text(
          Formatters.currency(value, decimals: 0),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
