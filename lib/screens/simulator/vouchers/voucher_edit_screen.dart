import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/voucher.dart';
import '../../../providers/accounting_provider.dart';
import '../../../providers/accounting_engine.dart';

class VoucherEditScreen extends StatefulWidget {
  final VoucherKind kind;
  final String? voucherId;
  const VoucherEditScreen({super.key, required this.kind, this.voucherId});

  @override
  State<VoucherEditScreen> createState() => _VoucherEditScreenState();
}

class _VoucherEditScreenState extends State<VoucherEditScreen> {
  late Voucher _v;
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _isNew = false;

  @override
  void initState() {
    super.initState();
    final acc = context.read<AccountingProvider>();
    if (widget.voucherId != null) {
      _v = (acc.vouchers.firstWhere((x) => x.id == widget.voucherId));
    } else {
      _isNew = true;
      _v = Voucher(
        id: 'v_${DateTime.now().millisecondsSinceEpoch}',
        number: 0,
        kind: widget.kind,
        date: DateTime.now(),
        partnerId: '',
        partnerName: '',
        cashAccountId: AccountingEngine.mainCashAccountId,
        cashAccountName: 'الصندوق الرئيسي',
        amount: 0,
      );
    }
    _amountCtrl.text = _v.amount == 0 ? '' : _v.amount.toString();
    _notesCtrl.text = _v.notes ?? '';
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final acc = context.read<AccountingProvider>();
    if (_v.partnerId.isEmpty) {
      _err(widget.kind == VoucherKind.receipt
          ? 'اختر العميل'
          : 'اختر المورد');
      return;
    }
    final amt = double.tryParse(_amountCtrl.text) ?? 0;
    if (amt <= 0) {
      _err('أدخل مبلغًا صحيحًا');
      return;
    }
    if (_v.cashAccountId.isEmpty) {
      _err('اختر الصندوق أو البنك');
      return;
    }
    _v.amount = amt;
    _v.notes = _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    // إنشاء قيد محاسبي تلقائي
    final je = AccountingEngine.journalFromVoucher(_v, acc);
    await acc.addJournal(je);
    _v.journalEntryId = je.id;
    _v.posted = true;
    await acc.addVoucher(_v);

    if (!mounted) return;
    messenger.showSnackBar(
      const SnackBar(content: Text('تم حفظ السند وترحيل القيد')),
    );
    navigator.pop();
  }

  void _err(String s) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(s), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final acc = context.watch<AccountingProvider>();
    final isReceipt = widget.kind == VoucherKind.receipt;
    final color = isReceipt ? AppColors.success : AppColors.error;
    final partners =
        isReceipt ? acc.customers : acc.suppliers;
    final cashAccounts = CashAccountsHelper.cashAndBankAccounts(acc);

    return Scaffold(
      appBar: AppBar(
        title: Text(isReceipt
            ? (_isNew ? 'سند قبض جديد' : 'سند قبض #${_v.number}')
            : (_isNew ? 'سند صرف جديد' : 'سند صرف #${_v.number}')),
        backgroundColor: color,
        actions: [
          if (!_isNew)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final navigator = Navigator.of(context);
                await acc.deleteVoucher(_v.id);
                if (mounted) navigator.pop();
              },
            ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    isReceipt
                        ? Icons.add_circle_outline
                        : Icons.remove_circle_outline,
                    color: color,
                    size: 30,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isReceipt
                          ? 'استلام مبلغ من عميل (يزيد رصيد الصندوق وينقص مديونية العميل)'
                          : 'دفع مبلغ لمورد (ينقص رصيد الصندوق وينقص مديونية المورد علينا)',
                      style: const TextStyle(
                          fontSize: 12.5, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    InkWell(
                      onTap: _isNew
                          ? () async {
                              final d = await showDatePicker(
                                context: context,
                                initialDate: _v.date,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (d != null) setState(() => _v.date = d);
                            }
                          : null,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'التاريخ',
                          prefixIcon: Icon(Icons.calendar_today, size: 18),
                        ),
                        child: Text(Formatters.date(_v.date)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _v.partnerId.isEmpty ? null : _v.partnerId,
                      decoration: InputDecoration(
                        labelText: isReceipt ? 'العميل' : 'المورد',
                        prefixIcon: const Icon(Icons.person, size: 18),
                      ),
                      isExpanded: true,
                      items: partners
                          .map((p) => DropdownMenuItem(
                                value: p.id,
                                child: Text('${p.name} (${p.city})',
                                    overflow: TextOverflow.ellipsis),
                              ))
                          .toList(),
                      onChanged: _isNew
                          ? (v) {
                              if (v != null) {
                                final p = partners.firstWhere(
                                    (x) => x.id == v,
                                    orElse: () => partners.first);
                                setState(() {
                                  _v.partnerId = v;
                                  _v.partnerName = p.name;
                                });
                              }
                            }
                          : null,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _v.cashAccountId,
                      decoration: const InputDecoration(
                        labelText: 'الصندوق / البنك',
                        prefixIcon:
                            Icon(Icons.account_balance_wallet, size: 18),
                      ),
                      isExpanded: true,
                      items: cashAccounts
                          .map((a) => DropdownMenuItem(
                                value: a.id,
                                child: Text(a.name,
                                    overflow: TextOverflow.ellipsis),
                              ))
                          .toList(),
                      onChanged: _isNew
                          ? (v) {
                              if (v != null) {
                                final a = cashAccounts
                                    .firstWhere((x) => x.id == v);
                                setState(() {
                                  _v.cashAccountId = v;
                                  _v.cashAccountName = a.name;
                                });
                              }
                            }
                          : null,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _amountCtrl,
                      enabled: _isNew,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'المبلغ',
                        prefixIcon: Icon(Icons.attach_money, size: 18),
                        suffixText: 'ر.ي',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _notesCtrl,
                      enabled: _isNew,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'ملاحظات (اختياري)',
                        prefixIcon: Icon(Icons.note, size: 18),
                      ),
                    ),
                  ],
                ),
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
                    backgroundColor: color,
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
                    Text('السند مرحّل ومعتمد',
                        style: TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}


