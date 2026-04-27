import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/financial_accounting/financial_exercise.dart';
import '../../data/models/financial_accounting/financial_lesson.dart';
import '../../data/models/financial_accounting/journal_entry_answer.dart';
import '../../data/seed/financial_accounts_catalog.dart';
import '../../providers/financial_accounting_provider.dart';
import '../../providers/progress_provider.dart';
import 'widgets/journal_entry_editor.dart';

/// شاشة تمرين عملي على قيد يومية.
///
/// تعرض السيناريو والمطلوب والتلميحات وتسمح للمتدرّب بإدخال أسطر القيد،
/// التحقق من توازنه ومطابقته للحل الصحيح، وعرض الحل التفصيلي.
class JournalPracticeScreen extends StatefulWidget {
  final FinancialExercise exercise;
  final FinancialLesson lesson;

  const JournalPracticeScreen({
    super.key,
    required this.exercise,
    required this.lesson,
  });

  @override
  State<JournalPracticeScreen> createState() => _JournalPracticeScreenState();
}

class _JournalPracticeScreenState extends State<JournalPracticeScreen> {
  final _descriptionCtrl = TextEditingController();
  late DateTime _date;
  final List<JournalLineDraft> _lines = [];
  JournalCheckResult? _result;
  bool _showHints = false;
  bool _solutionRevealed = false;
  int _attempts = 0;

  @override
  void initState() {
    super.initState();
    _date = widget.exercise.operationDate;
    _descriptionCtrl.text = '';
    // ابدأ بسطرين فارغين كنموذج بدائي.
    _lines.add(JournalLineDraft(side: 'debit'));
    _lines.add(JournalLineDraft(side: 'credit'));
  }

