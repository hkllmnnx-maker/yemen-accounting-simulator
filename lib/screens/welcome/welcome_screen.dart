import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../data/repositories/database_service.dart';
import '../dashboard/dashboard_screen.dart';

/// شاشة الترحيب الأولى - تظهر مرة واحدة عند فتح التطبيق لأول مرة.
/// تشرح للمستخدم محتوى التطبيق وأقسامه الرئيسية.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _controller = PageController();
  int _index = 0;

  final _pages = const [
    _IntroData(
      icon: Icons.account_balance_rounded,
      title: 'محاكي المحاسبة اليمني',
      desc:
          'تطبيق تدريبي عملي للمحاسبين المبتدئين في اليمن، مستوحى من الأنظمة المحاسبية المنتشرة في السوق اليمني.',
      color: AppColors.primary,
    ),
    _IntroData(
      icon: Icons.school_rounded,
      title: 'دروس وتدريبات عملية',
      desc:
          'دروس مختصرة بأمثلة من بيئة المحاسبة اليمنية، وتدريبات عملية بسيناريوهات حقيقية من الشركات والمحلات.',
      color: AppColors.accent,
    ),
    _IntroData(
      icon: Icons.calculate_rounded,
      title: 'محاكاة نظام محاسبي حقيقي',
      desc:
          'شجرة حسابات، قيود يومية، عملاء وموردون، فواتير، سندات قبض وصرف، تقارير مالية - كل شيء داخل تطبيق واحد.',
      color: AppColors.success,
    ),
    _IntroData(
      icon: Icons.emoji_events_rounded,
      title: 'تابع تقدمك واحصل على شارات',
      desc:
          'كل درس وتدريب يضيف لك نقاط خبرة وشارات إنجاز، حتى تصبح محاسبًا يمنيًا محترفًا.',
      color: AppColors.gold,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await DatabaseService.markIntroSeen();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const DashboardScreen(),
        transitionDuration: const Duration(milliseconds: 350),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: TextButton.icon(
                  onPressed: _finish,
                  icon: const Icon(Icons.skip_next_rounded, size: 18),
                  label: const Text('تخطّي'),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) => _IntroPage(data: _pages[i]),
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
                  width: i == _index ? 28 : 8,
                  decoration: BoxDecoration(
                    color: i == _index
                        ? _pages[_index].color
                        : AppColors.border,
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
                    TextButton.icon(
                      onPressed: () => _controller.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      ),
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: const Text(AppStrings.prev),
                    )
                  else
                    const SizedBox(width: 90),
                  ElevatedButton.icon(
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
                      backgroundColor: _pages[_index].color,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 26,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: Icon(
                      _index == _pages.length - 1
                          ? Icons.rocket_launch_rounded
                          : Icons.arrow_back_rounded,
                      size: 18,
                    ),
                    label: Text(
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

class _IntroData {
  final IconData icon;
  final String title;
  final String desc;
  final Color color;
  const _IntroData({
    required this.icon,
    required this.title,
    required this.desc,
    required this.color,
  });
}

class _IntroPage extends StatelessWidget {
  final _IntroData data;
  const _IntroPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // أيقونة بحجم كبير ومتدرج
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  data.color.withValues(alpha: 0.18),
                  data.color.withValues(alpha: 0.06),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: data.color.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Icon(data.icon, size: 80, color: data.color),
          ),
          const SizedBox(height: 28),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            data.desc,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14.5,
              color: AppColors.textSecondary,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}
