import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/item.dart';
import '../../../providers/accounting_provider.dart';
import '../../../widgets/section_card.dart';

class ItemsScreen extends StatefulWidget {
  const ItemsScreen({super.key});

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  String _q = '';
  @override
  Widget build(BuildContext context) {
    final acc = context.watch<AccountingProvider>();
    final list = acc.items
        .where(
          (it) => _q.isEmpty || it.name.contains(_q) || it.code.contains(_q),
        )
        .toList();
    final totalValue = acc.items.fold<double>(
      0,
      (s, it) => s + (it.cost * it.quantity),
    );
    return Scaffold(
      appBar: AppBar(title: const Text('الأصناف والمخزون')),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('صنف جديد'),
        onPressed: () => _showItemForm(context),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.inventory, color: AppColors.accent),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'قيمة المخزون بالتكلفة',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                  Text(
                    Formatters.currency(totalValue, decimals: 0),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TextField(
                onChanged: (v) => setState(() => _q = v),
                decoration: const InputDecoration(
                  hintText: 'بحث عن صنف...',
                  prefixIcon: Icon(Icons.search),
                  isDense: true,
                ),
              ),
            ),
            Expanded(
              child: list.isEmpty
                  ? const EmptyState(
                      icon: Icons.inventory_2_outlined,
                      message: 'لا توجد أصناف. أضف أول صنف.',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: list.length,
                      itemBuilder: (_, i) {
                        final it = list[i];
                        final low = it.quantity < 5;
                        return Card(
                          child: ListTile(
                            leading: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: low
                                    ? AppColors.error.withValues(alpha: 0.15)
                                    : AppColors.accent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.inventory_2,
                                color: low ? AppColors.error : AppColors.accent,
                              ),
                            ),
                            title: Text(
                              it.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5,
                              ),
                            ),
                            subtitle: Text(
                              '${it.code} • ${it.unit} • تكلفة ${Formatters.number(it.cost, decimals: 0)} • سعر ${Formatters.number(it.price, decimals: 0)}',
                              style: const TextStyle(fontSize: 11),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${Formatters.number(it.quantity, decimals: 0)} ${it.unit}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: low
                                        ? AppColors.error
                                        : AppColors.success,
                                  ),
                                ),
                                if (low)
                                  const Text(
                                    'مخزون منخفض',
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: AppColors.error,
                                    ),
                                  ),
                              ],
                            ),
                            onLongPress: () =>
                                _showItemForm(context, existing: it),
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

  void _showItemForm(BuildContext context, {Item? existing}) {
    final acc = context.read<AccountingProvider>();
    final name = TextEditingController(text: existing?.name ?? '');
    final unit = TextEditingController(text: existing?.unit ?? 'حبة');
    final cost = TextEditingController(text: (existing?.cost ?? 0).toString());
    final price = TextEditingController(
      text: (existing?.price ?? 0).toString(),
    );
    final qty = TextEditingController(
      text: (existing?.quantity ?? 0).toString(),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                existing == null ? 'صنف جديد' : 'تعديل الصنف',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'اسم الصنف'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: unit,
                decoration: const InputDecoration(
                  labelText: 'وحدة القياس (كرتون، كيس، حبة...)',
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: cost,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'سعر التكلفة',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: price,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'سعر البيع'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: qty,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'الرصيد الافتتاحي / الكمية',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (existing != null)
                    TextButton.icon(
                      icon: const Icon(Icons.delete, color: AppColors.error),
                      label: const Text(
                        'حذف',
                        style: TextStyle(color: AppColors.error),
                      ),
                      onPressed: () async {
                        await acc.deleteItem(existing.id);
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                    ),
                  const Spacer(),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('حفظ'),
                    onPressed: () async {
                      if (name.text.trim().isEmpty) return;
                      if (existing == null) {
                        final id =
                            'item_${DateTime.now().millisecondsSinceEpoch}';
                        final code =
                            'P${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
                        await acc.addItem(
                          Item(
                            id: id,
                            code: code,
                            name: name.text.trim(),
                            unit: unit.text.trim(),
                            cost: double.tryParse(cost.text) ?? 0,
                            price: double.tryParse(price.text) ?? 0,
                            quantity: double.tryParse(qty.text) ?? 0,
                          ),
                        );
                      } else {
                        existing.name = name.text.trim();
                        existing.unit = unit.text.trim();
                        existing.cost = double.tryParse(cost.text) ?? 0;
                        existing.price = double.tryParse(price.text) ?? 0;
                        existing.quantity = double.tryParse(qty.text) ?? 0;
                        await acc.updateItem(existing);
                      }
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
