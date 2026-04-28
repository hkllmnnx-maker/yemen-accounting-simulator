import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/account.dart';
import '../../../providers/accounting_provider.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final acc = context.watch<AccountingProvider>();
    final roots = acc.children(null);
    return Scaffold(
      appBar: AppBar(
        title: const Text('شجرة الحسابات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'إضافة حساب',
            onPressed: () => _showAddAccount(context),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(8),
          children: [
            // Legend
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppColors.infoLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info, color: AppColors.info, size: 18),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'الحسابات الرئيسية لا تقبل قيودًا. القيود تُسجل على الحسابات الفرعية.',
                      style: TextStyle(
                          fontSize: 12.5, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
            ...roots.map((r) => _AccountTile(root: r)),
          ],
        ),
      ),
    );
  }

  void _showAddAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const _AddAccountDialog(),
    );
  }
}

class _AddAccountDialog extends StatefulWidget {
  const _AddAccountDialog();

  @override
  State<_AddAccountDialog> createState() => _AddAccountDialogState();
}

class _AddAccountDialogState extends State<_AddAccountDialog> {
  final _nameCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  AccountType _type = AccountType.asset;
  String? _parent;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final acc = context.read<AccountingProvider>();
    final name = _nameCtrl.text.trim();
    final code = _codeCtrl.text.trim();
    if (name.isEmpty || code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال الاسم والرقم')),
      );
      return;
    }
    // Prevent duplicate codes
    if (acc.accounts.any((a) => a.code == code)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('رقم الحساب مستخدم مسبقًا')),
      );
      return;
    }
    setState(() => _saving = true);
    final id = 'acc_${DateTime.now().millisecondsSinceEpoch}';
    await acc.addAccount(Account(
      id: id,
      code: code,
      name: name,
      type: _type,
      parentId: _parent,
      isPostable: true,
    ));
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final acc = context.watch<AccountingProvider>();
    return AlertDialog(
      title: const Text('إضافة حساب جديد'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _codeCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'الرقم'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'الاسم'),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<AccountType>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'النوع'),
              items: AccountType.values
                  .map((t) =>
                      DropdownMenuItem(value: t, child: Text(t.arabicName)))
                  .toList(),
              onChanged: (v) => setState(() => _type = v ?? _type),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String?>(
              initialValue: _parent,
              decoration: const InputDecoration(labelText: 'الحساب الأب'),
              isExpanded: true,
              items: [
                const DropdownMenuItem<String?>(
                    value: null, child: Text('لا يوجد (حساب رئيسي)')),
                ...acc.accounts
                    .where((a) => !a.isPostable)
                    .map((a) => DropdownMenuItem<String?>(
                        value: a.id,
                        child: Text(
                          '${a.code} - ${a.name}',
                          overflow: TextOverflow.ellipsis,
                        ))),
              ],
              onChanged: (v) => setState(() => _parent = v),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}

class _AccountTile extends StatelessWidget {
  final Account root;
  const _AccountTile({required this.root});

  Color get typeColor {
    switch (root.type) {
      case AccountType.asset:
        return AppColors.assets;
      case AccountType.liability:
        return AppColors.liabilities;
      case AccountType.equity:
        return AppColors.equity;
      case AccountType.revenue:
        return AppColors.revenue;
      case AccountType.expense:
        return AppColors.expenses;
    }
  }

  @override
  Widget build(BuildContext context) {
    final acc = context.watch<AccountingProvider>();
    final children = acc.children(root.id);
    final balance = acc.accountBalance(root.id);

    if (children.isEmpty) {
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
        child: ListTile(
          dense: true,
          leading: Container(
            width: 8,
            decoration: BoxDecoration(
              color: typeColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          title: Text(
            '${root.code} • ${root.name}',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(root.type.arabicName,
              style: TextStyle(color: typeColor, fontSize: 11)),
          trailing: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 110),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerEnd,
              child: Text(
                Formatters.currency(balance, decimals: 0),
                style: TextStyle(
                  color: balance == 0
                      ? AppColors.textLight
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: ExpansionTile(
        initiallyExpanded: root.parentId == null,
        leading: Container(
          width: 6,
          decoration: BoxDecoration(
            color: typeColor,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        title: Text(
          '${root.code} • ${root.name}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(root.type.arabicName,
            style: TextStyle(color: typeColor, fontSize: 11)),
        children: children
            .map((c) => Padding(
                  padding: const EdgeInsetsDirectional.only(start: 12),
                  child: _AccountTile(root: c),
                ))
            .toList(),
      ),
    );
  }
}
