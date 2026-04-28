import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/formatters.dart';
import '../../providers/accounting_provider.dart';
import '../../providers/progress_provider.dart';
import '../../providers/financial_accounting_provider.dart';
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

/// لوحة تحكم رئيسية - النقطة الأولى التي يدخلها المحاسب المتدرب.
/// تعرض ترحيبًا، تقدمًا عامًا، إحصائيات سريعة، والأقسام الرئيسية.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final acc = context.watch<AccountingProvider>();
    final progress = context.watch<ProgressProvider>();
    final fa = context.watch<FinancialAccountingProvider>();

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text(AppStrings.dashboard),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            tooltip: 'بحث في القاموس',
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const GlossaryScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: AppStrings.settings,
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // عمود الأقسام: 2 على الشاشات الضيقة، 3 على المتوسطة، 4 على الواسعة
            final w = constraints.maxWidth;
            final crossAxisCount = w < 360
                ? 2
                : w < 600
                ? 3
                : w < 900
                ? 4
                : 5;

            return ListView(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
              children: [
                _WelcomeBanner(
                  companyName: acc.company.name,
                  city: acc.company.city,
                  fiscalYear: acc.company.fiscalYear,
                  overallProgress: progress.overallProgress,
                  totalXp: progress.progress.totalXp,
                ),
                const SizedBox(height: 14),

                // إحصائيات سريعة - في صف يلتف عند الحاجة
                _QuickStats(progress: progress, faProgress: fa.sectionProgress),

                const SizedBox(height: 16),
                const SectionHeader(
                  title: 'الأقسام التعليمية',
                  subtitle: 'كل ما تحتاجه لتعلّم المحاسبة من الصفر',
                  icon: Icons.school_rounded,
                ),
                const SizedBox(height: 8),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 0.95,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  children: [
                    SectionCard(
                      icon: Icons.menu_book_rounded,
                      title: AppStrings.lessons,
                      subtitle: 'دروس مختصرة',
                      color: AppColors.primary,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const LessonsScreen(),
                        ),
                      ),
                    ),
                    SectionCard(
                      icon: Icons.account_balance_wallet_rounded,
                      title: AppStrings.faShortName,
                      subtitle: '14 مستوى متدرّج',
                      color: AppColors.equity,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const FinancialAccountingHomeScreen(),
                        ),
                      ),
                    ),
                    SectionCard(
                      icon: Icons.fitness_center_rounded,
                      title: AppStrings.training,
                      subtitle: 'سيناريوهات حقيقية',
                      color: AppColors.accent,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const TrainingListScreen(),
                        ),
                      ),
                    ),
                    SectionCard(
                      icon: Icons.computer_rounded,
                      title: AppStrings.simulator,
                      subtitle: 'نظام محاسبي حقيقي',
                      color: AppColors.success,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SimulatorHomeScreen(),
                        ),
                      ),
                    ),
                    SectionCard(
                      icon: Icons.quiz_rounded,
                      title: AppStrings.quizzes,
                      subtitle: 'اختبر معلوماتك',
                      color: AppColors.warning,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const QuizzesListScreen(),
                        ),
                      ),
                    ),
                    SectionCard(
                      icon: Icons.emoji_events_rounded,
                      title: AppStrings.progress,
                      subtitle: 'الشارات والإنجازات',
                      color: AppColors.gold,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ProgressScreen(),
                        ),
                      ),
                    ),
                    SectionCard(
                      icon: Icons.library_books_rounded,
                      title: AppStrings.glossary,
                      subtitle: 'مصطلحات محاسبية',
                      color: AppColors.info,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const GlossaryScreen(),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),
                const SectionHeader(
                  title: 'النظام المحاسبي التدريبي',
                  subtitle: 'تدرّب كأنك تستخدم برنامجًا محاسبيًا حقيقيًا',
                  icon: Icons.computer_rounded,
                  color: AppColors.success,
                ),
                const SizedBox(height: 8),
                _SimulatorBigButton(
                  cashBalance: acc.accountBalance('a1111'),
                  receivables: acc.customers.fold<double>(
                    0,
                    (s, p) => s + acc.partnerBalance(p.id),
                  ),
                  itemsCount: acc.items.length,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SimulatorHomeScreen(),
                    ),
                  ),
                ),

                const SizedBox(height: 18),
                const SectionHeader(
                  title: 'إعدادات وأدوات',
                  icon: Icons.tune_rounded,
                ),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      _DashTile(
                        icon: Icons.settings_outlined,
                        color: AppColors.primary,
                        title: AppStrings.settings,
                        subtitle: 'تخصيص اسم الشركة، السنة المالية وغيرها',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SettingsScreen(),
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      _DashTile(
                        icon: Icons.info_outline_rounded,
                        color: AppColors.info,
                        title: 'عن التطبيق',
                        subtitle: AppStrings.appTagline,
                        onTap: () => _showAboutDialog(context),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppStrings.appName,
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(
          Icons.account_balance_rounded,
          color: Colors.white,
          size: 32,
        ),
      ),
      applicationLegalese: 'تطبيق تعليمي مجاني للمحاسبين المبتدئين في اليمن.',
      children: [
        const SizedBox(height: 12),
        const Text(AppStrings.appDescription, style: TextStyle(height: 1.6)),
      ],
    );
  }
}

