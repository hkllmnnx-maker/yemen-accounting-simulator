import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../providers/accounting_provider.dart';
import '../../widgets/section_card.dart';
import 'accounts/accounts_screen.dart';
import 'journal/journal_list_screen.dart';
import 'customers/customers_screen.dart';
import 'suppliers/suppliers_screen.dart';
import 'inventory/items_screen.dart';
import 'sales/sales_list_screen.dart';
import 'purchases/purchases_list_screen.dart';
import 'vouchers/vouchers_list_screen.dart';
import 'reports/reports_home_screen.dart';

class SimulatorHomeScreen extends StatelessWidget {
  const SimulatorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final acc = context.watch<AccountingProvider>();
    final cashBalance = acc.accountBalance('a1111');
    final receivables = acc.customers.fold<double>(
      0,
      (s, p) => s + acc.partnerBalance(p.id),
    );
    final payables = acc.suppliers.fold<double>(
      0,
      (s, p) => s + acc.partnerBalance(p.id),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('النظام المحاسبي التدريبي')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            // Top stats
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.business, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          acc.company.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Text(
                        'سنة ${acc.company.fiscalYear}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.account_balance_wallet,
                    label: 'الصندوق الرئيسي',
                    value: Formatters.currency(cashBalance),
                    color: AppColors.success,
                  ),
                ),
                Expanded(
                  child: StatCard(
                    icon: Icons.inventory,
                    label: 'الأصناف',
                    value: '${acc.items.length}',
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.people,
                    label: 'مديونية العملاء',
                    value: Formatters.currency(receivables),
                    color: AppColors.primary,
                  ),
                ),
                Expanded(
                  child: StatCard(
                    icon: Icons.local_shipping,
                    label: 'مديونيتنا للموردين',
                    value: Formatters.currency(payables),
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const _Heading(title: 'الحسابات العامة'),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              childAspectRatio: 0.95,
              children: [
                SectionCard(
                  icon: Icons.account_tree,
                  title: 'شجرة الحسابات',
                  color: AppColors.primary,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AccountsScreen()),
                  ),
                ),
                SectionCard(
                  icon: Icons.book,
                  title: 'القيود اليومية',
                  color: AppColors.accent,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const JournalListScreen(),
                    ),
                  ),
                ),
                SectionCard(
                  icon: Icons.receipt_long,
                  title: 'سندات قبض/صرف',
                  color: AppColors.success,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const VouchersListScreen(),
                    ),
                  ),
                ),
              ],
            ),
            const _Heading(title: 'العملاء والموردون'),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              childAspectRatio: 0.95,
              children: [
                SectionCard(
                  icon: Icons.people,
                  title: 'العملاء',
                  color: AppColors.primary,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CustomersScreen()),
                  ),
                ),
                SectionCard(
                  icon: Icons.local_shipping,
                  title: 'الموردون',
                  color: AppColors.warning,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SuppliersScreen()),
                  ),
                ),
                SectionCard(
                  icon: Icons.inventory_2,
                  title: 'الأصناف والمخزون',
                  color: AppColors.accent,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ItemsScreen()),
                  ),
                ),
              ],
            ),
            const _Heading(title: 'الفواتير'),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.6,
              children: [
                SectionCard(
                  icon: Icons.point_of_sale,
                  title: 'المبيعات',
                  color: AppColors.success,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SalesListScreen()),
                  ),
                ),
                SectionCard(
                  icon: Icons.shopping_cart,
                  title: 'المشتريات',
                  color: AppColors.warning,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PurchasesListScreen(),
                    ),
                  ),
                ),
              ],
            ),
            const _Heading(title: 'التقارير'),
            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.info,
                  foregroundColor: Colors.white,
                  child: Icon(Icons.assessment),
                ),
                title: const Text(
                  'التقارير المالية',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  'ميزان المراجعة • قائمة الدخل • المركز المالي • تقارير العملاء والمخزون',
                ),
                trailing: const Icon(Icons.chevron_left),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ReportsHomeScreen()),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  final String title;
  const _Heading({required this.title});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
