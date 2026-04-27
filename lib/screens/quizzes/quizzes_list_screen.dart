import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../data/seed/lessons_content.dart';
import '../../providers/progress_provider.dart';
import 'quiz_screen.dart';

class QuizzesListScreen extends StatelessWidget {
  const QuizzesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.quizzes)),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: appLessons.length,
          itemBuilder: (_, i) {
            final l = appLessons[i];
            final score = progress.quizScore(l.id);
            final passed = progress.isQuizPassed(l.id);
            return Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: CircleAvatar(
                  backgroundColor: passed
                      ? AppColors.success
                      : AppColors.warning.withValues(alpha: 0.15),
                  foregroundColor: passed ? Colors.white : AppColors.warning,
                  child: Icon(
                    passed ? Icons.check : Icons.quiz,
                    size: 20,
                  ),
                ),
                title: Text(l.title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  '${l.quiz.length} أسئلة • ${score == 0 ? 'لم يبدأ' : 'أعلى نتيجة: $score%'}',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: const Icon(Icons.chevron_left),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => QuizScreen(lesson: l))),
              ),
            );
          },
        ),
      ),
    );
  }
}
