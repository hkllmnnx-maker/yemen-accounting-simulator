import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/account.dart';
import '../../../data/models/journal_entry.dart';
import '../../../providers/accounting_provider.dart';

class JournalEditScreen extends StatefulWidget {
  final String? journalId;
  const JournalEditScreen({super.key, this.journalId});

  @override
  State<JournalEditScreen> createState() => _JournalEditScreenState();
}

class _JournalEditScreenState extends State<JournalEditScreen> {
  late JournalEntry _entry;
  bool _isNew = false;

  @override
  void initState() {
    super.initState();
    final acc = context.read<AccountingProvider>();
    if (widget.journalId != null) {
      _entry = acc.journalById(widget.journalId!) ?? _newEntry();
    } else {
      _isNew = true;
      _entry = _newEntry();
    }
  }

  JournalEntry _newEntry() {
    return JournalEntry(
      id: 'je_${DateTime.now().millisecondsSinceEpoch}',
      number: 0,
      date: DateTime.now(),
      description: '',
      lines: [
        JournalLine(accountId: '', accountName: ''),
        JournalLine(accountId: '', accountName: ''),
      ],
    );
  }

  Future<void> _save({bool post = false}) async {
    final acc = context.read<AccountingProvider>();
    if (_entry.description.trim().isEmpty) {
      _err('أدخل البيان أولًا');
      return;
    }
    final cleanedLines = _entry.lines
        .where((l) =>
            l.accountId.isNotEmpty && (l.debit > 0 || l.credit > 0))
        .toList();
    if (cleanedLines.length < 2) {
      _err('يجب إدخال سطرين على الأقل');
      return;
    }
    _entry.lines = cleanedLines;
    if (!_entry.isBalanced) {
      _err(
          'القيد غير متوازن! المدين: ${Formatters.currency(_entry.totalDebit, decimals: 0)} والدائن: ${Formatters.currency(_entry.totalCredit, decimals: 0)}');
      return;
    }
    if (post) _entry.posted = true;
    await acc.addJournal(_entry);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(post ? 'تم الترحيل' : 'تم الحفظ')),
    );
    Navigator.pop(context);
  }

  void _err(String s) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(s),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final acc = context.watch<AccountingProvider>();
    final postable = acc.postableAccounts;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? 'قيد جديد' : 'قيد رقم ${_entry.number}'),
        actions: [
          if (!_isNew && !_entry.posted)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                await acc.deleteJournal(_entry.id);
                if (mounted) Navigator.pop(context);
              },
            ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: _isNew || !_entry.posted
                                ? () async {
                                    final d = await showDatePicker(
                                      context: context,
                                      initialDate: _entry.date,
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime(2030),
                                    );
                                    if (d != null) {
                                      setState(() => _entry.date = d);
                                    }
                                  }
                                : null,
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'التاريخ',
                                prefixIcon: Icon(Icons.calendar_today, size: 18),
                              ),
                              child: Text(Formatters.date(_entry.date)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: _entry.posted
                                ? AppColors.successLight
                                : AppColors.warningLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _entry.posted ? 'مرحّل' : 'مؤقت',
                            style: TextStyle(
                              color: _entry.posted
                                  ? AppColors.success
                                  : AppColors.warning,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: TextEditingController(text: _entry.description),
                      enabled: _isNew || !_entry.posted,
                      decoration: const InputDecoration(
                        labelText: 'بيان القيد',
                        prefixIcon: Icon(Icons.description, size: 18),
                      ),
                      onChanged: (v) => _entry.description = v,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: Text(
                'سطور القيد',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            ..._entry.lines.asMap().entries.map((e) {
              final i = e.key;
              final l = e.value;
              return _LineCard(
                index: i,
                line: l,
                postable: postable,
                enabled: _isNew || !_entry.posted,
                onChanged: () => setState(() {}),
                onRemove: _entry.lines.length > 2
                    ? () => setState(() => _entry.lines.removeAt(i))
                    : null,
              );
            }),
            if (_isNew || !_entry.posted)
              TextButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('إضافة سطر'),
                onPressed: () => setState(() => _entry.lines.add(
                    JournalLine(accountId: '', accountName: ''))),
              ),
            const SizedBox(height: 8),
            Card(
              color: AppColors.background,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          const Text('إجمالي المدين',
                              style: TextStyle(fontSize: 12)),
                          Text(
                              Formatters.currency(_entry.totalDebit,
                                  decimals: 0),
                              style: const TextStyle(
                                  color: AppColors.debit,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Container(
                        width: 1, height: 30, color: AppColors.border),
                    Expanded(
                      child: Column(
                        children: [
                          const Text('إجمالي الدائن',
                              style: TextStyle(fontSize: 12)),
                          Text(
                              Formatters.currency(_entry.totalCredit,
                                  decimals: 0),
                              style: const TextStyle(
                                  color: AppColors.credit,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Container(
                        width: 1, height: 30, color: AppColors.border),
                    Expanded(
                      child: Column(
                        children: [
                          const Text('الفرق',
                              style: TextStyle(fontSize: 12)),
                          Text(
                            Formatters.currency(
                                (_entry.totalDebit - _entry.totalCredit).abs(),
                                decimals: 0),
                            style: TextStyle(
                              color: _entry.isBalanced
                                  ? AppColors.success
                                  : AppColors.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_isNew || !_entry.posted)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text('حفظ مؤقت'),
                      onPressed: () => _save(post: false),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check),
                      label: const Text('ترحيل'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success),
                      onPressed: () => _save(post: true),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _LineCard extends StatelessWidget {
  final int index;
  final JournalLine line;
  final List<Account> postable;
  final bool enabled;
  final VoidCallback onChanged;
  final VoidCallback? onRemove;

  const _LineCard({
    required this.index,
    required this.line,
    required this.postable,
    required this.enabled,
    required this.onChanged,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('${index + 1}',
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: line.accountId.isEmpty ? null : line.accountId,
                    decoration: const InputDecoration(
                      labelText: 'الحساب',
                      isDense: true,
                    ),
                    isExpanded: true,
                    items: postable
                        .map((a) => DropdownMenuItem(
                              value: a.id,
                              child: Text(
                                '${a.code} • ${a.name}',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ))
                        .toList(),
                    onChanged: enabled
                        ? (v) {
                            if (v != null) {
                              line.accountId = v;
                              line.accountName = postable
                                      .firstWhere((a) => a.id == v)
                                      .name;
                              onChanged();
                            }
                          }
                        : null,
                  ),
                ),
                if (onRemove != null && enabled)
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline,
                        color: AppColors.error),
                    onPressed: onRemove,
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: TextEditingController(
                      text: line.debit == 0 ? '' : line.debit.toString(),
                    ),
                    keyboardType: TextInputType.number,
                    enabled: enabled,
                    decoration: InputDecoration(
                      labelText: 'مدين',
                      labelStyle: const TextStyle(color: AppColors.debit),
                      isDense: true,
                      prefixIcon:
                          const Icon(Icons.add_circle_outline, color: AppColors.debit, size: 18),
                    ),
                    onChanged: (v) {
                      line.debit = double.tryParse(v) ?? 0;
                      if (line.debit > 0) line.credit = 0;
                      onChanged();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: TextEditingController(
                      text: line.credit == 0 ? '' : line.credit.toString(),
                    ),
                    keyboardType: TextInputType.number,
                    enabled: enabled,
                    decoration: InputDecoration(
                      labelText: 'دائن',
                      labelStyle: const TextStyle(color: AppColors.credit),
                      isDense: true,
                      prefixIcon: const Icon(
                          Icons.remove_circle_outline,
                          color: AppColors.credit,
                          size: 18),
                    ),
                    onChanged: (v) {
                      line.credit = double.tryParse(v) ?? 0;
                      if (line.credit > 0) line.debit = 0;
                      onChanged();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
