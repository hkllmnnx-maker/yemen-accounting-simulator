import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../providers/accounting_provider.dart';
import '../../widgets/section_card.dart';
import '../../widgets/thumbnails/section_thumbnails.dart';
import 'accounts/accounts_screen.dart';
import 'journal/journal_list_screen.dart';
import 'customers/customers_screen.dart';
import 'suppliers/suppliers_screen.dart';
import 'inventory/items_screen.dart';
import 'sales/sales_list_screen.dart';
import 'purchases/purchases_list_screen.dart';
import 'vouchers/vouchers_list_screen.dart';
import 'reports/reports_home_screen.dart';

/// شاشة النظام المحاسبي التدريبي - تحاكي البرامج المحاسبية اليمنية الحقيقية.
///
/// تستخدم البطاقات الجديدة المُزوَّدة بصور مصغّرة احترافية مرسومة خصيصًا،
/// مع تخطيط متجاوب يَحفظ النصوص العربية كاملةً على جميع الأحجام.
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
            // عمود واحد إضافي على الشاشات الصغيرة لمنع قَصّ النص العربي.
            // الحد الفاصل 420px يضمن وضوح ثلاث بطاقات + هامش مريح على هواتف
            // متوسطة الحجم (Pixel/iPhone) دون ضغط بصري.
            final cols = w < 420
                ? 2
                : w < 720
                ? 3
                : w < 1000
                ? 4
                : 6;
            // نسبة العرض إلى الارتفاع: قيم أصغر = بطاقات أطول → نص عربي مريح.
            final cardRatio = w < 420 ? 0.86 : 0.92;

            return ListView(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
              children: [
                _CompanyBanner(
                  companyName: acc.company.name,
                  city: acc.company.city,
                  fiscalYear: acc.company.fiscalYear,
                ),
                const SizedBox(height: 14),

                // ========== مؤشرات مالية رئيسية ==========
                LayoutBuilder(
                  builder: (context, c) {
                    final isWide = c.maxWidth >= 600;
                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: isWide ? 4 : 2,
                      childAspectRatio: isWide ? 2.4 : 2.05,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      children: [
                        StatCard(
                          thumbnail: ThumbnailKind.cashBox,
                          label: 'الصندوق',
                          value: Formatters.currency(cashBalance, decimals: 0),
                          color: AppColors.success,
                        ),
                        StatCard(
                          thumbnail: ThumbnailKind.inventoryValue,
                          label: 'قيمة المخزون',
                          value: Formatters.currency(
                            inventoryValue,
                            decimals: 0,
                          ),
                          color: AppColors.accent,
                        ),
                        StatCard(
                          thumbnail: ThumbnailKind.receivables,
                          label: 'مديونية العملاء',
                          value: Formatters.currency(receivables, decimals: 0),
                          color: AppColors.primary,
                        ),
                        StatCard(
                          thumbnail: ThumbnailKind.payables,
                          label: 'مديونيتنا للموردين',
                          value: Formatters.currency(payables, decimals: 0),
                          color: AppColors.warning,
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 18),
                const SectionHeader(
                  title: 'الحسابات والقيود',
                  subtitle: 'العمود الفقري لأي نظام محاسبي',
                  icon: Icons.book_rounded,
                ),
                const SizedBox(height: 8),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: cols,
                  childAspectRatio: cardRatio,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  children: [
                    SectionCard(
                      thumbnail: ThumbnailKind.accountsTree,
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
                      thumbnail: ThumbnailKind.journalEntries,
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
                      thumbnail: ThumbnailKind.vouchers,
                      title: 'سندات قبض وصرف',
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

                const SizedBox(height: 18),
                const SectionHeader(
                  title: 'العملاء والموردون والأصناف',
                  subtitle: 'إدارة الأطراف والمخزون',
                  icon: Icons.people_alt_rounded,
                  color: AppColors.accent,
                ),
                const SizedBox(height: 8),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: cols,
                  childAspectRatio: cardRatio,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  children: [
                    SectionCard(
                      thumbnail: ThumbnailKind.customers,
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
                      thumbnail: ThumbnailKind.suppliers,
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
                      thumbnail: ThumbnailKind.inventory,
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

                const SizedBox(height: 18),
                const SectionHeader(
                  title: 'الفواتير',
                  subtitle: 'فواتير البيع والشراء',
                  icon: Icons.receipt_rounded,
                  color: AppColors.success,
                ),
                const SizedBox(height: 8),
                LayoutBuilder(
                  builder: (context, c) {
                    final isWide = c.maxWidth >= 600;
                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: isWide ? 4 : 2,
                      childAspectRatio: isWide ? 1.7 : 1.35,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      children: [
                        SectionCard(
                          thumbnail: ThumbnailKind.sales,
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
                          thumbnail: ThumbnailKind.purchases,
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

                const SizedBox(height: 18),
                const SectionHeader(
                  title: 'التقارير المالية',
                  subtitle: 'ميزان المراجعة، قائمة الدخل، المركز المالي',
                  icon: Icons.assessment_rounded,
                  color: AppColors.info,
                ),
                const SizedBox(height: 8),
                _ReportsLauncher(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ReportsHomeScreen(),
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

class _ReportsLauncher extends StatelessWidget {
  final VoidCallback onTap;
  const _ReportsLauncher({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
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
              const SectionThumbnail(
                kind: ThumbnailKind.reports,
                color: AppColors.info,
                size: 56,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'لوحة التقارير الكاملة',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'ستة تقارير: ميزان مراجعة، قائمة دخل، مركز مالي، '
                      'مبيعات، مخزون، صندوق.',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                        height: 1.45,
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
          const SectionThumbnail(
            kind: ThumbnailKind.company,
            color: Colors.white,
            size: 50,
            padded: false,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  companyName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          color: Colors.white70,
                          size: 13,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          city,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Colors.white38,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Text(
                      'السنة المالية $fiscalYear',
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
