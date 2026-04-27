import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/financial_accounting/financial_exercise.dart';
import '../../data/models/financial_accounting/financial_lesson.dart';

/// شاشة تمرين قيد يومية - سيتم تطويرها بالكامل في المهمة التالية.
class JournalPracticeScreen extends StatelessWidget {
  final FinancialExercise exercise;
  final FinancialLesson lesson;

  const JournalPracticeScreen({
    super.key,
    required this.exercise,
    required this.lesson,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(exercise.title)),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'شاشة تمرين القيد - قيد التطوير...',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      ),
    );
  }
}
