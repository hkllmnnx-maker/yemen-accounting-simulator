import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/financial_accounting/financial_exercise.dart';
import '../../../data/seed/financial_accounts_catalog.dart';

/// نموذج بيانات لسطر قيد قابل للتعديل في الواجهة.
class JournalLineDraft {
  String? accountId;
  String side; // 'debit' or 'credit'
  TextEditingController amountCtrl;

  JournalLineDraft({
    this.accountId,
    this.side = 'debit',
    String initialAmount = '',
  }) : amountCtrl = TextEditingController(text: initialAmount);

  double get amount => double.tryParse(amountCtrl.text.trim()) ?? 0;

  FinJournalLine? toFinLine() {
    if (accountId == null || amount <= 0) return null;
    return FinJournalLine(
      accountId: accountId!,
      side: side,
      amount: amount,
    );
  }

  void dispose() => amountCtrl.dispose();
}

/// محرر متعدد الأسطر لقيد يومية محاسبي.
///
/// يعرض:
/// - قائمة أسطر مع: حساب (Dropdown)، طرف (مدين/دائن)، مبلغ.
/// - زر إضافة سطر جديد.
/// - مجاميع المدين/الدائن وحالة التوازن.
class JournalEntryEditor extends StatefulWidget {
  final List<JournalLineDraft> lines;
  final ValueChanged<List<JournalLineDraft>> onChanged;

  const JournalEntryEditor({
    super.key,
    required this.lines,
    required this.onChanged,
  });

  @override
  State<JournalEntryEditor> createState() => _JournalEntryEditorState();
}

class _JournalEntryEditorState extends State<JournalEntryEditor> {
  void _addLine() {
    setState(() {
      widget.lines.add(JournalLineDraft());
      widget.onChanged(widget.lines);
    });
  }

  void _removeLine(int i) {
    setState(() {
      widget.lines[i].dispose();
      widget.lines.removeAt(i);
      widget.onChanged(widget.lines);
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalDebit = widget.lines
        .where((l) => l.side == 'debit')
        .fold<double>(0, (s, l) => s + l.amount);
    final totalCredit = widget.lines
        .where((l) => l.side == 'credit')
        .fold<double>(0, (s, l) => s + l.amount);
    final balanced =
        (totalDebit - totalCredit).abs() < 0.01 && totalDebit > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            children: [
              Expanded(
                  flex: 3,
                  child: Text('الحساب',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12))),
              Expanded(
                  flex: 2,
                  child: Text('الطرف',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12))),
              Expanded(
                  flex: 3,
                  child: Text('المبلغ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12))),
              SizedBox(width: 32),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // Lines
        for (var i = 0; i < widget.lines.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: _LineRow(
              draft: widget.lines[i],
              onChanged: () {
                setState(() {});
                widget.onChanged(widget.lines);
              },
              onRemove: () => _removeLine(i),
            ),
          ),
        const SizedBox(height: 6),
        OutlinedButton.icon(
          onPressed: _addLine,
          icon: const Icon(Icons.add, size: 16),
          label: const Text('إضافة سطر'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
          ),
        ),
        const SizedBox(height: 10),
        // Totals
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: balanced
                ? AppColors.successLight
                : AppColors.errorLight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: balanced ? AppColors.success : AppColors.error,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                      child: Text(
                          'مجموع المدين: ${Formatters.currency(totalDebit)}',
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.debit,
                              fontWeight: FontWeight.bold))),
                  Expanded(
                      child: Text(
                          'مجموع الدائن: ${Formatters.currency(totalCredit)}',
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.credit,
                              fontWeight: FontWeight.bold))),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    balanced ? Icons.check_circle : Icons.error,
                    size: 16,
                    color: balanced
                        ? AppColors.success
                        : AppColors.error,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    balanced
                        ? 'القيد متوازن'
                        : 'القيد غير متوازن',
                    style: TextStyle(
                      color: balanced
                          ? AppColors.success
                          : AppColors.error,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LineRow extends StatelessWidget {
  final JournalLineDraft draft;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  const _LineRow({
    required this.draft,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final accounts = FinAccountsCatalog.sorted;
    return Row(
      children: [
        // Account dropdown
        Expanded(
          flex: 3,
          child: DropdownButtonFormField<String>(
            initialValue: draft.accountId,
            isExpanded: true,
            decoration: const InputDecoration(
              isDense: true,
              hintText: 'اختر الحساب',
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              border: OutlineInputBorder(),
            ),
            items: [
              for (final a in accounts)
                DropdownMenuItem(
                  value: a.id,
                  child: Text(
                    a.name,
                    style: const TextStyle(fontSize: 11.5),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: (v) {
              draft.accountId = v;
              onChanged();
            },
          ),
        ),
        const SizedBox(width: 4),
        // Side toggle
        Expanded(
          flex: 2,
          child: SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: 'debit',
                label: Text('مدين',
                    style: TextStyle(fontSize: 10.5)),
              ),
              ButtonSegment(
                value: 'credit',
                label: Text('دائن',
                    style: TextStyle(fontSize: 10.5)),
              ),
            ],
            selected: {draft.side},
            onSelectionChanged: (s) {
              draft.side = s.first;
              onChanged();
            },
            showSelectedIcon: false,
            style: ButtonStyle(
              padding: WidgetStateProperty.all(
                  const EdgeInsets.symmetric(
                      horizontal: 4, vertical: 6)),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
        ),
        const SizedBox(width: 4),
        // Amount
        Expanded(
          flex: 3,
          child: TextField(
            controller: draft.amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(
                decimal: true),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
            decoration: const InputDecoration(
              hintText: '0',
              isDense: true,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => onChanged(),
          ),
        ),
        IconButton(
          onPressed: onRemove,
          icon: const Icon(Icons.close, size: 16),
          color: AppColors.error,
          tooltip: 'حذف السطر',
          padding: EdgeInsets.zero,
          constraints:
              const BoxConstraints(minWidth: 28, minHeight: 28),
        ),
      ],
    );
  }
}
