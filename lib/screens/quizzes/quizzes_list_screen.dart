import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../data/seed/lessons_content.dart';
import '../../providers/progress_provider.dart';
import '../../widgets/section_card.dart';
import 'quiz_screen.dart';

/// شاشة قائمة الاختبارات - كل درس له اختبار.
class QuizzesListScreen extends StatelessWidget {
  const QuizzesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressProvider>();
    final passedCount = appLessons
        .where((l) => progress.isQuizPassed(l.id))
        .length;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.quizzes)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 24),
          children: [
            // بانر علوي
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    AppColors.warning,
                    AppColors.warning.withValues(alpha: 0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.quiz_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'اختبر معلوماتك',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'أسئلة قصيرة بعد كل درس - النجاح من 70% فأكثر',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$passedCount/${appLessons.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'مجتاز',
                        style: TextStyle(color: Colors.white70, fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const SectionHeader(
              title: 'الاختبارات المتاحة',
              icon: Icons.fact_check_rounded,
            ),
            const SizedBox(height: 6),
            ...List.generate(appLessons.length, (i) {
              final l = appLessons[i];
              final score = progress.quizScore(l.id);
              final passed = progress.isQuizPassed(l.id);
              final attempted = score > 0;
              return _QuizCard(
                index: i + 1,
                title: l.title,
                questionsCount: l.quiz.length,
                score: score,
                attempted: attempted,
                passed: passed,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => QuizScreen(lesson: l)),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _QuizCard extends StatelessWidget {
  final int index;
  final String title;
  final int questionsCount;
  final int score;
  final bool attempted;
  final bool passed;
  final VoidCallback onTap;

  const _QuizCard({
    required this.index,
    required this.title,
    required this.questionsCount,
    required this.score,
    required this.attempted,
    required this.passed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = passed
        ? AppColors.success
        : (attempted ? AppColors.warning : AppColors.primary);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.15)),
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
                    colors: [
                      color.withValues(alpha: 0.18),
                      color.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: passed
                    ? const Icon(
                        Icons.check_rounded,
                        color: AppColors.success,
                        size: 26,
                      )
                    : Icon(Icons.quiz_rounded, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
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
                              Icons.help_outline_rounded,
                              size: 12,
                              color: AppColors.textLight,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '$questionsCount أسئلة',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        if (attempted)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: color.withValues(alpha: 0.25),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  passed
                                      ? Icons.workspace_premium_rounded
                                      : Icons.warning_amber_rounded,
                                  size: 11,
                                  color: color,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  '$score%',
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'لم يبدأ بعد',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
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
