import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../data/seed/trainings_content.dart';
import '../../providers/progress_provider.dart';
import '../../widgets/section_card.dart';
import 'training_screen.dart';

/// شاشة قائمة التدريبات العملية
class TrainingListScreen extends StatelessWidget {
  const TrainingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressProvider>();
    final completed = progress.completedTrainings;
    final total = appTrainings.length;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.training)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 24),
          children: [
            // بانر تعريفي
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    AppColors.accent,
                    AppColors.accent.withValues(alpha: 0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.fitness_center_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تدريبات عملية واقعية',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'سيناريوهات من الشركات اليمنية لتطبيق ما تعلمته',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$completed/$total',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'مكتملة',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const SectionHeader(
              title: 'قائمة التدريبات',
              icon: Icons.list_alt_rounded,
            ),
            const SizedBox(height: 6),
            if (appTrainings.isEmpty)
              const Padding(
                padding: EdgeInsets.all(40),
                child: EmptyState(
                  icon: Icons.fitness_center_rounded,
                  message: 'لا توجد تدريبات متاحة بعد',
                ),
              )
            else
              ...List.generate(appTrainings.length, (i) {
                final t = appTrainings[i];
                final done = progress.isTrainingCompleted(t.id);
                return _TrainingCard(
                  index: i + 1,
                  title: t.title,
                  description: t.description,
                  xp: t.xpReward,
                  done: done,
                  steps: t.steps.length,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TrainingScreen(scenario: t),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _TrainingCard extends StatelessWidget {
  final int index;
  final String title;
  final String description;
  final int xp;
  final bool done;
  final int steps;
  final VoidCallback onTap;

  const _TrainingCard({
    required this.index,
    required this.title,
    required this.description,
    required this.xp,
    required this.done,
    required this.steps,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final mainColor = done ? AppColors.success : AppColors.accent;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: mainColor.withValues(alpha: done ? 0.30 : 0.15),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          mainColor.withValues(alpha: 0.18),
                          mainColor.withValues(alpha: 0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: done
                        ? const Icon(
                            Icons.check_rounded,
                            color: AppColors.success,
                            size: 24,
                          )
                        : Icon(
                            Icons.fitness_center_rounded,
                            color: mainColor,
                            size: 22,
                          ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.5,
                      ),
                    ),
                  ),
                  if (done)
                    const Padding(
                      padding: EdgeInsets.only(right: 4),
                      child: Icon(
                        Icons.verified_rounded,
                        color: AppColors.success,
                        size: 22,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12.5,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _Chip(
                    icon: Icons.format_list_numbered_rounded,
                    text: '$steps خطوة',
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  _Chip(
                    icon: Icons.star_rounded,
                    text: '$xp XP',
                    color: AppColors.gold,
                  ),
                  const Spacer(),
                  Text(
                    done ? 'إعادة' : 'بدء التدريب',
                    style: TextStyle(
                      color: mainColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.5,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_back_ios_rounded,
                    size: 12,
                    color: mainColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _Chip({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 3),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
