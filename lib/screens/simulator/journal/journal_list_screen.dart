import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/accounting_provider.dart';
import '../../../widgets/section_card.dart';
import 'journal_edit_screen.dart';

class JournalListScreen extends StatelessWidget {
  const JournalListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final acc = context.watch<AccountingProvider>();
    final journals = acc.journals;
    return Scaffold(
      appBar: AppBar(title: const Text('القيود اليومية')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const JournalEditScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('قيد جديد'),
      ),
      body: SafeArea(
        child: journals.isEmpty
            ? const EmptyState(
                icon: Icons.book,
                message: 'لا توجد قيود بعد. ابدأ بإنشاء أول قيد محاسبي.',
              )
            : ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: journals.length,
                itemBuilder: (_, i) {
                  final j = journals[i];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: j.posted
                            ? AppColors.success.withValues(alpha: 0.15)
                            : AppColors.warning.withValues(alpha: 0.15),
                        foregroundColor: j.posted
                            ? AppColors.success
                            : AppColors.warning,
                        child: Text(
                          '#${j.number}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        j.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 12,
                              color: AppColors.textLight,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              Formatters.date(j.date),
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Icon(
                              Icons.label_outline,
                              size: 12,
                              color: AppColors.textLight,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              j.source,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            Formatters.currency(j.totalDebit, decimals: 0),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: j.posted
                                  ? AppColors.successLight
                                  : AppColors.warningLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              j.posted ? 'مرحّل' : 'مؤقت',
                              style: TextStyle(
                                fontSize: 10,
                                color: j.posted
                                    ? AppColors.success
                                    : AppColors.warning,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => JournalEditScreen(journalId: j.id),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
