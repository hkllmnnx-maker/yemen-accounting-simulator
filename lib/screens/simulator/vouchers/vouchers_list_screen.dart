import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/voucher.dart';
import '../../../providers/accounting_provider.dart';
import '../../../widgets/section_card.dart';
import 'voucher_edit_screen.dart';

class VouchersListScreen extends StatelessWidget {
  const VouchersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('السندات'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.add_circle_outline), text: 'سندات قبض'),
              Tab(icon: Icon(Icons.remove_circle_outline), text: 'سندات صرف'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _VouchersList(kind: VoucherKind.receipt),
            _VouchersList(kind: VoucherKind.payment),
          ],
        ),
      ),
    );
  }
}

class _VouchersList extends StatelessWidget {
  final VoucherKind kind;
  const _VouchersList({required this.kind});

  @override
  Widget build(BuildContext context) {
    final acc = context.watch<AccountingProvider>();
    final list = kind == VoucherKind.receipt
        ? acc.receiptVouchers
        : acc.paymentVouchers;
    final color =
        kind == VoucherKind.receipt ? AppColors.success : AppColors.error;
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: color,
        icon: const Icon(Icons.add),
        label: Text(
            kind == VoucherKind.receipt ? 'سند قبض جديد' : 'سند صرف جديد'),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => VoucherEditScreen(kind: kind)),
        ),
      ),
      body: SafeArea(
        child: list.isEmpty
            ? EmptyState(
                icon: Icons.receipt_long,
                message: kind == VoucherKind.receipt
                    ? 'لا توجد سندات قبض. أنشئ أول سند.'
                    : 'لا توجد سندات صرف. أنشئ أول سند.',
              )
            : ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final v = list[i];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: color.withValues(alpha: 0.15),
                        foregroundColor: color,
                        child: Text('#${v.number}',
                            style: const TextStyle(fontSize: 11)),
                      ),
                      title: Text(v.partnerName,
                          style:
                              const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        '${Formatters.date(v.date)} • ${v.cashAccountName}${v.notes != null && v.notes!.isNotEmpty ? " • ${v.notes}" : ""}',
                        style: const TextStyle(fontSize: 11.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text(
                        Formatters.currency(v.amount, decimals: 0),
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => VoucherEditScreen(
                                kind: kind, voucherId: v.id)),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