class _WelcomeBanner extends StatelessWidget {
  final String companyName;
  final String city;
  final int fiscalYear;
  final double overallProgress;
  final int totalXp;

  const _WelcomeBanner({
    required this.companyName,
    required this.city,
    required this.fiscalYear,
    required this.overallProgress,
    required this.totalXp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.waving_hand_rounded,
                  color: AppColors.gold,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'أهلًا بك أيها المحاسب اليمني',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.6),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: AppColors.gold,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '$totalXp XP',
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            companyName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 19,
            ),
          ),
          Text(
            '$city • السنة المالية $fiscalYear',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(
                Icons.trending_up_rounded,
                color: AppColors.gold,
                size: 16,
              ),
              const SizedBox(width: 4),
              const Text(
                'تقدمك العام',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const Spacer(),
              Text(
                Formatters.percent(overallProgress),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: overallProgress.clamp(0.0, 1.0),
              backgroundColor: Colors.white.withValues(alpha: 0.18),
              valueColor: const AlwaysStoppedAnimation(AppColors.gold),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStats extends StatelessWidget {
  final ProgressProvider progress;
  final double faProgress;

  const _QuickStats({required this.progress, required this.faProgress});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final isWide = c.maxWidth >= 600;
        final crossAxisCount = isWide ? 4 : 2;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          childAspectRatio: isWide ? 2.4 : 2.1,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          children: [
            StatCard(
              icon: Icons.school_rounded,
              label: 'الدروس',
              value: '${progress.completedLessons}/${progress.totalLessons}',
              color: AppColors.primary,
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const LessonsScreen())),
            ),
            StatCard(
              icon: Icons.fitness_center_rounded,
              label: 'تدريبات',
              value:
                  '${progress.completedTrainings}/${progress.totalTrainings}',
              color: AppColors.accent,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TrainingListScreen()),
              ),
            ),
            StatCard(
              icon: Icons.workspace_premium_rounded,
              label: 'الشارات',
              value: '${progress.progress.earnedBadges.length}',
              color: AppColors.gold,
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const ProgressScreen())),
            ),
            StatCard(
              icon: Icons.account_balance_wallet_rounded,
              label: 'المحاسبة المالية',
              value: Formatters.percent(faProgress),
              color: AppColors.equity,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const FinancialAccountingHomeScreen(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SimulatorBigButton extends StatelessWidget {
  final double cashBalance;
  final double receivables;
  final int itemsCount;
  final VoidCallback onTap;

  const _SimulatorBigButton({
    required this.cashBalance,
    required this.receivables,
    required this.itemsCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                AppColors.success.withValues(alpha: 0.10),
                AppColors.accent.withValues(alpha: 0.05),
              ],
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.computer_rounded,
                      color: AppColors.success,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'فتح النظام المحاسبي',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'قيود يومية، عملاء، موردين، فواتير، تقارير',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textSecondary,
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
              const SizedBox(height: 12),
              // ملخص سريع للنظام المحاسبي
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MiniInfo(
                    icon: Icons.account_balance_wallet_rounded,
                    label: 'الصندوق',
                    value: Formatters.currency(cashBalance),
                    color: AppColors.success,
                  ),
                  _MiniInfo(
                    icon: Icons.people_rounded,
                    label: 'مديونية العملاء',
                    value: Formatters.currency(receivables),
                    color: AppColors.primary,
                  ),
                  _MiniInfo(
                    icon: Icons.inventory_2_rounded,
                    label: 'الأصناف',
                    value: '$itemsCount',
                    color: AppColors.accent,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MiniInfo({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _DashTile({
    required this.icon,
    required this.color,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11.5),
            ),
      trailing: const Icon(
        Icons.arrow_back_ios_rounded,
        size: 14,
        color: AppColors.textLight,
      ),
      onTap: onTap,
    );
  }
}
