import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../data/repositories/database_service.dart';
import '../dashboard/dashboard_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _controller = PageController();
  int _index = 0;

  final _pages = const [
    _IntroPage(
      icon: Icons.account_balance,
      title: 'محاكي المحاسبة اليمني',
      desc:
          'تطبيق تدريبي عملي للمحاسبين المبتدئين في اليمن، مستوحى من الأنظمة المحاسبية المنتشرة في السوق اليمني.',
    ),
    _IntroPage(
      icon: Icons.school,
      title: 'دروس وتدريبات عملية',
      desc:
          'دروس مختصرة بأمثلة من بيئة المحاسبة اليمنية، وتدريبات عملية بسيناريوهات حقيقية من الشركات والمحلات.',
    ),
    _IntroPage(
      icon: Icons.calculate,
      title: 'محاكاة نظام محاسبي حقيقي',
      desc:
          'شجرة حسابات، قيود يومية، عملاء وموردون، فواتير، سندات قبض وصرف، تقارير مالية - كل شيء داخل تطبيق واحد.',
    ),
    _IntroPage(
      icon: Icons.emoji_events,
      title: 'تابع تقدمك واحصل على شارات',
      desc:
          'كل درس وتدريب يضيف لك نقاط خبرة وشارات إنجاز، حتى تصبح محاسبًا يمنيًا محترفًا.',
    ),
  ];

  Future<void> _finish() async {
    await DatabaseService.markIntroSeen();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: TextButton(
                  onPressed: _finish,
                  child: const Text('تخطّي'),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) => _pages[i],
              ),
            ),
            // dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: i == _index ? 24 : 8,
                  decoration: BoxDecoration(
                    color: i == _index ? AppColors.primary : AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_index > 0)
                    TextButton(
                      onPressed: () => _controller.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      ),
                      child: const Text(AppStrings.prev),
                    )
                  else
                    const SizedBox(width: 80),
                  ElevatedButton(
                    onPressed: () {
                      if (_index < _pages.length - 1) {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      } else {
                        _finish();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      _index == _pages.length - 1
                          ? 'ابدأ الآن'
                          : AppStrings.next,
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

class _IntroPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  const _IntroPage({
    required this.icon,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 70, color: AppColors.primary),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
