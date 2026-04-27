import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/accounting_provider.dart';
import '../../../providers/accounting_engine.dart';

class CashReportScreen extends StatelessWidget {
  const CashReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final acc = context.watch<AccountingProvider>();
    final cashAccs = CashAccountsHelper.cashAndBankAccounts(acc);

    return Scaffold(
      appBar: AppBar(title: const Text('تقرير الصندوق والبنوك')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            ...cashAccs.map((a) {
              final bal = acc.accountBalance(a.id);
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.success.withValues(alpha: 0.15),
                    foregroundColor: AppColors.success,
                    child: Icon(
                      a.parentId == 'a111'
                          ? Icons.account_balance_wallet
                          : Icons.account_balance,
                    ),
                  ),
                  title: Text(a.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle:
                      Text('${a.code} • ${a.currency}', style: const TextStyle(fontSize: 11)),
                  trailing: Text(
                    Formatters.currency(bal, decimals: 0),
                    style: TextStyle(
                      color: bal >= 0 ? AppColors.success : AppColors.error,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            Card(
              color: AppColors.background,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const Icon(Icons.summarize, color: AppColors.primary),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text('إجمالي السيولة (بالريال اليمني)',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                    Text(
                      Formatters.currency(
                        cashAccs.fold<double>(0, (s, a) => s + acc.accountBalance(a.id)),
                        decimals: 0,
                      ),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
