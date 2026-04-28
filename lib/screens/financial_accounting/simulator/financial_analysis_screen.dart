import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/financial_accounting/financial_statement.dart';
import '../../../providers/financial_accounting_provider.dart';

/// شاشة التحليل المالي - تعرض النسب الأساسية مع شرح كل نسبة.
class FaFinancialAnalysisScreen extends StatelessWidget {
  const FaFinancialAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fa = context.watch<FinancialAccountingProvider>();
    final ratios = fa.buildRatios();

    if (fa.simJournal.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'لا توجد قيود لاستخراج تحليل مالي.\n'
            'أدخل قيودًا في تبويب اليومية أولاً.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.equity, Color(0xFF4A148C)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Row(
                children: [
                  Icon(Icons.analytics, color: Colors.white, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'التحليل المالي',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6),
              Text(
                'النسب المالية تساعدك على قراءة أداء المنشأة وموقفها المالي.',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (ratios.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'لا توجد بيانات كافية لاحتساب النسب المالية. تأكد من إدخال إيرادات/مصروفات/أصول/التزامات.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          )
        else
          for (final r in ratios) _RatioCard(ratio: r),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _RatioCard extends StatelessWidget {
  final FinancialRatio ratio;
  const _RatioCard({required this.ratio});

  Color get _color {
    final v = ratio.value;
    final name = ratio.name;

    if (name.contains('التداول')) {
      if (v >= 2) return AppColors.success;
      if (v >= 1) return AppColors.warning;
      return AppColors.error;
    }
    if (name.contains('هامش الربح') || name.contains('العائد')) {
      if (v >= 10) return AppColors.success;
      if (v >= 0) return AppColors.warning;
      return AppColors.error;
    }
    if (name.contains('المديونية')) {
      if (v <= 40) return AppColors.success;
      if (v <= 60) return AppColors.warning;
      return AppColors.error;
    }
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.insights, color: color, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    ratio.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${ratio.value} ${ratio.unit}',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.calculate,
                  size: 14,
                  color: AppColors.textLight,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'الصيغة: ${ratio.formula}',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline, color: color, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      ratio.interpretation,
                      style: TextStyle(fontSize: 12, height: 1.5, color: color),
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
