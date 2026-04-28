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
  late final TextEditingController _searchCtrl;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final acc = context.watch<AccountingProvider>();
    final list = acc.items
        .where((it) =>
            _q.isEmpty || it.name.contains(_q) || it.code.contains(_q))
        .toList();
    final totalValue =
        acc.items.fold<double>(0, (s, it) => s + (it.cost * it.quantity));
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
                    child: Text('قيمة المخزون بالتكلفة',
                        style: TextStyle(fontSize: 13)),
                  ),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerEnd,
                      child: Text(Formatters.currency(totalValue, decimals: 0),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.accent,
                              fontSize: 14)),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TextField(
                controller: _searchCtrl,
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
                            title: Text(it.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.5),
                                overflow: TextOverflow.ellipsis),
                            subtitle: Text(
                              '${it.code} • ${it.unit} • تكلفة ${Formatters.number(it.cost, decimals: 0)} • سعر ${Formatters.number(it.price, decimals: 0)}',
                              style: const TextStyle(fontSize: 11),
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '${Formatters.number(it.quantity, decimals: 0)} ${it.unit}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: low
                                          ? AppColors.error
                                          : AppColors.success,
                                    ),
                                  ),
                                ),
                                if (low)
                                  const Text('مخزون منخفض',
                                      style: TextStyle(
                                          fontSize: 9,
                                          color: AppColors.error)),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _ItemFormSheet(existing: existing),
    );
  }
}

class _ItemFormSheet extends StatefulWidget {
  final Item? existing;
  const _ItemFormSheet({this.existing});

  @override
  State<_ItemFormSheet> createState() => _ItemFormSheetState();
}

class _ItemFormSheetState extends State<_ItemFormSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _unitCtrl;
  late final TextEditingController _costCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _qtyCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _unitCtrl = TextEditingController(text: e?.unit ?? 'حبة');
    _costCtrl = TextEditingController(text: (e?.cost ?? 0).toString());
    _priceCtrl = TextEditingController(text: (e?.price ?? 0).toString());
    _qtyCtrl = TextEditingController(text: (e?.quantity ?? 0).toString());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _unitCtrl.dispose();
    _costCtrl.dispose();
    _priceCtrl.dispose();
    _qtyCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال اسم الصنف')),
      );
      return;
    }
    final cost = double.tryParse(_costCtrl.text) ?? 0;
    final price = double.tryParse(_priceCtrl.text) ?? 0;
    final qty = double.tryParse(_qtyCtrl.text) ?? 0;
    if (cost < 0 || price < 0 || qty < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يُسمح بقيم سالبة')),
      );
      return;
    }
    setState(() => _saving = true);
    final acc = context.read<AccountingProvider>();
    if (widget.existing == null) {
      final id = 'item_${DateTime.now().millisecondsSinceEpoch}';
      final code =
          'P${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      await acc.addItem(Item(
        id: id,
        code: code,
        name: name,
        unit: _unitCtrl.text.trim(),
        cost: cost,
        price: price,
        quantity: qty,
      ));
    } else {
      final existing = widget.existing!;
      existing.name = name;
      existing.unit = _unitCtrl.text.trim();
      existing.cost = cost;
      existing.price = price;
      existing.quantity = qty;
      await acc.updateItem(existing);
    }
    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> _delete() async {
    final acc = context.read<AccountingProvider>();
    final navigator = Navigator.of(context);
    await acc.deleteItem(widget.existing!.id);
    if (!mounted) return;
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.existing == null ? 'صنف جديد' : 'تعديل الصنف',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
                controller: _nameCtrl,
                decoration:
                    const InputDecoration(labelText: 'اسم الصنف')),
            const SizedBox(height: 8),
            TextField(
                controller: _unitCtrl,
                decoration: const InputDecoration(
                    labelText: 'وحدة القياس (كرتون، كيس، حبة...)')),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _costCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration:
                        const InputDecoration(labelText: 'سعر التكلفة'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _priceCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration:
                        const InputDecoration(labelText: 'سعر البيع'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
                controller: _qtyCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                    labelText: 'الرصيد الافتتاحي / الكمية')),
            const SizedBox(height: 16),
            Row(
              children: [
                if (widget.existing != null)
                  TextButton.icon(
                    icon: const Icon(Icons.delete, color: AppColors.error),
                    label: const Text('حذف',
                        style: TextStyle(color: AppColors.error)),
                    onPressed: _saving ? null : _delete,
                  ),
                const Spacer(),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('حفظ'),
                  onPressed: _saving ? null : _save,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
