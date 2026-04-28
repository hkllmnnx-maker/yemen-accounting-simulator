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
import 'thumbnails/section_thumbnails.dart';

/// قائمة جانبية شبيهة بالأنظمة المحاسبية اليمنية - مع صور مصغّرة احترافية.
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
                      const SectionThumbnail(
                        kind: ThumbnailKind.financialAccounting,
                        color: Colors.white,
                        size: 48,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          AppStrings.appName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            height: 1.25,
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
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.business_rounded,
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
            const SizedBox(height: 6),
            _drawerItem(
              context,
              ThumbnailKind.simulator,
              AppColors.primary,
              AppStrings.dashboard,
              const DashboardScreen(),
              replaceRoot: true,
            ),
            _drawerItem(
              context,
              ThumbnailKind.lessons,
              AppColors.primary,
              AppStrings.lessons,
              const LessonsScreen(),
            ),
            _drawerItem(
              context,
              ThumbnailKind.financialAccounting,
              AppColors.equity,
              AppStrings.faShortName,
              const FinancialAccountingHomeScreen(),
            ),
            _drawerItem(
              context,
              ThumbnailKind.training,
              AppColors.accent,
              AppStrings.training,
              const TrainingListScreen(),
            ),
            _drawerItem(
              context,
              ThumbnailKind.simulator,
              AppColors.success,
              AppStrings.simulator,
              const SimulatorHomeScreen(),
            ),
            _drawerItem(
              context,
              ThumbnailKind.quiz,
              AppColors.warning,
              AppStrings.quizzes,
              const QuizzesListScreen(),
            ),
            _drawerItem(
              context,
              ThumbnailKind.progress,
              AppColors.gold,
              AppStrings.progress,
              const ProgressScreen(),
            ),
            _drawerItem(
              context,
              ThumbnailKind.glossary,
              AppColors.info,
              AppStrings.glossary,
              const GlossaryScreen(),
            ),
            const Divider(color: Colors.white24, height: 24),
            _drawerItem(
              context,
              ThumbnailKind.settings,
              AppColors.silver,
              AppStrings.settings,
              const SettingsScreen(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context,
    ThumbnailKind kind,
    Color color,
    String title,
    Widget page, {
    bool replaceRoot = false,
  }) {
    return ListTile(
      leading: SectionThumbnail(kind: kind, color: color, size: 38),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
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
