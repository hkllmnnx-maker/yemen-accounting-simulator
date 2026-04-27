import 'package:intl/intl.dart';

/// أدوات تنسيق الأرقام والعملات والتواريخ
class Formatters {
  /// تنسيق الأرقام بالفواصل (1,000.50)
  static String number(num value, {int decimals = 2}) {
    final f = NumberFormat.decimalPatternDigits(
      locale: 'en_US',
      decimalDigits: decimals,
    );
    return f.format(value);
  }

  /// تنسيق المبلغ بالعملة
  static String currency(num value, {String code = 'YER', int decimals = 2}) {
    final formatted = number(value, decimals: decimals);
    final symbol = currencySymbol(code);
    return '$formatted $symbol';
  }

  /// رمز العملة
  static String currencySymbol(String code) {
    switch (code.toUpperCase()) {
      case 'YER':
        return 'ر.ي';
      case 'USD':
        return '\$';
      case 'SAR':
        return 'ر.س';
      default:
        return code;
    }
  }

  /// اسم العملة بالعربية
  static String currencyName(String code) {
    switch (code.toUpperCase()) {
      case 'YER':
        return 'ريال يمني';
      case 'USD':
        return 'دولار أمريكي';
      case 'SAR':
        return 'ريال سعودي';
      default:
        return code;
    }
  }

  /// تنسيق التاريخ
  static String date(DateTime d) {
    return DateFormat('yyyy/MM/dd', 'ar').format(d);
  }

  /// تنسيق التاريخ والوقت
  static String dateTime(DateTime d) {
    return DateFormat('yyyy/MM/dd - HH:mm', 'ar').format(d);
  }

  /// تنسيق الوقت فقط
  static String time(DateTime d) {
    return DateFormat('HH:mm', 'ar').format(d);
  }

  /// تحويل النسبة المئوية
  static String percent(double v) {
    return '${(v * 100).toStringAsFixed(1)}%';
  }
}
