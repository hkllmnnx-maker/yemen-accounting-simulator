import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/formatters.dart';
import '../../providers/accounting_provider.dart';
import '../../providers/progress_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/section_card.dart';
import '../lessons/lessons_screen.dart';
import '../training/training_list_screen.dart';
import '../quizzes/quizzes_list_screen.dart';
import '../progress/progress_screen.dart';
import '../glossary/glossary_screen.dart';
import '../settings/settings_screen.dart';
import '../simulator/simulator_home_screen.dart';
import '../financial_accounting/financial_accounting_home_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final acc = context.watch<AccountingProvider>();
    final progress = context.watch<ProgressProvider>();

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text(AppStrings.dashboard),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () {}),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            // Welcome banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.waving_hand, color: AppColors.gold, size: 20),
                      SizedBox(width: 6),
                      Text(
                        'مرحبًا أيها المحاسب اليمني',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    acc.company.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    '${acc.company.city} • السنة المالية ${acc.company.fiscalYear}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: progress.overallProgress,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation(
                            AppColors.gold,
                          ),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        Formatters.percent(progress.overallProgress),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Quick stats
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.school,
                    label: 'الدروس',
                    value:
                        '${progress.completedLessons}/${progress.totalLessons}',
                    color: AppColors.primary,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LessonsScreen()),
                    ),
                  ),
                ),
                Expanded(
                  child: StatCard(
                    icon: Icons.fitness_center,
                    label: 'تدريبات',
                    value:
                        '${progress.completedTrainings}/${progress.totalTrainings}',
                    color: AppColors.accent,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const TrainingListScreen(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.workspace_premium,
                    label: 'الشارات',
                    value: '${progress.progress.earnedBadges.length}',
                    color: AppColors.gold,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ProgressScreen()),
                    ),
                  ),
                ),
                Expanded(
                  child: StatCard(
                    icon: Icons.star,
                    label: 'نقاط الخبرة',
                    value: '${progress.progress.totalXp} XP',
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const _SectionTitle(title: 'الأقسام التعليمية'),
            const SizedBox(height: 8),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              childAspectRatio: 0.95,
              children: [
                SectionCard(
                  icon: Icons.school,
                  title: AppStrings.lessons,
                  color: AppColors.primary,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LessonsScreen()),
                  ),
                ),
                SectionCard(
                  icon: Icons.account_balance_wallet,
                  title: AppStrings.faShortName,
                  subtitle: 'من القيد إلى التحليل',
                  color: AppColors.equity,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const FinancialAccountingHomeScreen(),
                    ),
                  ),
                ),
                SectionCard(
                  icon: Icons.fitness_center,
                  title: AppStrings.training,
                  color: AppColors.accent,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const TrainingListScreen(),
                    ),
                  ),
                ),
                SectionCard(
                  icon: Icons.computer,
                  title: AppStrings.simulator,
                  color: AppColors.success,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SimulatorHomeScreen(),
                    ),
                  ),
                ),
                SectionCard(
                  icon: Icons.quiz,
                  title: AppStrings.quizzes,
                  color: AppColors.warning,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const QuizzesListScreen(),
                    ),
                  ),
                ),
                SectionCard(
                  icon: Icons.emoji_events,
                  title: AppStrings.progress,
                  color: AppColors.gold,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProgressScreen()),
                  ),
                ),
                SectionCard(
                  icon: Icons.menu_book,
                  title: AppStrings.glossary,
                  color: AppColors.info,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const GlossaryScreen()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const _SectionTitle(title: 'النظام المحاسبي'),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    const Text(
                      'ادخل إلى المحاكاة المحاسبية الكاملة وتدرّب كأنك تستخدم نظامًا محاسبيًا حقيقيًا',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.computer),
                        label: const Text('فتح النظام المحاسبي التدريبي'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SimulatorHomeScreen(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const _SectionTitle(title: 'إعدادات وأدوات'),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.settings,
                      color: AppColors.primary,
                    ),
                    title: const Text(AppStrings.settings),
                    trailing: const Icon(Icons.chevron_left),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
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
