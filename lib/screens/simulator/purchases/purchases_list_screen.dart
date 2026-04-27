import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/invoice.dart';
import '../../../providers/accounting_provider.dart';
import '../../../widgets/section_card.dart';
import '../sales/invoice_edit_screen.dart';

class PurchasesListScreen extends StatelessWidget {
  const PurchasesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('المشتريات'),
          bottom: const TabBar(tabs: [
            Tab(icon: Icon(Icons.shopping_cart), text: 'فواتير شراء'),
            Tab(icon: Icon(Icons.assignment_return), text: 'مرتجعات شراء'),
          ]),
        ),
        body: const TabBarView(children: [
          _List(kind: InvoiceKind.purchase),
          _List(kind: InvoiceKind.purchaseReturn),
        ]),
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
        label: Text(
            kind == InvoiceKind.purchase ? 'فاتورة شراء' : 'مرتجع شراء'),
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => InvoiceEditScreen(kind: kind))),
      ),
      body: SafeArea(
        child: list.isEmpty
            ? EmptyState(
                icon: Icons.shopping_cart_outlined,
                message: kind == InvoiceKind.purchase
                    ? 'لا توجد فواتير شراء.'
                    : 'لا توجد مرتجعات شراء.',
              )
            : ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final inv = list[i];
                  final color = kind == InvoiceKind.purchase
                      ? AppColors.warning
                      : AppColors.error;
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: color.withValues(alpha: 0.15),
                        foregroundColor: color,
                        child: Text('#${inv.number}',
                            style: const TextStyle(fontSize: 11)),
                      ),
                      title: Text(inv.partnerName,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        '${Formatters.date(inv.date)} • ${inv.lines.length} أصناف',
                        style: const TextStyle(fontSize: 11.5),
                      ),
                      trailing: Text(
                        Formatters.currency(inv.total, decimals: 0),
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => InvoiceEditScreen(
                              kind: kind, invoiceId: inv.id),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