  @override
  void dispose() {
    for (final l in _lines) {
      l.dispose();
    }
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('ar'),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  void _check() {
    final fa = context.read<FinancialAccountingProvider>();
    final answer = JournalEntryAnswer(
      date: _date,
      description: _descriptionCtrl.text.trim(),
      lines: _lines
          .map((l) => l.toFinLine())
          .whereType<FinJournalLine>()
          .toList(),
    );
    final res = fa.evaluateAnswer(widget.exercise, answer);
    setState(() {
      _result = res;
      _attempts++;
      if (res.correct && !_solutionRevealed) {
        _solutionRevealed = true;
      }
    });

    if (res.correct) {
      _onSuccess();
    }
  }

  Future<void> _onSuccess() async {
    final fa = context.read<FinancialAccountingProvider>();
    final progress = context.read<ProgressProvider>();
    final wasCompleted = fa.isExerciseCompleted(widget.exercise.id);

    await fa.markExerciseCompleted(widget.exercise.id);

    if (!wasCompleted) {
      // أضِف XP فقط في أول مرة لإنجاز التمرين.
      progress.progress.totalXp += widget.exercise.xpReward;
      // حفظ مباشر عبر إعادة تعيين set مؤقت ليُحفظ.
      await progress.completeLesson('fa_ex_${widget.exercise.id}');
    }
  }

  void _revealSolution() {
    setState(() => _solutionRevealed = true);
  }

  @override
  Widget build(BuildContext context) {
    final ex = widget.exercise;
    final completed = context
        .watch<FinancialAccountingProvider>()
        .isExerciseCompleted(ex.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(ex.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            // ============== Status banner ==============
            if (completed)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.5),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: AppColors.success),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'لقد سبق وأنجزت هذا التمرين بنجاح. يمكنك إعادة المحاولة للتمرّن.',
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // ============== Scenario ==============
            _Section(
              icon: Icons.event_note,
              color: AppColors.primary,
              title: 'السيناريو',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ex.scenario,
                    style: const TextStyle(fontSize: 13, height: 1.7),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'تاريخ العملية: ${Formatters.date(ex.operationDate)}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ============== Operation ==============
            _Section(
              icon: Icons.description,
              color: AppColors.info,
              title: 'وصف العملية',
              child: Text(
                ex.operationText,
                style: const TextStyle(fontSize: 13, height: 1.7),
              ),
            ),

            // ============== Requirement ==============
            _Section(
              icon: Icons.assignment,
              color: AppColors.accent,
              title: 'المطلوب',
              child: Text(
                ex.requirement,
                style: const TextStyle(
                  fontSize: 13.5,
                  height: 1.7,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // ============== Hints ==============
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () => setState(() => _showHints = !_showHints),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.tips_and_updates,
                            color: AppColors.gold,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'تلميحات قبل الحل',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            _showHints ? Icons.expand_less : Icons.expand_more,
                            color: AppColors.textLight,
                          ),
                        ],
                      ),
                    ),
                    if (_showHints) ...[
                      const Divider(),
                      for (final h in ex.hints)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.bolt,
                                size: 14,
                                color: AppColors.gold,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  h,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),

            // ============== Editor ==============
            _Section(
              icon: Icons.edit_note,
              color: AppColors.success,
              title: 'حقول إدخال القيد',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: _pickDate,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'تاريخ القيد',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            child: Text(
                              Formatters.date(_date),
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descriptionCtrl,
                    decoration: const InputDecoration(
                      labelText: 'البيان',
                      hintText: 'وصف مختصر للعملية',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  JournalEntryEditor(
                    lines: _lines,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _check,
                          icon: const Icon(Icons.check),
                          label: const Text('تحقّق من الحل'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: _revealSolution,
                        icon: const Icon(Icons.lightbulb_outline, size: 18),
                        label: const Text('إظهار الحل'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ============== Result ==============
            if (_result != null) _buildResultCard(),

            // ============== Solution ==============
            if (_solutionRevealed) _buildSolutionCard(),

            // ============== Common Mistakes ==============
            if (ex.commonMistakes.isNotEmpty)
              _Section(
                icon: Icons.warning_amber,
                color: AppColors.error,
                title: 'أخطاء شائعة في هذا التمرين',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final m in ex.commonMistakes)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.close,
                              size: 14,
                              color: AppColors.error,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                m,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
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

  Widget _buildResultCard() {
    final r = _result!;
    final color = r.correct
        ? AppColors.success
        : (r.balanced ? AppColors.warning : AppColors.error);
    final bg = r.correct
        ? AppColors.successLight
        : (r.balanced ? AppColors.warningLight : AppColors.errorLight);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                r.correct
                    ? Icons.check_circle
                    : (r.balanced ? Icons.warning_amber_rounded : Icons.error),
                color: color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  r.correct
                      ? 'إجابة صحيحة - أحسنت!'
                      : (r.balanced
                            ? 'القيد متوازن لكن لا يطابق الحل الصحيح'
                            : 'القيد غير متوازن'),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              if (_attempts > 0)
                Text(
                  'محاولات: $_attempts',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            r.message,
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.6,
              color: AppColors.textPrimary,
            ),
          ),
          if (r.issues.isNotEmpty) ...[
            const SizedBox(height: 8),
            for (final issue in r.issues)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.error_outline, size: 14, color: color),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        issue,
                        style: TextStyle(
                          fontSize: 11.5,
                          height: 1.5,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildSolutionCard() {
    final ex = widget.exercise;
    final exp = ex.expected;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.lightbulb, color: AppColors.gold),
              SizedBox(width: 6),
              Text(
                'الحل الصحيح',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'التاريخ: ${Formatters.date(exp.date)}',
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            'البيان: ${exp.description}',
            style: const TextStyle(fontSize: 12),
          ),
          const Divider(),
          // أطراف القيد
          for (final l in exp.lines)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Icon(
                    l.isDebit ? Icons.arrow_back : Icons.arrow_forward,
                    size: 14,
                    color: l.isDebit ? AppColors.debit : AppColors.credit,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${l.isDebit ? 'من ح/' : 'إلى ح/'} '
                      '${FinAccountsCatalog.byId(l.accountId)?.name ?? l.accountId}',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: l.isDebit ? AppColors.debit : AppColors.credit,
                      ),
                    ),
                  ),
                  Text(
                    Formatters.currency(l.amount),
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: l.isDebit ? AppColors.debit : AppColors.credit,
                    ),
                  ),
                ],
              ),
            ),
          const Divider(),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              ex.solutionExplanation,
              style: const TextStyle(fontSize: 12, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final Widget child;

  const _Section({
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
                  child: Icon(icon, color: color, size: 16),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
