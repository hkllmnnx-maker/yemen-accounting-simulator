import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/seed/financial_accounts_catalog.dart';
import '../../../providers/financial_accounting_provider.dart';
import 'journal_entry_form_screen.dart';

/// شاشة قائمة قيود اليومية في المحاكاة.
class FaJournalListScreen extends StatelessWidget {
  const FaJournalListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fa = context.watch<FinancialAccountingProvider>();
    final entries = fa.simJournal;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header summary
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.book, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'دفتر اليومية',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'عدد القيود: ${entries.length}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (entries.isNotEmpty)
                    IconButton(
                      tooltip: 'مسح كل القيود',
                      onPressed: () => _confirmClear(context, fa),
                      icon: const Icon(Icons.delete_sweep, color: Colors.white),
                    ),
                ],
              ),
            ),
            Expanded(
              child: entries.isEmpty
                  ? _buildEmpty(context)
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: entries.length,
                      itemBuilder: (_, i) {
                        final e = entries[entries.length - 1 - i];
                        final originalIndex = entries.length - 1 - i;
                        return _JournalCard(
                          entry: e,
                          number: entries.length - i,
                          onDelete: () => fa.removeSimEntry(originalIndex),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const JournalEntryFormScreen()),
        ),
        backgroundColor: AppColors.success,
        icon: const Icon(Icons.add),
        label: const Text('قيد جديد'),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.book_outlined,
              size: 80,
              color: AppColors.textLight,
            ),
            const SizedBox(height: 12),
            const Text(
              'لا توجد قيود مدخلة بعد',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'ابدأ بإدخال قيد يومية جديد عبر زر "قيد جديد"',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: AppColors.textLight),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const JournalEntryFormScreen(),
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text('إضافة قيد جديد'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmClear(
    BuildContext context,
    FinancialAccountingProvider fa,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('مسح كل القيود؟'),
        content: const Text(
          'سيتم حذف جميع قيود اليومية في المحاكاة وإعادة المحاسبة من الصفر. هل أنت متأكد؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('نعم، احذف الكل'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await fa.clearSimJournal();
    }
  }
}

class _JournalCard extends StatelessWidget {
  final dynamic entry; // JournalEntryAnswer
  final int number;
  final VoidCallback onDelete;

  const _JournalCard({
    required this.entry,
    required this.number,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'قيد رقم $number',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  Formatters.date(entry.date),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: AppColors.error,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 28,
                    minHeight: 28,
                  ),
                ),
              ],
            ),
            if (entry.description != null &&
                (entry.description as String).isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  entry.description as String,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            const Divider(height: 16),
            // أطراف القيد
            for (final l in entry.lines)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
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
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: l.isDebit ? AppColors.debit : AppColors.credit,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerEnd,
                        child: Text(
                          Formatters.currency(l.amount),
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: l.isDebit
                                ? AppColors.debit
                                : AppColors.credit,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
