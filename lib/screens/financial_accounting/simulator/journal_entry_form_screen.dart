import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/financial_accounting/financial_exercise.dart';
import '../../../data/models/financial_accounting/journal_entry_answer.dart';
import '../../../providers/financial_accounting_provider.dart';
import '../widgets/journal_entry_editor.dart';

/// شاشة إدخال قيد جديد في يومية المحاكاة.
class JournalEntryFormScreen extends StatefulWidget {
  const JournalEntryFormScreen({super.key});

  @override
  State<JournalEntryFormScreen> createState() =>
      _JournalEntryFormScreenState();
}

class _JournalEntryFormScreenState extends State<JournalEntryFormScreen> {
  final _descriptionCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  final List<JournalLineDraft> _lines = [];

  @override
  void initState() {
    super.initState();
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

  Future<void> _save() async {
    final fa = context.read<FinancialAccountingProvider>();
    final lines = _lines
        .map((l) => l.toFinLine())
        .whereType<FinJournalLine>()
        .toList();
    final entry = JournalEntryAnswer(
      date: _date,
      description: _descriptionCtrl.text.trim(),
      lines: lines,
    );
    final err = fa.addSimEntry(entry);
    if (err != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          content: Text(err),
        ),
      );
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.success,
        content: Text('تم حفظ القيد بنجاح في يومية المحاكاة.'),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('قيد يومية جديد'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: AppColors.info.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline,
                      color: AppColors.info, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'لا يُسمح بحفظ القيد إلا إذا كان متوازنًا (مجموع المدين = مجموع الدائن).',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.info),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: _pickDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'تاريخ القيد',
                          border: OutlineInputBorder(),
                          isDense: true,
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(Formatters.date(_date),
                            style: const TextStyle(fontSize: 13)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _descriptionCtrl,
                      decoration: const InputDecoration(
                        labelText: 'البيان',
                        hintText: 'مثل: شراء بضاعة نقدًا',
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
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text('حفظ القيد'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
