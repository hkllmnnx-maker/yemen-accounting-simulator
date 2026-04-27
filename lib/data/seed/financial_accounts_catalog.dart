import '../models/financial_accounting/financial_exercise.dart';

/// كتالوج الحسابات المعتمد داخل قسم
/// "المحاسبة المالية من القيد إلى التحليل المالي".
///
/// هذه الحسابات تُستخدم في التمارين والمحاكاة على حدٍّ سواء،
/// وأسماؤها مأخوذة من بيئة السوق المحاسبي اليمني.
class FinAccountsCatalog {
  static const List<FinAccount> all = [
    // ========== الأصول المتداولة ==========
    FinAccount(id: 'cash', name: 'الصندوق', type: FinAccountType.asset),
    FinAccount(id: 'bank', name: 'البنك', type: FinAccountType.asset),
    FinAccount(
      id: 'accounts_receivable',
      name: 'العملاء (المدينون)',
      type: FinAccountType.asset,
    ),
    FinAccount(
      id: 'notes_receivable',
      name: 'أوراق القبض',
      type: FinAccountType.asset,
    ),
    FinAccount(
      id: 'inventory',
      name: 'المخزون (البضاعة)',
      type: FinAccountType.asset,
    ),
    FinAccount(id: 'purchases', name: 'المشتريات', type: FinAccountType.asset),
    FinAccount(
      id: 'prepaid_rent',
      name: 'إيجار مدفوع مقدماً',
      type: FinAccountType.asset,
    ),
    FinAccount(
      id: 'supplies',
      name: 'المواد واللوازم',
      type: FinAccountType.asset,
    ),

    // ========== الأصول الثابتة ==========
    FinAccount(
      id: 'equipment',
      name: 'الأثاث والمعدات',
      type: FinAccountType.asset,
    ),
    FinAccount(id: 'vehicles', name: 'وسائل النقل', type: FinAccountType.asset),
    FinAccount(id: 'buildings', name: 'المباني', type: FinAccountType.asset),
    // مجمع الإهلاك يُعامَل كحساب مقابل (Contra Asset)؛
    // لتبسيط التطبيق التعليمي نضعه ضمن الالتزامات في العرض،
    // لكن نحتفظ به هنا كأصل سالب ونتعامل معه بمنطق خاص في القيد.
    FinAccount(
      id: 'accumulated_depreciation',
      name: 'مجمع إهلاك المعدات',
      type: FinAccountType.liability,
    ),

    // ========== الالتزامات ==========
    FinAccount(
      id: 'accounts_payable',
      name: 'الموردون (الدائنون)',
      type: FinAccountType.liability,
    ),
    FinAccount(
      id: 'notes_payable',
      name: 'أوراق الدفع',
      type: FinAccountType.liability,
    ),
    FinAccount(
      id: 'salaries_payable',
      name: 'رواتب مستحقة',
      type: FinAccountType.liability,
    ),
    FinAccount(
      id: 'loans_payable',
      name: 'قروض البنك',
      type: FinAccountType.liability,
    ),

    // ========== حقوق الملكية ==========
    FinAccount(id: 'capital', name: 'رأس المال', type: FinAccountType.equity),
    FinAccount(
      id: 'drawings',
      name: 'المسحوبات الشخصية',
      type: FinAccountType.equity,
    ),

    // ========== الإيرادات ==========
    FinAccount(
      id: 'sales',
      name: 'إيرادات المبيعات',
      type: FinAccountType.revenue,
    ),
    FinAccount(
      id: 'service_revenue',
      name: 'إيرادات خدمات',
      type: FinAccountType.revenue,
    ),
    FinAccount(
      id: 'discount_earned',
      name: 'الخصم المكتسب',
      type: FinAccountType.revenue,
    ),
    FinAccount(
      id: 'sales_returns',
      name: 'مردودات المبيعات',
      type: FinAccountType.expense,
    ), // يُخصم من الإيرادات
    // ========== المصروفات ==========
    FinAccount(
      id: 'cost_of_goods_sold',
      name: 'تكلفة البضاعة المباعة',
      type: FinAccountType.expense,
    ),
    FinAccount(
      id: 'rent_expense',
      name: 'مصروف الإيجار',
      type: FinAccountType.expense,
    ),
    FinAccount(
      id: 'salaries_expense',
      name: 'مصروف الرواتب',
      type: FinAccountType.expense,
    ),
    FinAccount(
      id: 'electricity_expense',
      name: 'مصروف الكهرباء',
      type: FinAccountType.expense,
    ),
    FinAccount(
      id: 'water_expense',
      name: 'مصروف الماء',
      type: FinAccountType.expense,
    ),
    FinAccount(
      id: 'transport_expense',
      name: 'مصروف النقل والمواصلات',
      type: FinAccountType.expense,
    ),
    FinAccount(
      id: 'phone_expense',
      name: 'مصروف الاتصالات',
      type: FinAccountType.expense,
    ),
    FinAccount(
      id: 'depreciation_expense',
      name: 'مصروف الإهلاك',
      type: FinAccountType.expense,
    ),
    FinAccount(
      id: 'discount_allowed',
      name: 'الخصم المسموح به',
      type: FinAccountType.expense,
    ),
    FinAccount(
      id: 'purchases_returns',
      name: 'مردودات المشتريات',
      type: FinAccountType.revenue,
    ), // يُخصم من المشتريات
    FinAccount(
      id: 'misc_expense',
      name: 'مصروفات متنوعة',
      type: FinAccountType.expense,
    ),
    FinAccount(
      id: 'advertising_expense',
      name: 'مصروف الدعاية والإعلان',
      type: FinAccountType.expense,
    ),
  ];

  /// بحث سريع عن حساب بمعرّفه.
  static FinAccount? byId(String id) {
    for (final a in all) {
      if (a.id == id) return a;
    }
    return null;
  }

  /// قائمة بأسماء الحسابات لاستخدامها في القوائم المنسدلة.
  static List<FinAccount> get sorted {
    final list = List<FinAccount>.from(all);
    list.sort((a, b) => a.name.compareTo(b.name));
    return list;
  }
}
