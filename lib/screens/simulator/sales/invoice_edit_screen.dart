import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/invoice.dart';
import '../../../providers/accounting_provider.dart';
import '../../../providers/accounting_engine.dart';

class InvoiceEditScreen extends StatefulWidget {
  final InvoiceKind kind;
  final String? invoiceId;
  const InvoiceEditScreen({super.key, required this.kind, this.invoiceId});

  @override
  State<InvoiceEditScreen> createState() => _InvoiceEditScreenState();
}

class _InvoiceEditScreenState extends State<InvoiceEditScreen> {
  late Invoice _inv;
  bool _isNew = false;
  final _paidCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final acc = context.read<AccountingProvider>();
    if (widget.invoiceId != null) {
      _inv = acc.invoices.firstWhere((x) => x.id == widget.invoiceId);
    } else {
      _isNew = true;
      _inv = Invoice(
        id: 'inv_${DateTime.now().millisecondsSinceEpoch}',
        number: 0,
        kind: widget.kind,
        date: DateTime.now(),
        partnerId: '',
        partnerName: '',
        lines: [],
        paymentType: InvoicePaymentType.cash,
      );
    }
    _paidCtrl.text = _inv.paidAmount == 0 ? '' : _inv.paidAmount.toString();
    _notesCtrl.text = _inv.notes ?? '';
  }

  bool get _isPurchase =>
      widget.kind == InvoiceKind.purchase ||
      widget.kind == InvoiceKind.purchaseReturn;

  bool get _isReturn =>
      widget.kind == InvoiceKind.saleReturn ||
      widget.kind == InvoiceKind.purchaseReturn;

  String get _title {
    switch (widget.kind) {
      case InvoiceKind.sale:
        return _isNew ? 'فاتورة بيع جديدة' : 'فاتورة بيع #${_inv.number}';
      case InvoiceKind.purchase:
        return _isNew ? 'فاتورة شراء جديدة' : 'فاتورة شراء #${_inv.number}';
      case InvoiceKind.saleReturn:
        return _isNew ? 'مرتجع بيع جديد' : 'مرتجع بيع #${_inv.number}';
      case InvoiceKind.purchaseReturn:
        return _isNew ? 'مرتجع شراء جديد' : 'مرتجع شراء #${_inv.number}';
    }
  }

  Color get _color {
    switch (widget.kind) {
      case InvoiceKind.sale:
        return AppColors.success;
      case InvoiceKind.purchase:
        return AppColors.warning;
      case InvoiceKind.saleReturn:
        return AppColors.warning;
      case InvoiceKind.purchaseReturn:
        return AppColors.error;
    }
  }

  void _addLine() {
    final acc = context.read<AccountingProvider>();
    if (acc.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا توجد أصناف. أضف أصنافًا أولًا.')),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        String? selectedItemId;
        final qtyCtrl = TextEditingController(text: '1');
        final priceCtrl = TextEditingController();
        final discountCtrl = TextEditingController(text: '0');
        return StatefulBuilder(
          builder: (ctx, setState) => Padding(
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
                  const Text(
                    'إضافة صنف للفاتورة',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedItemId,
                    decoration: const InputDecoration(labelText: 'الصنف'),
                    isExpanded: true,
                    items: acc.items
                        .map(
                          (it) => DropdownMenuItem(
                            value: it.id,
                            child: Text(
                              '${it.name} (متاح: ${Formatters.number(it.quantity, decimals: 0)} ${it.unit})',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      setState(() {
                        selectedItemId = v;
                        if (v != null) {
                          final it = acc.itemById(v)!;
                          priceCtrl.text = (_isPurchase ? it.cost : it.price)
                              .toString();
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: qtyCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'الكمية',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: priceCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'السعر'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: discountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'الخصم (اختياري)',
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check),
                      label: const Text('إضافة'),
                      onPressed: () {
                        if (selectedItemId == null) return;
                        final it = acc.itemById(selectedItemId!)!;
                        final qty = double.tryParse(qtyCtrl.text) ?? 0;
                        final price = double.tryParse(priceCtrl.text) ?? 0;
                        final disc = double.tryParse(discountCtrl.text) ?? 0;
                        if (qty <= 0 || price <= 0) return;
                        this.setState(() {
                          _inv.lines.add(
                            InvoiceLine(
                              itemId: it.id,
                              itemName: it.name,
                              quantity: qty,
                              unitPrice: price,
                              discount: disc,
                            ),
                          );
                        });
                        Navigator.pop(ctx);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _save() async {
    final acc = context.read<AccountingProvider>();
    if (_inv.partnerId.isEmpty) {
      _err(_isPurchase ? 'اختر المورد' : 'اختر العميل');
      return;
    }
    if (_inv.lines.isEmpty) {
      _err('أضف صنفًا واحدًا على الأقل');
      return;
    }
    if (_inv.paymentType == InvoicePaymentType.mixed) {
      _inv.paidAmount = double.tryParse(_paidCtrl.text) ?? 0;
      if (_inv.paidAmount <= 0 || _inv.paidAmount >= _inv.total) {
        _err(
          'في الفاتورة المختلطة، المدفوع يجب أن يكون أقل من الإجمالي وأكبر من صفر',
        );
        return;
      }
    }
    _inv.notes = _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim();
    // Save invoice
    await acc.addInvoice(_inv);
    // Auto-generate journal entry
    final je = AccountingEngine.journalFromInvoice(_inv, acc);
    await acc.addJournal(je);
    _inv.journalEntryId = je.id;
    _inv.posted = true;
    await acc.addInvoice(_inv);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حفظ الفاتورة وترحيل القيد')),
    );
    Navigator.pop(context);
  }

  void _err(String s) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(s), backgroundColor: AppColors.error));

  @override
  Widget build(BuildContext context) {
    final acc = context.watch<AccountingProvider>();
    final partners = _isPurchase ? acc.suppliers : acc.customers;
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        backgroundColor: _color,
        actions: [
          if (!_isNew)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final navigator = Navigator.of(context);
                await acc.deleteInvoice(_inv.id);
                if (mounted) navigator.pop();
              },
            ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(10),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    InkWell(
                      onTap: _isNew
                          ? () async {
                              final d = await showDatePicker(
                                context: context,
                                initialDate: _inv.date,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (d != null) setState(() => _inv.date = d);
                            }
                          : null,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'التاريخ',
                          isDense: true,
                          prefixIcon: Icon(Icons.calendar_today, size: 18),
                        ),
                        child: Text(Formatters.date(_inv.date)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _inv.partnerId.isEmpty
                          ? null
                          : _inv.partnerId,
                      decoration: InputDecoration(
                        labelText: _isPurchase ? 'المورد' : 'العميل',
                        isDense: true,
                        prefixIcon: const Icon(Icons.person, size: 18),
                      ),
                      isExpanded: true,
                      items: partners
                          .map(
                            (p) => DropdownMenuItem(
                              value: p.id,
                              child: Text(
                                p.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: _isNew
                          ? (v) {
                              if (v != null) {
                                final p = partners.firstWhere((x) => x.id == v);
                                setState(() {
                                  _inv.partnerId = v;
                                  _inv.partnerName = p.name;
                                });
                              }
                            }
                          : null,
                    ),
                    const SizedBox(height: 8),
                    if (!_isReturn)
                      DropdownButtonFormField<InvoicePaymentType>(
                        initialValue: _inv.paymentType,
                        decoration: const InputDecoration(
                          labelText: 'طريقة الدفع',
                          isDense: true,
                          prefixIcon: Icon(Icons.payment, size: 18),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: InvoicePaymentType.cash,
                            child: Text('نقدي'),
                          ),
                          DropdownMenuItem(
                            value: InvoicePaymentType.credit,
                            child: Text('آجل'),
                          ),
                          DropdownMenuItem(
                            value: InvoicePaymentType.mixed,
                            child: Text('مختلط (نقد + آجل)'),
                          ),
                        ],
                        onChanged: _isNew
                            ? (v) => setState(() {
                                _inv.paymentType = v ?? InvoicePaymentType.cash;
                              })
                            : null,
                      ),
                    if (_inv.paymentType == InvoicePaymentType.mixed) ...[
                      const SizedBox(height: 8),
                      TextField(
                        controller: _paidCtrl,
                        enabled: _isNew,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'المبلغ المدفوع نقدًا',
                          isDense: true,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  const Text(
                    'الأصناف',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const Spacer(),
                  if (_isNew)
                    TextButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('صنف'),
                      onPressed: _addLine,
                    ),
                ],
              ),
            ),
            ..._inv.lines.asMap().entries.map((e) {
              final i = e.key;
              final l = e.value;
              return Card(
                child: ListTile(
                  dense: true,
                  title: Text(
                    l.itemName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  subtitle: Text(
                    '${Formatters.number(l.quantity, decimals: 0)} × ${Formatters.number(l.unitPrice, decimals: 0)}${l.discount > 0 ? " - خصم ${Formatters.number(l.discount, decimals: 0)}" : ""}',
                    style: const TextStyle(fontSize: 11.5),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        Formatters.currency(l.total, decimals: 0),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      if (_isNew)
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(
                            Icons.close,
                            color: AppColors.error,
                            size: 18,
                          ),
                          onPressed: () =>
                              setState(() => _inv.lines.removeAt(i)),
                        ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            Card(
              color: _color.withValues(alpha: 0.05),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    _row(
                      'الإجمالي',
                      Formatters.currency(_inv.total, decimals: 0),
                      bold: true,
                      color: _color,
                      large: true,
                    ),
                    if (_inv.paymentType == InvoicePaymentType.mixed) ...[
                      const Divider(),
                      _row(
                        'المدفوع نقدًا',
                        Formatters.currency(_inv.paidAmount, decimals: 0),
                      ),
                      _row(
                        'الباقي (آجل)',
                        Formatters.currency(_inv.remaining, decimals: 0),
                        color: AppColors.warning,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesCtrl,
              enabled: _isNew,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'ملاحظات',
                isDense: true,
              ),
            ),
            const SizedBox(height: 16),
            if (_isNew)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text('حفظ وترحيل'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _color,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _save,
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: AppColors.success),
                    SizedBox(width: 8),
                    Text(
                      'الفاتورة مرحّلة',
                      style: TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _row(
    String label,
    String value, {
    bool bold = false,
    Color? color,
    bool large = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: color ?? AppColors.textPrimary,
              fontSize: large ? 16 : 13,
            ),
          ),
        ],
      ),
    );
  }
}
