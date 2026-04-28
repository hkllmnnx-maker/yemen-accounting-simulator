import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/accounting_provider.dart';
import '../../../widgets/section_card.dart';
import 'trial_balance_screen.dart';
import 'income_statement_screen.dart';
import 'balance_sheet_screen.dart';
import 'sales_report_screen.dart';
import 'inventory_report_screen.dart';
import 'cash_report_screen.dart';

/// شاشة التقارير الرئيسية - تعرض كل التقارير المالية المتاحة
/// مع نظرة سريعة على المؤشرات المالية الأساسية.
class ReportsHomeScreen extends StatelessWidget {
  const ReportsHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final acc = context.watch<AccountingProvider>();
    final cashBalance = acc.accountBalance('a1111');
    final salesTotal = acc.salesInvoices.fold<double>(
      0,
      (s, inv) => s + inv.total,
    );
    final inventoryValue = acc.items.fold<double>(
      0,
      (s, i) => s + (i.quantity * i.cost),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('التقارير المالية')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(10),
          children: [
            // مؤشرات سريعة
            const SectionHeader(
              title: 'نظرة سريعة',
              icon: Icons.dashboard_rounded,
            ),
            const SizedBox(height: 6),
            LayoutBuilder(
              builder: (context, c) {
                final isWide = c.maxWidth >= 600;
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: isWide ? 3 : 2,
                  childAspectRatio: isWide ? 2.4 : 2.0,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  children: [
                    StatCard(
                      icon: Icons.account_balance_wallet_rounded,
                      label: 'رصيد الصندوق',
                      value: Formatters.currency(cashBalance, decimals: 0),
                      color: AppColors.success,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CashReportScreen(),
                        ),
                      ),
                    ),
                    StatCard(
                      icon: Icons.point_of_sale_rounded,
                      label: 'إجمالي المبيعات',
                      value: Formatters.currency(salesTotal, decimals: 0),
                      color: AppColors.primary,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SalesReportScreen(),
                        ),
                      ),
                    ),
                    StatCard(
                      icon: Icons.inventory_2_rounded,
                      label: 'قيمة المخزون',
                      value: Formatters.currency(inventoryValue, decimals: 0),
                      color: AppColors.accent,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const InventoryReportScreen(),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 16),
            const SectionHeader(
              title: 'القوائم المالية الرئيسية',
              subtitle: 'القوائم التي يجب على كل محاسب إعدادها',
              icon: Icons.assessment_rounded,
            ),
            const SizedBox(height: 6),
            _ReportTile(
              icon: Icons.balance_rounded,
              title: 'ميزان المراجعة',
              desc: 'كل الحسابات وأرصدتها مع تأكيد توازن المدين والدائن',
              color: AppColors.primary,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const TrialBalanceScreen(),
                ),
              ),
            ),
            _ReportTile(
              icon: Icons.trending_up_rounded,
              title: 'قائمة الدخل',
              desc: 'الإيرادات - المصروفات = صافي الربح/الخسارة',
              color: AppColors.success,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const IncomeStatementScreen(),
                ),
              ),
            ),
            _ReportTile(
              icon: Icons.account_balance_rounded,
              title: 'قائمة المركز المالي (الميزانية)',
              desc: 'الأصول = الالتزامات + حقوق الملكية',
              color: AppColors.equity,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BalanceSheetScreen(),
                ),
              ),
            ),

            const SizedBox(height: 14),
            const SectionHeader(
              title: 'تقارير تشغيلية',
              subtitle: 'تقارير يومية يحتاجها المحاسب باستمرار',
              icon: Icons.bar_chart_rounded,
              color: AppColors.accent,
            ),
            const SizedBox(height: 6),
            _ReportTile(
              icon: Icons.point_of_sale_rounded,
              title: 'تقرير المبيعات',
              desc: 'إجمالي المبيعات والأرباح والفواتير المسجلة',
              color: AppColors.success,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SalesReportScreen(),
                ),
              ),
            ),
            _ReportTile(
              icon: Icons.account_balance_wallet_rounded,
              title: 'تقرير الصندوق',
              desc: 'حركات الصندوق المُرحَّلة (قبض، صرف، فواتير نقدية)',
              color: AppColors.warning,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CashReportScreen(),
                ),
              ),
            ),
            _ReportTile(
              icon: Icons.inventory_rounded,
              title: 'تقرير المخزون',
              desc: 'الأصناف والكميات الحالية وقيمة المخزون بالتكلفة',
              color: AppColors.info,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const InventoryReportScreen(),
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

class _ReportTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final Color color;
  final VoidCallback onTap;

  const _ReportTile({
    required this.icon,
    required this.title,
    required this.desc,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.15), width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withValues(alpha: 0.18),
                      color.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      desc,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
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
                size: 14,
                color: AppColors.textLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
