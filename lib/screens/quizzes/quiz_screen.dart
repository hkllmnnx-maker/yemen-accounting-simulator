import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/seed/lessons_content.dart';
import '../../providers/progress_provider.dart';

class QuizScreen extends StatefulWidget {
  final LessonContent lesson;
  const QuizScreen({super.key, required this.lesson});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _index = 0;
  int? _selected;
  final Map<int, int> _answers = {}; // questionIndex -> selected
  bool _showAnswer = false;
  bool _finished = false;

  void _next() {
    if (_selected == null) return;
    _answers[_index] = _selected!;
    setState(() => _showAnswer = true);
  }

  void _continue() {
    if (_index < widget.lesson.quiz.length - 1) {
      setState(() {
        _index++;
        _selected = null;
        _showAnswer = false;
      });
    } else {
      setState(() => _finished = true);
      _saveScore();
    }
  }

  void _saveScore() {
    int correct = 0;
    for (int i = 0; i < widget.lesson.quiz.length; i++) {
      if (_answers[i] == widget.lesson.quiz[i].correctIndex) correct++;
    }
    final percent = (correct * 100 ~/ widget.lesson.quiz.length);
    context.read<ProgressProvider>().setQuizScore(widget.lesson.id, percent);
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) return _resultPage();
    final q = widget.lesson.quiz[_index];
    final isCorrect = _selected == q.correctIndex;

    return Scaffold(
      appBar: AppBar(
        title: Text('اختبار: ${widget.lesson.title}'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress
            LinearProgressIndicator(
              value: (_index + 1) / widget.lesson.quiz.length,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                'سؤال ${_index + 1} من ${widget.lesson.quiz.length}',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      q.question,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(q.options.length, (i) {
                    Color bg = Colors.white;
                    Color border = AppColors.border;
                    if (_showAnswer) {
                      if (i == q.correctIndex) {
                        bg = AppColors.successLight;
                        border = AppColors.success;
                      } else if (i == _selected && i != q.correctIndex) {
                        bg = AppColors.errorLight;
                        border = AppColors.error;
                      }
                    } else if (_selected == i) {
                      border = AppColors.primary;
                      bg = AppColors.primary.withValues(alpha: 0.05);
                    }
                    return GestureDetector(
                      onTap: _showAnswer
                          ? null
                          : () => setState(() => _selected = i),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: bg,
                          border: Border.all(color: border, width: 1.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: _selected == i
                                    ? AppColors.primary
                                    : Colors.white,
                                border: Border.all(
                                    color: _selected == i
                                        ? AppColors.primary
                                        : AppColors.border),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: _selected == i
                                  ? const Icon(Icons.check,
                                      color: Colors.white, size: 16)
                                  : null,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                q.options[i],
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            if (_showAnswer && i == q.correctIndex)
                              const Icon(Icons.check_circle,
                                  color: AppColors.success),
                            if (_showAnswer && i == _selected && i != q.correctIndex)
                              const Icon(Icons.cancel, color: AppColors.error),
                          ],
                        ),
                      ),
                    );
                  }),
                  if (_showAnswer)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isCorrect
                            ? AppColors.successLight
                            : AppColors.warningLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            isCorrect ? Icons.check_circle : Icons.info,
                            color: isCorrect
                                ? AppColors.success
                                : AppColors.warning,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isCorrect ? 'إجابة صحيحة!' : 'إجابة خاطئة',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isCorrect
                                        ? AppColors.success
                                        : AppColors.warning,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  q.explanation,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      height: 1.5,
                                      color: AppColors.textPrimary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _showAnswer
                      ? _continue
                      : (_selected == null ? null : _next),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(_showAnswer
                      ? (_index < widget.lesson.quiz.length - 1
                          ? 'السؤال التالي'
                          : 'النتيجة')
                      : 'تأكيد الإجابة'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultPage() {
    int correct = 0;
    for (int i = 0; i < widget.lesson.quiz.length; i++) {
      if (_answers[i] == widget.lesson.quiz[i].correctIndex) correct++;
    }
    final percent = (correct * 100 ~/ widget.lesson.quiz.length);
    final passed = percent >= 70;

    return Scaffold(
      appBar: AppBar(title: const Text('نتيجة الاختبار')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                passed ? Icons.celebration : Icons.psychology,
                size: 100,
                color: passed ? AppColors.success : AppColors.warning,
              ),
              const SizedBox(height: 16),
              Text(
                passed ? 'أحسنت! نجحت في الاختبار' : 'حاول مرة أخرى!',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$correct من ${widget.lesson.quiz.length} إجابات صحيحة',
                style: const TextStyle(
                    fontSize: 16, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  color: passed
                      ? AppColors.success.withValues(alpha: 0.15)
                      : AppColors.warning.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$percent%',
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    color: passed ? AppColors.success : AppColors.warning,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('العودة'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => setState(() {
                    _index = 0;
                    _selected = null;
                    _showAnswer = false;
                    _finished = false;
                    _answers.clear();
                  }),
                  child: const Text('إعادة الاختبار'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
