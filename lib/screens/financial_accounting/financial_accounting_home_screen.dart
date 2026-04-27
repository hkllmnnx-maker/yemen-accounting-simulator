import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/financial_accounting/financial_lesson.dart';
import '../../data/seed/financial_accounting_content.dart';
import '../../data/seed/financial_exercises_content.dart';
import '../../providers/financial_accounting_provider.dart';
import 'financial_level_screen.dart';
import 'simulator/financial_simulator_screen.dart';

/// الشاشة الرئيسية لقسم "المحاسبة المالية من القيد إلى التحليل المالي".
///
/// تعرض:
/// - بطاقة ترحيب وتقدّم القسم.
/// - زر فتح المحاكاة العملية.
/// - قائمة المستويات الـ14 مع نسبة إنجاز كل واحد.
class FinancialAccountingHomeScreen extends StatelessWidget {
  const FinancialAccountingHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fa = context.watch<FinancialAccountingProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.faSection)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            _buildHeader(context, fa),
            const SizedBox(height: 12),
            _buildSimulatorButton(context),
            const SizedBox(height: 16),
            const _SectionTitle(title: 'المسار التعليمي - 14 مستوى متدرّج'),
            const SizedBox(height: 8),
            ...List.generate(financialLessons.length, (i) {
              final l = financialLessons[i];
              return _LessonTile(lesson: l);
            }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, FinancialAccountingProvider fa) {
    return Container(
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
              Icon(
                Icons.account_balance_wallet,
                color: AppColors.gold,
                size: 22,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppStrings.faSection,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'تدريب عملي للمحاسب المبتدئ في اليمن: من القيد إلى التحليل المالي.',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: fa.sectionProgress,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation(AppColors.gold),
                  minHeight: 8,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                Formatters.percent(fa.sectionProgress),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatChip(
                icon: Icons.layers,
                label:
                    'المستويات: ${fa.completedLessons.length}/${financialLessons.length}',
              ),
              _StatChip(
                icon: Icons.task_alt,
                label:
                    'تمارين: ${fa.completedExercises.length}/${financialExercises.length}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimulatorButton(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.computer, color: AppColors.success),
        ),
        title: const Text(
          'شاشة المحاكاة العملية',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text(
          'أدخل قيود يومية، شاهد دفتر الأستاذ، ميزان المراجعة، '
          'القوائم المالية، والتحليل المالي تلقائيًا.',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        trailing: const Icon(Icons.chevron_left, color: AppColors.textLight),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const FinancialSimulatorScreen()),
        ),
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  final FinancialLesson lesson;
  const _LessonTile({required this.lesson});

  @override
  Widget build(BuildContext context) {
    final fa = context.watch<FinancialAccountingProvider>();
    final progress = fa.lessonProgress(lesson.id);
    final completed = fa.isLessonCompleted(lesson.id);
    final exercisesCount = fa.exercisesOf(lesson.id).length;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => FinancialLevelScreen(lesson: lesson),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: completed
                      ? AppColors.success.withValues(alpha: 0.15)
                      : AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${lesson.order}',
                  style: TextStyle(
                    color: completed ? AppColors.success : AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      lesson.subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'تمارين: $exercisesCount',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${lesson.xpReward} XP',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.gold,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          Formatters.percent(progress),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 4,
                      backgroundColor: AppColors.divider,
                      valueColor: AlwaysStoppedAnimation(
                        completed ? AppColors.success : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              if (completed)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 22,
                )
              else
                const Icon(Icons.chevron_left, color: AppColors.textLight),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
