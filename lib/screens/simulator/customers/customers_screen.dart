import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/partner.dart';
import '../../../data/seed/yemeni_data.dart';
import '../../../providers/accounting_provider.dart';
import '../../../widgets/section_card.dart';
import 'partner_statement_screen.dart';

class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final acc = context.watch<AccountingProvider>();
    final list = acc.customers;
    final total = list.fold<double>(0, (s, p) => s + acc.partnerBalance(p.id));
    return Scaffold(
      appBar: AppBar(title: const Text('العملاء')),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.person_add),
        label: const Text('عميل جديد'),
        onPressed: () => _showPartnerForm(context, kind: PartnerKind.customer),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_balance_wallet,
                      color: AppColors.primary),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text('إجمالي مديونية العملاء',
                        style: TextStyle(
                            fontSize: 13, color: AppColors.textPrimary)),
                  ),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerEnd,
                      child: Text(Formatters.currency(total, decimals: 0),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              fontSize: 14)),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: list.isEmpty
                  ? const EmptyState(
                      icon: Icons.people_outline,
                      message: 'لا يوجد عملاء بعد. أضف أول عميل.')
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: list.length,
                      itemBuilder: (_, i) {
                        final p = list[i];
                        final bal = acc.partnerBalance(p.id);
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  AppColors.primary.withValues(alpha: 0.15),
                              foregroundColor: AppColors.primary,
                              child: Text(
                                  p.name.isEmpty
                                      ? '?'
                                      : p.name.substring(0, 1),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ),
                            title: Text(p.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis),
                            subtitle: Text(
                                '${p.city} • ${p.isCredit ? "آجل" : "نقدي"} • ${p.code}',
                                style: const TextStyle(fontSize: 11.5),
                                overflow: TextOverflow.ellipsis),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    Formatters.currency(bal, decimals: 0),
                                    style: TextStyle(
                                      color: bal > 0
                                          ? AppColors.error
                                          : (bal < 0
                                              ? AppColors.success
                                              : AppColors.textLight),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                Text(
                                  bal > 0
                                      ? 'مديونية'
                                      : (bal < 0 ? 'له لدينا' : 'مسوّى'),
                                  style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textLight),
                                ),
                              ],
                            ),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      PartnerStatementScreen(partnerId: p.id)),
                            ),
                            onLongPress: () => _showPartnerForm(context,
                                kind: PartnerKind.customer, existing: p),
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

void showPartnerForm(BuildContext context,
    {required PartnerKind kind, Partner? existing}) {
  _showPartnerForm(context, kind: kind, existing: existing);
}

void _showPartnerForm(BuildContext context,
    {required PartnerKind kind, Partner? existing}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => _PartnerFormSheet(kind: kind, existing: existing),
  );
}

class _PartnerFormSheet extends StatefulWidget {
  final PartnerKind kind;
  final Partner? existing;
  const _PartnerFormSheet({required this.kind, this.existing});

  @override
  State<_PartnerFormSheet> createState() => _PartnerFormSheetState();
}

class _PartnerFormSheetState extends State<_PartnerFormSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _creditLimitCtrl;
  late final TextEditingController _openingCtrl;
  late String _city;
  late bool _isCredit;
  late String _currency;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _phoneCtrl = TextEditingController(text: e?.phone ?? '');
    _creditLimitCtrl =
        TextEditingController(text: (e?.creditLimit ?? 0).toString());
    _openingCtrl =
        TextEditingController(text: (e?.openingBalance ?? 0).toString());
    _city = e?.city ?? YemeniData.cities.first;
    _isCredit = e?.isCredit ?? true;
    _currency = e?.currency ?? 'YER';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _creditLimitCtrl.dispose();
    _openingCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال الاسم')),
      );
      return;
    }
    setState(() => _saving = true);
    final acc = context.read<AccountingProvider>();
    if (widget.existing == null) {
      final newCode =
          'P${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      final p = Partner(
        id: 'p_${DateTime.now().millisecondsSinceEpoch}',
        code: newCode,
        name: name,
        kind: widget.kind,
        city: _city,
        phone: _phoneCtrl.text.trim(),
        isCredit: _isCredit,
        creditLimit: double.tryParse(_creditLimitCtrl.text) ?? 0,
        currency: _currency,
        openingBalance: double.tryParse(_openingCtrl.text) ?? 0,
        accountId: '',
      );
      await acc.addPartner(p);
    } else {
      final existing = widget.existing!;
      existing.name = name;
      existing.city = _city;
      existing.phone = _phoneCtrl.text.trim();
      existing.isCredit = _isCredit;
      existing.creditLimit = double.tryParse(_creditLimitCtrl.text) ?? 0;
      existing.currency = _currency;
      existing.openingBalance = double.tryParse(_openingCtrl.text) ?? 0;
      await acc.updatePartner(existing);
    }
    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> _delete() async {
    final acc = context.read<AccountingProvider>();
    final navigator = Navigator.of(context);
    await acc.deletePartner(widget.existing!.id);
    if (!mounted) return;
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final existing = widget.existing;
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
            Text(
              existing == null
                  ? (widget.kind == PartnerKind.customer
                      ? 'عميل جديد'
                      : 'مورد جديد')
                  : 'تعديل ${existing.name}',
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'الاسم'),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _city,
              decoration: const InputDecoration(labelText: 'المدينة'),
              isExpanded: true,
              items: YemeniData.cities
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _city = v ?? _city),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration:
                  const InputDecoration(labelText: 'رقم الهاتف (اختياري)'),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _currency,
              decoration: const InputDecoration(labelText: 'العملة'),
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'YER', child: Text('ريال يمني')),
                DropdownMenuItem(value: 'USD', child: Text('دولار أمريكي')),
                DropdownMenuItem(value: 'SAR', child: Text('ريال سعودي')),
              ],
              onChanged: (v) => setState(() => _currency = v ?? 'YER'),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              value: _isCredit,
              onChanged: (v) => setState(() => _isCredit = v),
              title: Text(widget.kind == PartnerKind.customer
                  ? 'تعامل آجل (مع مديونية)'
                  : 'تعامل آجل'),
              contentPadding: EdgeInsets.zero,
            ),
            if (widget.kind == PartnerKind.customer && _isCredit)
              TextField(
                controller: _creditLimitCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true),
                decoration:
                    const InputDecoration(labelText: 'حد الائتمان (ر.ي)'),
              ),
            const SizedBox(height: 8),
            TextField(
              controller: _openingCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'الرصيد الافتتاحي (اختياري)',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (existing != null)
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
