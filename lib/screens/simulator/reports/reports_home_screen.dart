import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'trial_balance_screen.dart';
import 'income_statement_screen.dart';
import 'balance_sheet_screen.dart';
import 'sales_report_screen.dart';
import 'inventory_report_screen.dart';
import 'cash_report_screen.dart';

class ReportsHomeScreen extends StatelessWidget {
  const ReportsHomeScreen({super.key});

  final reports = const [
    _R(
        Icons.balance,
        'ميزان المراجعة',
        'كل الحسابات وأرصدتها مع تأكيد توازن المدين والدائن',
        AppColors.primary),
    _R(Icons.trending_up, 'قائمة الدخل',
        'الإيرادات - المصروفات = صافي الربح/الخسارة', AppColors.success),
    _R(
        Icons.account_balance,
        'المركز المالي (الميزانية)',
        'الأصول = الالتزامات + حقوق الملكية',
        AppColors.accent),
    _R(Icons.point_of_sale, 'تقرير المبيعات',
        'إجمالي المبيعات والأرباح المبسطة', AppColors.success),
    _R(Icons.account_balance_wallet, 'تقرير الصندوق',
        'حركات الصندوق المرحلة', AppColors.warning),
    _R(Icons.inventory, 'تقرير المخزون',
        'الأصناف والكميات وقيمة المخزون', AppColors.info),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('التقارير المالية')),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: reports.length,
          itemBuilder: (_, i) {
            final r = reports[i];
            return Card(
              child: ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: r.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Icon(r.icon, color: r.color),
                ),
                title: Text(r.title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(r.desc, style: const TextStyle(fontSize: 11.5)),
                trailing: const Icon(Icons.chevron_left),
                onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) {
                      switch (i) {
                        case 0:
                          return const TrialBalanceScreen();
                        case 1:
                          return const IncomeStatementScreen();
                        case 2:
                          return const BalanceSheetScreen();
                        case 3:
                          return const SalesReportScreen();
                        case 4:
                          return const CashReportScreen();
                        case 5:
                          return const InventoryReportScreen();
                        default:
                          return const TrialBalanceScreen();
                      }
                    })),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _R {
  final IconData icon;
  final String title;
  final String desc;
  final Color color;
  const _R(this.icon, this.title, this.desc, this.color);
}
