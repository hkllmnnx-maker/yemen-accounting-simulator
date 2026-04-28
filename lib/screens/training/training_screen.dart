import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/seed/trainings_content.dart';
import '../../providers/progress_provider.dart';

class TrainingScreen extends StatefulWidget {
  final TrainingScenario scenario;
  const TrainingScreen({super.key, required this.scenario});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  int _index = 0;
  String _input = '';
  String? _choice;
  String? _error;
  bool _showHint = false;
  bool _finished = false;
  final TextEditingController _controller = TextEditingController();

  TrainingStep get current => widget.scenario.steps[_index];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _check() {
    setState(() => _error = null);
    final step = current;
    bool ok = false;

    switch (step.type) {
      case 'text':
        ok = _input.trim() == (step.expectedValue ?? '').trim();
        break;
      case 'choice':
        ok = _choice == step.expectedValue;
        break;
      case 'number':
        final v = double.tryParse(_input.replaceAll(',', ''));
        if (v != null && step.expectedNumber != null) {
          final tol = step.tolerance ?? 0.01;
          ok = (v - step.expectedNumber!).abs() <= tol;
        }
        break;
    }

    if (!ok) {
      setState(() => _error = 'الإجابة غير صحيحة. تحقق من الإدخال أو استخدم التلميح.');
      return;
    }

    if (_index < widget.scenario.steps.length - 1) {
      setState(() {
        _index++;
        _input = '';
        _choice = null;
        _showHint = false;
        _error = null;
        _controller.clear();
      });
    } else {
      _finishScenario();
    }
  }

  Future<void> _finishScenario() async {
    final p = context.read<ProgressProvider>();
    await p.completeTraining(widget.scenario.id, widget.scenario.xpReward);
    if (widget.scenario.badgeId != null) {
      await p.awardBadge(widget.scenario.badgeId!);
    }
    setState(() => _finished = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) return _successPage();
    return Scaffold(
      appBar: AppBar(title: const Text('تدريب عملي')),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_index + 1) / widget.scenario.steps.length,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation(AppColors.accent),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    widget.scenario.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'الخطوة ${_index + 1} من ${widget.scenario.steps.length}',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.warningLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.business,
                            color: AppColors.warning, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            widget.scenario.yemeniContext,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textPrimary,
                              height: 1.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      current.instruction,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildInput(),
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.errorLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error,
                              color: AppColors.error, size: 18),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(_error!,
                                style: const TextStyle(
                                    color: AppColors.error, fontSize: 13)),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (_showHint) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.infoLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.lightbulb,
                              color: AppColors.info, size: 18),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(current.hint,
                                style: const TextStyle(
                                    color: AppColors.info,
                                    fontSize: 13,
                                    height: 1.5)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.lightbulb_outline),
                    label: const Text('تلميح'),
                    onPressed: () => setState(() => _showHint = true),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text('تحقّق'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 14),
                      backgroundColor: AppColors.accent,
                    ),
                    onPressed: _check,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput() {
    final step = current;
    if (step.type == 'choice') {
      return Column(
        children: (step.choices ?? []).map((c) {
          final selected = _choice == c;
          return GestureDetector(
            onTap: () => setState(() => _choice = c),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.accent.withValues(alpha: 0.08)
                    : Colors.white,
                border: Border.all(
                  color: selected ? AppColors.accent : AppColors.border,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: selected ? AppColors.accent : AppColors.textLight,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(c,
                        style: const TextStyle(
                            fontSize: 14, color: AppColors.textPrimary)),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    }
    return TextField(
      controller: _controller,
      keyboardType:
          step.type == 'number' ? TextInputType.number : TextInputType.text,
      onChanged: (v) => setState(() => _input = v),
      decoration: InputDecoration(
        hintText:
            step.type == 'number' ? 'أدخل الرقم' : 'اكتب الإجابة هنا',
      ),
    );
  }

  Widget _successPage() {
    return Scaffold(
      appBar: AppBar(title: const Text('تم بنجاح!')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.emoji_events,
                  size: 120, color: AppColors.gold),
              const SizedBox(height: 16),
              const Text(
                'مبروك!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.scenario.successMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: AppColors.gold, size: 32),
                    const SizedBox(width: 8),
                    Text(
                      '+ ${widget.scenario.xpReward} نقطة خبرة',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gold,
                      ),
                    ),
                  ],
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
                  child: const Text('متابعة'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
