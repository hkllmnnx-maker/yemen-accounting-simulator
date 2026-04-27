import 'package:flutter/material.dart';

/// ألوان التطبيق - مستوحاة من بيئة الأنظمة المحاسبية اليمنية
class AppColors {
  // ألوان أساسية محاسبية
  static const Color primary = Color(0xFF1565C0); // أزرق محاسبي عميق
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color primaryLight = Color(0xFF1976D2);
  static const Color accent = Color(0xFF00897B); // تركواز محاسبي

  // خلفيات
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Colors.white;
  static const Color cardBackground = Colors.white;
  static const Color sidebar = Color(0xFF1E2A3A); // قائمة جانبية داكنة
  static const Color sidebarActive = Color(0xFF1565C0);

  // نصوص
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF5A6470);
  static const Color textLight = Color(0xFF8B95A1);
  static const Color textOnDark = Colors.white;

  // حالات
  static const Color success = Color(0xFF2E7D32); // أخضر للنجاح
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color error = Color(0xFFC62828); // أحمر للأخطاء
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color warning = Color(0xFFEF6C00);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color info = Color(0xFF0277BD);
  static const Color infoLight = Color(0xFFE1F5FE);

  // محاسبية مخصصة
  static const Color debit = Color(0xFFC62828); // مدين
  static const Color credit = Color(0xFF2E7D32); // دائن
  static const Color balance = Color(0xFF1565C0); // الرصيد

  // ألوان للتدريب والإنجازات
  static const Color gold = Color(0xFFFFB300);
  static const Color silver = Color(0xFFB0BEC5);
  static const Color bronze = Color(0xFFA1887F);

  // حدود وخطوط
  static const Color border = Color(0xFFE0E4E8);
  static const Color divider = Color(0xFFEEF1F4);

  // ألوان فئات الحسابات
  static const Color assets = Color(0xFF1565C0); // أصول
  static const Color liabilities = Color(0xFFC62828); // التزامات
  static const Color equity = Color(0xFF6A1B9A); // حقوق ملكية
  static const Color revenue = Color(0xFF2E7D32); // إيرادات
  static const Color expenses = Color(0xFFEF6C00); // مصروفات
}
