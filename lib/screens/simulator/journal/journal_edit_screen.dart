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
  late TextEditingController _descriptionCtrl;

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
    _descriptionCtrl = TextEditingController(text: _entry.description);
  }

  @override
  void dispose() {
    _descriptionCtrl.dispose();
    super.dispose();
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
    // Validate no line has both debit and credit > 0
    for (final l in cleanedLines) {
      if (l.debit > 0 && l.credit > 0) {
        _err('لا يمكن أن يحتوي السطر على مدين ودائن في نفس الوقت');
        return;
      }
      if (l.debit < 0 || l.credit < 0) {
        _err('لا يُسمح بقيم سالبة');
        return;
      }
    }
    _entry.lines = cleanedLines;
    if (!_entry.isBalanced) {
      _err(
          'القيد غير متوازن! المدين: ${Formatters.currency(_entry.totalDebit, decimals: 0)} والدائن: ${Formatters.currency(_entry.totalCredit, decimals: 0)}');
      return;
    }
    if (_entry.totalDebit <= 0) {
      _err('لا يمكن حفظ قيد بمجموع صفر');
      return;
    }
    if (post) _entry.posted = true;
    await acc.addJournal(_entry);
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    messenger.showSnackBar(
      SnackBar(content: Text(post ? 'تم الترحيل' : 'تم الحفظ')),
    );
    navigator.pop();
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
                final navigator = Navigator.of(context);
                await acc.deleteJournal(_entry.id);
                if (mounted) navigator.pop();
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
                      controller: _descriptionCtrl,
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
                key: ValueKey('line_${_entry.id}_$i'),
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
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                                Formatters.currency(_entry.totalDebit,
                                    decimals: 0),
                                style: const TextStyle(
                                    color: AppColors.debit,
                                    fontWeight: FontWeight.bold)),
                          ),
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
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                                Formatters.currency(_entry.totalCredit,
                                    decimals: 0),
                                style: const TextStyle(
                                    color: AppColors.credit,
                                    fontWeight: FontWeight.bold)),
                          ),
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
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
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

class _LineCard extends StatefulWidget {
  final int index;
  final JournalLine line;
  final List<Account> postable;
  final bool enabled;
  final VoidCallback onChanged;
  final VoidCallback? onRemove;

  const _LineCard({
    super.key,
    required this.index,
    required this.line,
    required this.postable,
    required this.enabled,
    required this.onChanged,
    this.onRemove,
  });

  @override
  State<_LineCard> createState() => _LineCardState();
}

class _LineCardState extends State<_LineCard> {
  late TextEditingController _debitCtrl;
  late TextEditingController _creditCtrl;

  @override
  void initState() {
    super.initState();
    _debitCtrl = TextEditingController(
      text: widget.line.debit == 0 ? '' : widget.line.debit.toString(),
    );
    _creditCtrl = TextEditingController(
      text: widget.line.credit == 0 ? '' : widget.line.credit.toString(),
    );
  }

  @override
  void didUpdateWidget(covariant _LineCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync values if the underlying line was reset programmatically (e.g.
    // exclusive debit/credit toggling). Avoid overwriting while user is typing.
    final debitText =
        widget.line.debit == 0 ? '' : widget.line.debit.toString();
    if (_debitCtrl.text != debitText &&
        double.tryParse(_debitCtrl.text) != widget.line.debit) {
      _debitCtrl.text = debitText;
    }
    final creditText =
        widget.line.credit == 0 ? '' : widget.line.credit.toString();
    if (_creditCtrl.text != creditText &&
        double.tryParse(_creditCtrl.text) != widget.line.credit) {
      _creditCtrl.text = creditText;
    }
  }

  @override
  void dispose() {
    _debitCtrl.dispose();
    _creditCtrl.dispose();
    super.dispose();
  }

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
                  child: Text('${widget.index + 1}',
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: widget.line.accountId.isEmpty
                        ? null
                        : widget.line.accountId,
                    decoration: const InputDecoration(
                      labelText: 'الحساب',
                      isDense: true,
                    ),
                    isExpanded: true,
                    items: widget.postable
                        .map((a) => DropdownMenuItem(
                              value: a.id,
                              child: Text(
                                '${a.code} • ${a.name}',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ))
                        .toList(),
                    onChanged: widget.enabled
                        ? (v) {
                            if (v != null) {
                              widget.line.accountId = v;
                              widget.line.accountName = widget.postable
                                  .firstWhere((a) => a.id == v)
                                  .name;
                              widget.onChanged();
                            }
                          }
                        : null,
                  ),
                ),
                if (widget.onRemove != null && widget.enabled)
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline,
                        color: AppColors.error),
                    onPressed: widget.onRemove,
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _debitCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    enabled: widget.enabled,
                    decoration: const InputDecoration(
                      labelText: 'مدين',
                      labelStyle: TextStyle(color: AppColors.debit),
                      isDense: true,
                      prefixIcon: Icon(Icons.add_circle_outline,
                          color: AppColors.debit, size: 18),
                    ),
                    onChanged: (v) {
                      final value = double.tryParse(v) ?? 0;
                      widget.line.debit = value < 0 ? 0 : value;
                      if (widget.line.debit > 0) {
                        widget.line.credit = 0;
                        _creditCtrl.text = '';
                      }
                      widget.onChanged();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _creditCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    enabled: widget.enabled,
                    decoration: const InputDecoration(
                      labelText: 'دائن',
                      labelStyle: TextStyle(color: AppColors.credit),
                      isDense: true,
                      prefixIcon: Icon(Icons.remove_circle_outline,
                          color: AppColors.credit, size: 18),
                    ),
                    onChanged: (v) {
                      final value = double.tryParse(v) ?? 0;
                      widget.line.credit = value < 0 ? 0 : value;
                      if (widget.line.credit > 0) {
                        widget.line.debit = 0;
                        _debitCtrl.text = '';
                      }
                      widget.onChanged();
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
