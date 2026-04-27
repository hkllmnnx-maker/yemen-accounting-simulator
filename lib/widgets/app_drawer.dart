import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../providers/accounting_provider.dart';
import '../providers/progress_provider.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/lessons/lessons_screen.dart';
import '../screens/training/training_list_screen.dart';
import '../screens/quizzes/quizzes_list_screen.dart';
import '../screens/progress/progress_screen.dart';
import '../screens/glossary/glossary_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/simulator/simulator_home_screen.dart';
import '../screens/financial_accounting/financial_accounting_home_screen.dart';

/// قائمة جانبية شبيهة بالأنظمة المحاسبية اليمنية
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final company = context.watch<AccountingProvider>().company;
    final progress = context.watch<ProgressProvider>();
    return Drawer(
      child: Container(
        color: AppColors.sidebar,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.account_balance,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          AppStrings.appName,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.business,
                          color: Colors.white70,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            company.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Text(
                          '${progress.progress.totalXp} XP',
                          style: const TextStyle(
                            color: AppColors.gold,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _drawerItem(
              context,
              Icons.dashboard,
              AppStrings.dashboard,
              const DashboardScreen(),
              replaceRoot: true,
            ),
            _drawerItem(
              context,
              Icons.school,
              AppStrings.lessons,
              const LessonsScreen(),
            ),
            _drawerItem(
              context,
              Icons.account_balance_wallet,
              AppStrings.faShortName,
              const FinancialAccountingHomeScreen(),
            ),
            _drawerItem(
              context,
              Icons.fitness_center,
              AppStrings.training,
              const TrainingListScreen(),
            ),
            _drawerItem(
              context,
              Icons.computer,
              AppStrings.simulator,
              const SimulatorHomeScreen(),
            ),
            _drawerItem(
              context,
              Icons.quiz,
              AppStrings.quizzes,
              const QuizzesListScreen(),
            ),
            _drawerItem(
              context,
              Icons.emoji_events,
              AppStrings.progress,
              const ProgressScreen(),
            ),
            _drawerItem(
              context,
              Icons.menu_book,
              AppStrings.glossary,
              const GlossaryScreen(),
            ),
            const Divider(color: Colors.white24, height: 24),
            _drawerItem(
              context,
              Icons.settings,
              AppStrings.settings,
              const SettingsScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context,
    IconData icon,
    String title,
    Widget page, {
    bool replaceRoot = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
      onTap: () {
        Navigator.of(context).pop();
        if (replaceRoot) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => page),
            (r) => false,
          );
        } else {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
        }
      },
    );
  }
}
