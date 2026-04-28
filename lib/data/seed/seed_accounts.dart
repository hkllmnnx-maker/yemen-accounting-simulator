import '../models/account.dart';

/// شجرة الحسابات اليمنية الافتراضية
List<Account> defaultAccountsTree() {
  return [
    // ========== 1 الأصول ==========
    Account(
      id: 'a1',
      code: '1',
      name: 'الأصول',
      type: AccountType.asset,
      isPostable: false,
    ),

    Account(
      id: 'a11',
      code: '11',
      name: 'الأصول المتداولة',
      type: AccountType.asset,
      parentId: 'a1',
      isPostable: false,
    ),

    // الصناديق
    Account(
      id: 'a111',
      code: '111',
      name: 'الصناديق',
      type: AccountType.asset,
      parentId: 'a11',
      isPostable: false,
    ),
    Account(
      id: 'a1111',
      code: '1111',
      name: 'الصندوق الرئيسي',
      type: AccountType.asset,
      parentId: 'a111',
    ),
    Account(
      id: 'a1112',
      code: '1112',
      name: 'صندوق المبيعات',
      type: AccountType.asset,
      parentId: 'a111',
    ),
    Account(
      id: 'a1113',
      code: '1113',
      name: 'صندوق المشتريات',
      type: AccountType.asset,
      parentId: 'a111',
    ),

    // البنوك
    Account(
      id: 'a112',
      code: '112',
      name: 'البنوك',
      type: AccountType.asset,
      parentId: 'a11',
      isPostable: false,
    ),
    Account(
      id: 'a1121',
      code: '1121',
      name: 'بنك التسليف الزراعي - ريال يمني',
      type: AccountType.asset,
      parentId: 'a112',
    ),
    Account(
      id: 'a1122',
      code: '1122',
      name: 'بنك الكريمي - دولار',
      type: AccountType.asset,
      parentId: 'a112',
      currency: 'USD',
    ),

    // العملاء
    Account(
      id: 'a113',
      code: '113',
      name: 'العملاء (مدينون)',
      type: AccountType.asset,
      parentId: 'a11',
      isPostable: false,
    ),

    // المخزون
    Account(
      id: 'a114',
      code: '114',
      name: 'المخزون',
      type: AccountType.asset,
      parentId: 'a11',
    ),

    // الأصول الثابتة
    Account(
      id: 'a12',
      code: '12',
      name: 'الأصول الثابتة',
      type: AccountType.asset,
      parentId: 'a1',
      isPostable: false,
    ),
    Account(
      id: 'a121',
      code: '121',
      name: 'أثاث ومفروشات',
      type: AccountType.asset,
      parentId: 'a12',
    ),
    Account(
      id: 'a122',
      code: '122',
      name: 'سيارات',
      type: AccountType.asset,
      parentId: 'a12',
    ),
    Account(
      id: 'a123',
      code: '123',
      name: 'أجهزة كمبيوتر',
      type: AccountType.asset,
      parentId: 'a12',
    ),

    // ========== 2 الالتزامات ==========
    Account(
      id: 'a2',
      code: '2',
      name: 'الالتزامات',
      type: AccountType.liability,
      isPostable: false,
    ),
    Account(
      id: 'a21',
      code: '21',
      name: 'الموردون (دائنون)',
      type: AccountType.liability,
      parentId: 'a2',
      isPostable: false,
    ),
    Account(
      id: 'a22',
      code: '22',
      name: 'مصروفات مستحقة',
      type: AccountType.liability,
      parentId: 'a2',
    ),

    // ========== 3 حقوق الملكية ==========
    Account(
      id: 'a3',
      code: '3',
      name: 'حقوق الملكية',
      type: AccountType.equity,
      isPostable: false,
    ),
    Account(
      id: 'a31',
      code: '31',
      name: 'رأس المال',
      type: AccountType.equity,
      parentId: 'a3',
    ),
    Account(
      id: 'a32',
      code: '32',
      name: 'الأرباح المحتجزة',
      type: AccountType.equity,
      parentId: 'a3',
    ),

    // ========== 4 الإيرادات ==========
    Account(
      id: 'a4',
      code: '4',
      name: 'الإيرادات',
      type: AccountType.revenue,
      isPostable: false,
    ),
    Account(
      id: 'a41',
      code: '41',
      name: 'إيرادات المبيعات',
      type: AccountType.revenue,
      parentId: 'a4',
    ),
    Account(
      id: 'a42',
      code: '42',
      name: 'مرتجعات المبيعات',
      type: AccountType.revenue,
      parentId: 'a4',
    ),
    Account(
      id: 'a43',
      code: '43',
      name: 'فروقات صرف عملة',
      type: AccountType.revenue,
      parentId: 'a4',
    ),

    // ========== 5 المصروفات ==========
    Account(
      id: 'a5',
      code: '5',
      name: 'المصروفات',
      type: AccountType.expense,
      isPostable: false,
    ),
    Account(
      id: 'a51',
      code: '51',
      name: 'تكلفة البضاعة المباعة',
      type: AccountType.expense,
      parentId: 'a5',
    ),
    Account(
      id: 'a52',
      code: '52',
      name: 'مصروف الإيجار',
      type: AccountType.expense,
      parentId: 'a5',
    ),
    Account(
      id: 'a53',
      code: '53',
      name: 'مصروف الكهرباء',
      type: AccountType.expense,
      parentId: 'a5',
    ),
    Account(
      id: 'a54',
      code: '54',
      name: 'مصروف الرواتب',
      type: AccountType.expense,
      parentId: 'a5',
    ),
    Account(
      id: 'a55',
      code: '55',
      name: 'مصروف المواصلات',
      type: AccountType.expense,
      parentId: 'a5',
    ),
    Account(
      id: 'a56',
      code: '56',
      name: 'مصروفات متنوعة',
      type: AccountType.expense,
      parentId: 'a5',
    ),
    Account(
      id: 'a57',
      code: '57',
      name: 'مرتجعات المشتريات',
      type: AccountType.expense,
      parentId: 'a5',
    ),
  ];
}
