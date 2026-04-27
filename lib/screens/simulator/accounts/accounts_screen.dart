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
                        fontSize: 12.5,
                        color: AppColors.textPrimary,
                      ),
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
    final acc = context.read<AccountingProvider>();
    final name = TextEditingController();
    final code = TextEditingController();
    AccountType type = AccountType.asset;
    String? parent;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('إضافة حساب جديد'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: code,
                  decoration: const InputDecoration(labelText: 'الرقم'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: name,
                  decoration: const InputDecoration(labelText: 'الاسم'),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<AccountType>(
                  initialValue: type,
                  decoration: const InputDecoration(labelText: 'النوع'),
                  items: AccountType.values
                      .map(
                        (t) => DropdownMenuItem(
                          value: t,
                          child: Text(t.arabicName),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => type = v ?? type),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String?>(
                  initialValue: parent,
                  decoration: const InputDecoration(labelText: 'الحساب الأب'),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('لا يوجد (حساب رئيسي)'),
                    ),
                    ...acc.accounts
                        .where((a) => !a.isPostable)
                        .map(
                          (a) => DropdownMenuItem<String?>(
                            value: a.id,
                            child: Text('${a.code} - ${a.name}'),
                          ),
                        ),
                  ],
                  onChanged: (v) => setState(() => parent = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (name.text.trim().isEmpty || code.text.trim().isEmpty) {
                  return;
                }
                final id = 'acc_${DateTime.now().millisecondsSinceEpoch}';
                await acc.addAccount(
                  Account(
                    id: id,
                    code: code.text.trim(),
                    name: name.text.trim(),
                    type: type,
                    parentId: parent,
                    isPostable: true,
                  ),
                );
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
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
          ),
          subtitle: Text(
            root.type.arabicName,
            style: TextStyle(color: typeColor, fontSize: 11),
          ),
          trailing: Text(
            Formatters.currency(balance, decimals: 0),
            style: TextStyle(
              color: balance == 0 ? AppColors.textLight : AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
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
        ),
        subtitle: Text(
          root.type.arabicName,
          style: TextStyle(color: typeColor, fontSize: 11),
        ),
        children: children
            .map(
              (c) => Padding(
                padding: const EdgeInsetsDirectional.only(start: 12),
                child: _AccountTile(root: c),
              ),
            )
            .toList(),
      ),
    );
  }
}
