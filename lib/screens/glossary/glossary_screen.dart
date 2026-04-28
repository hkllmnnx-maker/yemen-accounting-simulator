import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../data/seed/glossary_content.dart';
import '../../widgets/section_card.dart';

/// قاموس المصطلحات المحاسبية - يعرض كل المصطلحات مع البحث الفوري.
class GlossaryScreen extends StatefulWidget {
  const GlossaryScreen({super.key});

  @override
  State<GlossaryScreen> createState() => _GlossaryScreenState();
}

class _GlossaryScreenState extends State<GlossaryScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = glossary
        .where(
          (g) =>
              _query.isEmpty ||
              g.term.contains(_query) ||
              g.definition.contains(_query),
        )
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.glossary)),
      body: SafeArea(
        child: Column(
          children: [
            // شريط بحث محسن
            Container(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: 'ابحث في المصطلحات...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _query = '');
                          },
                        ),
                ),
              ),
            ),
            // مؤشر العدد
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.library_books_rounded,
                    color: AppColors.info,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _query.isEmpty
                        ? 'إجمالي المصطلحات: ${glossary.length}'
                        : 'النتائج: ${filtered.length} من ${glossary.length}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: filtered.isEmpty
                  ? const EmptyState(
                      icon: Icons.search_off_rounded,
                      message: 'لم يتم العثور على أي مصطلح',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(10, 4, 10, 16),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final g = filtered[i];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: AppColors.primary.withValues(alpha: 0.10),
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: ExpansionTile(
                            tilePadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            leading: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary.withValues(alpha: 0.18),
                                    AppColors.primary.withValues(alpha: 0.08),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.auto_stories_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              g.term,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.5,
                              ),
                            ),
                            childrenPadding: const EdgeInsets.fromLTRB(
                              16,
                              0,
                              16,
                              14,
                            ),
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  g.definition,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    height: 1.7,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              if (g.example != null) ...[
                                const SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.warningLight,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.warning.withValues(
                                        alpha: 0.20,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.lightbulb_rounded,
                                        color: AppColors.warning,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'مثال',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.warning,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              g.example!,
                                              style: const TextStyle(
                                                fontSize: 12.5,
                                                color: AppColors.textPrimary,
                                                height: 1.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
