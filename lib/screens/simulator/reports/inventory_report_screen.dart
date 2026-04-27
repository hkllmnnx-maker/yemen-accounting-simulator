import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/accounting_provider.dart';

class InventoryReportScreen extends StatelessWidget {
  const InventoryReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final acc = context.watch<AccountingProvider>();
    final items = acc.items;
    final totalCost =
        items.fold<double>(0, (s, it) => s + (it.cost * it.quantity));
    final totalSale =
        items.fold<double>(0, (s, it) => s + (it.price * it.quantity));
    final lowStock = items.where((it) => it.quantity < 5).length;

    return Scaffold(
      appBar: AppBar(title: const Text('تقرير المخزون')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                      child: _stat('قيمة بالتكلفة',
                          Formatters.currency(totalCost, decimals: 0),
                          AppColors.accent)),
                  Expanded(
                      child: _stat('قيمة بالبيع',
                          Formatters.currency(totalSale, decimals: 0),
                          AppColors.success)),
                  Expanded(
                      child: _stat('مخزون منخفض', '$lowStock صنف',
                          AppColors.error)),
                ],
              ),
            ),
            Container(
              color: AppColors.primary.withValues(alpha: 0.06),
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: const Row(
                children: [
                  Expanded(
                      child: Text('الصنف',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 11))),
                  SizedBox(
                      width: 60,
                      child: Text('الكمية',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 11))),
                  SizedBox(
                      width: 70,
                      child: Text('تكلفة',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 11))),
                  SizedBox(
                      width: 80,
                      child: Text('قيمة',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 11))),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final it = items[i];
                  final value = it.cost * it.quantity;
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(it.name,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                              Text('${it.code} • ${it.unit}',
                                  style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textLight)),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 60,
                          child: Text(
                            Formatters.number(it.quantity, decimals: 0),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: it.quantity < 5
                                  ? AppColors.error
                                  : AppColors.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 70,
                          child: Text(
                            Formatters.number(it.cost, decimals: 0),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                        SizedBox(
                          width: 80,
                          child: Text(
                            Formatters.number(value, decimals: 0),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.accent),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Text(value,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: color)),
          ],
        ),
      ),
    );
  }
}
