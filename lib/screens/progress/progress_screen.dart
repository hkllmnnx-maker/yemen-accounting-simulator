import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/formatters.dart';
import '../../data/seed/glossary_content.dart' as g;
import '../../providers/progress_provider.dart';
import '../../widgets/section_card.dart';

/// شاشة التقدم والإنجازات - تعرض نقاط الخبرة، الشارات، والإحصائيات.
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ProgressProvider>();
    final level = (p.progress.totalXp / 100).floor() + 1;
    final xpInLevel = p.progress.totalXp % 100;
    final earnedBadges = g.appBadges.where((b) => p.hasBadge(b.id)).length;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.progress)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
          children: [
            // بانر XP والمستوى
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [AppColors.gold, Color(0xFFE65100)],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.30),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // مستوى مع أيقونة كأس
                  Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.20),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.emoji_events_rounded,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'المستوى $level',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${p.progress.totalXp} نقطة خبرة',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // شريط التقدم نحو المستوى التالي
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.flag_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'حتى المستوى التالي',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '$xpInLevel / 100 XP',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: xpInLevel / 100,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation(
                            Colors.white,
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // إحصائيات بطاقات
            const SectionHeader(
              title: 'الإحصائيات',
              icon: Icons.bar_chart_rounded,
            ),
            const SizedBox(height: 6),
            LayoutBuilder(
              builder: (context, c) {
                final isWide = c.maxWidth >= 600;
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: isWide ? 4 : 2,
                  childAspectRatio: isWide ? 2.4 : 2.1,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  children: [
                    StatCard(
                      icon: Icons.school_rounded,
                      label: 'الدروس',
                      value: '${p.completedLessons}/${p.totalLessons}',
                      color: AppColors.primary,
                    ),
                    StatCard(
                      icon: Icons.fitness_center_rounded,
                      label: 'التدريبات',
                      value: '${p.completedTrainings}/${p.totalTrainings}',
                      color: AppColors.accent,
                    ),
                    StatCard(
                      icon: Icons.quiz_rounded,
                      label: 'الاختبارات',
                      value: '${p.passedQuizzes}/${p.totalQuizzes}',
                      color: AppColors.warning,
                    ),
                    StatCard(
                      icon: Icons.workspace_premium_rounded,
                      label: 'الشارات',
                      value: '$earnedBadges/${g.appBadges.length}',
                      color: AppColors.gold,
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 12),
            // بطاقة الإنجاز الكلي
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: AppColors.success.withValues(alpha: 0.20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.trending_up_rounded,
                            color: AppColors.success,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'الإنجاز الكلي للتطبيق',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Text(
                          Formatters.percent(p.overallProgress),
                          style: const TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: p.overallProgress.clamp(0.0, 1.0),
                        backgroundColor: AppColors.border,
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.success,
                        ),
                        minHeight: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            const SectionHeader(
              title: 'شارات الإنجاز',
              subtitle: 'احصل على شارات بإنجاز الدروس والتدريبات',
              icon: Icons.workspace_premium_rounded,
              color: AppColors.gold,
            ),
            const SizedBox(height: 6),
            LayoutBuilder(
              builder: (context, c) {
                final w = c.maxWidth;
                final cols = w < 360
                    ? 2
                    : w < 600
                    ? 3
                    : w < 900
                    ? 4
                    : 5;
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: cols,
                  childAspectRatio: 0.95,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  children: g.appBadges.map((b) {
                    final earned = p.hasBadge(b.id);
                    return _BadgeCard(
                      emoji: b.emoji,
                      name: b.name,
                      description: b.description,
                      earned: earned,
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  final String emoji;
  final String name;
  final String description;
  final bool earned;

  const _BadgeCard({
    required this.emoji,
    required this.name,
    required this.description,
    required this.earned,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: earned
              ? AppColors.gold.withValues(alpha: 0.5)
              : AppColors.border,
          width: earned ? 1.5 : 1,
        ),
      ),
      color: earned ? AppColors.gold.withValues(alpha: 0.06) : null,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: earned
                    ? const LinearGradient(
                        colors: [AppColors.gold, Color(0xFFFB8C00)],
                      )
                    : null,
                color: earned ? null : AppColors.divider,
              ),
              alignment: Alignment.center,
              child: Opacity(
                opacity: earned ? 1.0 : 0.5,
                child: Text(
                  emoji,
                  style: TextStyle(
                    fontSize: 28,
                    color: earned ? Colors.white : AppColors.textLight,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Flexible(
              child: Text(
                name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: earned ? AppColors.gold : AppColors.textLight,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Flexible(
              child: Text(
                description,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 9.5,
                  color: AppColors.textSecondary,
                  height: 1.3,
                ),
              ),
            ),
            if (earned) ...[
              const SizedBox(height: 2),
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 14,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
