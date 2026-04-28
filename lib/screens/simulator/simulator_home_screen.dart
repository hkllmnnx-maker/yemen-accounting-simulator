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

/// شاشة النظام المحاسبي التدريبي - تحاكي البرامج المحاسبية اليمنية الحقيقية
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
    final inventoryValue = acc.items.fold<double>(
      0,
      (s, i) => s + (i.quantity * i.cost),
    );
    final journalsCount = acc.journals.length;
    final salesCount = acc.salesInvoices.length;

    return Scaffold(
      appBar: AppBar(title: const Text('النظام المحاسبي التدريبي')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final cols = w < 360
                ? 2
                : w < 600
                ? 3
                : w < 900
                ? 4
                : 6;
            return ListView(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 24),
              children: [
                _CompanyBanner(
                  companyName: acc.company.name,
                  city: acc.company.city,
                  fiscalYear: acc.company.fiscalYear,
                ),
                const SizedBox(height: 12),

                // مؤشرات مالية رئيسية
                LayoutBuilder(
                  builder: (context, c) {
                    final isWide = c.maxWidth >= 600;
                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: isWide ? 4 : 2,
                      childAspectRatio: isWide ? 2.4 : 2.0,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                      children: [
                        StatCard(
                          icon: Icons.account_balance_wallet_rounded,
                          label: 'الصندوق',
                          value: Formatters.currency(cashBalance, decimals: 0),
                          color: AppColors.success,
                        ),
                        StatCard(
                          icon: Icons.inventory_2_rounded,
                          label: 'قيمة المخزون',
                          value: Formatters.currency(
                            inventoryValue,
                            decimals: 0,
                          ),
                          color: AppColors.accent,
                        ),
                        StatCard(
                          icon: Icons.people_rounded,
                          label: 'مديونية العملاء',
                          value: Formatters.currency(receivables, decimals: 0),
                          color: AppColors.primary,
                        ),
                        StatCard(
                          icon: Icons.local_shipping_rounded,
                          label: 'مديونيتنا للموردين',
                          value: Formatters.currency(payables, decimals: 0),
                          color: AppColors.warning,
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 14),
                const SectionHeader(
                  title: 'الحسابات والقيود',
                  subtitle: 'العمود الفقري لأي نظام محاسبي',
                  icon: Icons.book_rounded,
                ),
                const SizedBox(height: 6),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: cols,
                  childAspectRatio: 0.95,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  children: [
                    SectionCard(
                      icon: Icons.account_tree_rounded,
                      title: 'شجرة الحسابات',
                      subtitle: '${acc.accounts.length} حساب',
                      color: AppColors.primary,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AccountsScreen(),
                        ),
                      ),
                    ),
                    SectionCard(
                      icon: Icons.book_rounded,
                      title: 'القيود اليومية',
                      subtitle: '$journalsCount قيد',
                      color: AppColors.accent,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const JournalListScreen(),
                        ),
                      ),
                    ),
                    SectionCard(
                      icon: Icons.receipt_long_rounded,
                      title: 'سندات قبض/صرف',
                      subtitle: 'حركة الصندوق',
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

                const SizedBox(height: 14),
                const SectionHeader(
                  title: 'العملاء والموردون والأصناف',
                  subtitle: 'إدارة الأطراف والمخزون',
                  icon: Icons.people_alt_rounded,
                  color: AppColors.accent,
                ),
                const SizedBox(height: 6),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: cols,
                  childAspectRatio: 0.95,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  children: [
                    SectionCard(
                      icon: Icons.people_rounded,
                      title: 'العملاء',
                      subtitle: '${acc.customers.length} عميل',
                      color: AppColors.primary,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CustomersScreen(),
                        ),
                      ),
                    ),
                    SectionCard(
                      icon: Icons.local_shipping_rounded,
                      title: 'الموردون',
                      subtitle: '${acc.suppliers.length} مورد',
                      color: AppColors.warning,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SuppliersScreen(),
                        ),
                      ),
                    ),
                    SectionCard(
                      icon: Icons.inventory_2_rounded,
                      title: 'الأصناف والمخزون',
                      subtitle: '${acc.items.length} صنف',
                      color: AppColors.accent,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ItemsScreen()),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                const SectionHeader(
                  title: 'الفواتير',
                  subtitle: 'فواتير البيع والشراء',
                  icon: Icons.receipt_rounded,
                  color: AppColors.success,
                ),
                const SizedBox(height: 6),
                LayoutBuilder(
                  builder: (context, c) {
                    final isWide = c.maxWidth >= 600;
                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: isWide ? 4 : 2,
                      childAspectRatio: isWide ? 1.8 : 1.5,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                      children: [
                        SectionCard(
                          icon: Icons.point_of_sale_rounded,
                          title: 'المبيعات',
                          subtitle: '$salesCount فاتورة',
                          color: AppColors.success,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SalesListScreen(),
                            ),
                          ),
                        ),
                        SectionCard(
                          icon: Icons.shopping_cart_rounded,
                          title: 'المشتريات',
                          subtitle: '${acc.purchaseInvoices.length} فاتورة',
                          color: AppColors.warning,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PurchasesListScreen(),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 14),
                const SectionHeader(
                  title: 'التقارير المالية',
                  subtitle: 'ميزان المراجعة، قائمة الدخل، المركز المالي',
                  icon: Icons.assessment_rounded,
                  color: AppColors.info,
                ),
                const SizedBox(height: 6),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ReportsHomeScreen(),
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.info.withValues(alpha: 0.10),
                            AppColors.primary.withValues(alpha: 0.05),
                          ],
                        ),
                      ),
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppColors.info.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.assessment_rounded,
                              color: AppColors.info,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'لوحة التقارير الكاملة',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  '6 تقارير: ميزان مراجعة، قائمة دخل، مركز مالي،\n'
                                  'مبيعات، مخزون، صندوق',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: AppColors.textSecondary,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_back_ios_rounded,
                            size: 16,
                            color: AppColors.textLight,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CompanyBanner extends StatelessWidget {
  final String companyName;
  final String city;
  final int fiscalYear;

  const _CompanyBanner({
    required this.companyName,
    required this.city,
    required this.fiscalYear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.20),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.business_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  companyName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      color: Colors.white70,
                      size: 12,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      city,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '  •  السنة المالية $fiscalYear',
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
        ],
      ),
    );
  }
}
