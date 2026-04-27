import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// شاشة المحاكاة العملية للمحاسبة المالية - سيتم تطويرها بالكامل لاحقًا.
class FinancialSimulatorScreen extends StatelessWidget {
  const FinancialSimulatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المحاكاة العملية')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'شاشة المحاكاة العملية - قيد التطوير...',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      ),
    );
  }
}
