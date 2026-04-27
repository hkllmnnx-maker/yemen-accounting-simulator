import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/financial_accounting/financial_lesson.dart';
import '../../providers/financial_accounting_provider.dart';
import '../../providers/progress_provider.dart';
import 'journal_practice_screen.dart';

/// شاشة مستوى تعليمي داخل قسم المحاسبة المالية.
///
/// تعرض الشرح، الأمثلة المحلولة، الأخطاء الشائعة، التلميحات،
/// قائمة التمارين، وتسمح بإكمال المستوى.
class FinancialLevelScreen extends StatelessWidget {
  final FinancialLesson lesson;
  const FinancialLevelScreen({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    final fa = context.watch<FinancialAccountingProvider>();
    final exercises = fa.exercisesOf(lesson.id);
    final completed = fa.isLessonCompleted(lesson.id);
    final progress = fa.lessonProgress(lesson.id);

    return Scaffold(
      appBar: AppBar(
        title: Text('المستوى ${lesson.order}: ${lesson.title}'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            // ============== Header ==============
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: completed
                      ? const [AppColors.success, Color(0xFF1B5E20)]
                      : const [AppColors.primary, AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${lesson.order}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          lesson.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    lesson.subtitle,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 12.5),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Colors.white24,
                    valueColor:
                        const AlwaysStoppedAnimation(AppColors.gold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'الإنجاز: ${Formatters.percent(progress)} • '
                    '${lesson.xpReward} XP',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ============== Summary ==============
            _Card(
              icon: Icons.menu_book,
              color: AppColors.primary,
              title: 'ملخّص المستوى',
              child: Text(
                lesson.summary,
                style: const TextStyle(
                    fontSize: 13.5,
                    height: 1.6,
                    color: AppColors.textPrimary),
              ),
            ),

            // ============== Sections ==============
            _Card(
              icon: Icons.school,
              color: AppColors.info,
              title: 'الشرح المفصّل',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < lesson.sections.length; i++) ...[
                    _NumberedParagraph(
                      number: i + 1,
                      text: lesson.sections[i],
                    ),
                    if (i < lesson.sections.length - 1)
                      const SizedBox(height: 8),
                  ],
                ],
              ),
            ),

            // ============== Solved Examples ==============
            if (lesson.solvedExamples.isNotEmpty)
              _Card(
                icon: Icons.lightbulb,
                color: AppColors.gold,
                title: 'أمثلة محلولة',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final ex in lesson.solvedExamples) ...[
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color:
                                  AppColors.gold.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          ex,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.7,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

            // ============== Common Mistakes ==============
            if (lesson.commonMistakes.isNotEmpty)
              _Card(
                icon: Icons.warning_amber_rounded,
                color: AppColors.error,
                title: 'أخطاء شائعة احذرها',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final m in lesson.commonMistakes)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.close_rounded,
                                color: AppColors.error, size: 16),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(m,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    height: 1.5,
                                    color: AppColors.textPrimary,
                                  )),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

            // ============== Tips ==============
            if (lesson.tips.isNotEmpty)
              _Card(
                icon: Icons.tips_and_updates,
                color: AppColors.accent,
                title: 'تلميحات مفيدة',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final t in lesson.tips)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.bolt,
                                color: AppColors.accent, size: 16),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(t,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    height: 1.5,
                                    color: AppColors.textPrimary,
                                  )),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

            // ============== Exercises ==============
            if (exercises.isNotEmpty)
              _Card(
                icon: Icons.fitness_center,
                color: AppColors.success,
                title: 'تمارين عملية (${exercises.length})',
                child: Column(
                  children: [
                    for (final ex in exercises) ...[
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: ListTile(
                          leading: Icon(
                            fa.isExerciseCompleted(ex.id)
                                ? Icons.check_circle
                                : Icons.assignment,
                            color: fa.isExerciseCompleted(ex.id)
                                ? AppColors.success
                                : AppColors.primary,
                          ),
                          title: Text(
                            ex.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5),
                          ),
                          subtitle: Text(
                            ex.scenario,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                          trailing: Icon(Icons.chevron_left,
                              color: AppColors.textLight),
                          onTap: () =>
                              Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => JournalPracticeScreen(
                                exercise: ex, lesson: lesson),
                          )),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

            // ============== Wrap-up ==============
            _Card(
              icon: Icons.auto_awesome,
              color: AppColors.equity,
              title: 'ملخص ختامي',
              child: Text(
                lesson.wrapUp,
                style: const TextStyle(
                  fontSize: 13.5,
                  height: 1.6,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            // ============== Mark as completed ==============
            if (!completed)
              ElevatedButton.icon(
                onPressed: () =>
                    _markCompleted(context, fa, lesson),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  padding:
                      const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.check_circle),
                label: Text(
                  'إنهاء المستوى ${lesson.order} والحصول على ${lesson.xpReward} XP',
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color:
                          AppColors.success.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle,
                        color: AppColors.success),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'تم إنهاء هذا المستوى. تابع المستويات التالية لإكمال الرحلة.',
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
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

  Future<void> _markCompleted(BuildContext context,
      FinancialAccountingProvider fa, FinancialLesson lesson) async {
    final progress = context.read<ProgressProvider>();
    await fa.markLessonCompleted(lesson.id);
    // أضِف XP وشارة عبر ProgressProvider الذي يحفظ تلقائيًا.
    if (lesson.badgeId != null) {
      await progress.awardBadge(lesson.badgeId!);
    }
    // إكمال المستوى نسجّله بمعرّف كدرس عام لإضافة XP.
    await progress.completeLesson('fa_${lesson.id}');
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.success,
        content: Text(
          'تم إنهاء المستوى! حصلت على XP'
          '${lesson.badgeId != null ? ' وشارة جديدة' : ''}.',
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final Widget child;

  const _Card({
    required this.icon,
    required this.color,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 18),
            child,
          ],
        ),
      ),
    );
  }
}

class _NumberedParagraph extends StatelessWidget {
  final int number;
  final String text;
  const _NumberedParagraph({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Text(
            '$number',
            style: const TextStyle(
              color: AppColors.info,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
