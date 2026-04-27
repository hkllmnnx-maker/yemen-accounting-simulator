import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/invoice.dart';
import '../../../providers/accounting_provider.dart';
import '../../../widgets/section_card.dart';
import 'invoice_edit_screen.dart';

class SalesListScreen extends StatelessWidget {
  const SalesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('المبيعات'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.point_of_sale), text: 'فواتير بيع'),
              Tab(icon: Icon(Icons.assignment_return), text: 'مرتجعات بيع'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _List(kind: InvoiceKind.sale),
            _List(kind: InvoiceKind.saleReturn),
          ],
        ),
      ),
    );
  }
}

class _List extends StatelessWidget {
  final InvoiceKind kind;
  const _List({required this.kind});

  @override
  Widget build(BuildContext context) {
    final acc = context.watch<AccountingProvider>();
    final list = acc.invoices.where((i) => i.kind == kind).toList();
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: Text(kind == InvoiceKind.sale ? 'فاتورة بيع' : 'مرتجع بيع'),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => InvoiceEditScreen(kind: kind)),
        ),
      ),
      body: SafeArea(
        child: list.isEmpty
            ? EmptyState(
                icon: Icons.receipt,
                message: kind == InvoiceKind.sale
                    ? 'لا توجد فواتير بيع. أنشئ أول فاتورة.'
                    : 'لا توجد مرتجعات بيع.',
              )
            : ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final inv = list[i];
                  final color = kind == InvoiceKind.sale
                      ? AppColors.success
                      : AppColors.warning;
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: color.withValues(alpha: 0.15),
                        foregroundColor: color,
                        child: Text(
                          '#${inv.number}',
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                      title: Text(
                        inv.partnerName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${Formatters.date(inv.date)} • ${inv.lines.length} أصناف • ${_paymentLabel(inv.paymentType)}',
                        style: const TextStyle(fontSize: 11.5),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            Formatters.currency(inv.total, decimals: 0),
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          if (inv.remaining > 0)
                            Text(
                              'باقي ${Formatters.number(inv.remaining, decimals: 0)}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.warning,
                              ),
                            ),
                        ],
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              InvoiceEditScreen(kind: kind, invoiceId: inv.id),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  String _paymentLabel(InvoicePaymentType t) {
    switch (t) {
      case InvoicePaymentType.cash:
        return 'نقدية';
      case InvoicePaymentType.credit:
        return 'آجلة';
      case InvoicePaymentType.mixed:
        return 'مختلطة';
    }
  }
}
