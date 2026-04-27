import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/partner.dart';
import '../../../providers/accounting_provider.dart';
import '../../../widgets/section_card.dart';
import '../customers/customers_screen.dart';
import '../customers/partner_statement_screen.dart';

class SuppliersScreen extends StatelessWidget {
  const SuppliersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final acc = context.watch<AccountingProvider>();
    final list = acc.suppliers;
    final total = list.fold<double>(0, (s, p) => s + acc.partnerBalance(p.id));
    return Scaffold(
      appBar: AppBar(title: const Text('الموردون')),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.local_shipping),
        label: const Text('مورد جديد'),
        onPressed: () => showPartnerForm(context, kind: PartnerKind.supplier),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shopping_basket, color: AppColors.warning),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'إجمالي ما علينا للموردين',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    Formatters.currency(total, decimals: 0),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.warning,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: list.isEmpty
                  ? const EmptyState(
                      icon: Icons.local_shipping_outlined,
                      message: 'لا يوجد موردون بعد. أضف أول مورد.',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: list.length,
                      itemBuilder: (_, i) {
                        final p = list[i];
                        final bal = acc.partnerBalance(p.id);
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.warning.withValues(
                                alpha: 0.15,
                              ),
                              foregroundColor: AppColors.warning,
                              child: Text(
                                p.name.substring(0, 1),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              p.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${p.city} • ${p.code} • ${p.currency}',
                              style: const TextStyle(fontSize: 11.5),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  Formatters.currency(bal, decimals: 0),
                                  style: TextStyle(
                                    color: bal > 0
                                        ? AppColors.warning
                                        : (bal < 0
                                              ? AppColors.success
                                              : AppColors.textLight),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  bal > 0
                                      ? 'علينا'
                                      : (bal < 0 ? 'لنا لديه' : 'مسوّى'),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textLight,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    PartnerStatementScreen(partnerId: p.id),
                              ),
                            ),
                            onLongPress: () => showPartnerForm(
                              context,
                              kind: PartnerKind.supplier,
                              existing: p,
                            ),
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
}
