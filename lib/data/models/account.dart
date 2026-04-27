import 'package:hive/hive.dart';

/// نوع الحساب الرئيسي (تصنيف القائمة المالية)
enum AccountType {
  asset, // أصول
  liability, // التزامات
  equity, // حقوق ملكية
  revenue, // إيرادات
  expense, // مصروفات
}

extension AccountTypeX on AccountType {
  String get arabicName {
    switch (this) {
      case AccountType.asset:
        return 'الأصول';
      case AccountType.liability:
        return 'الالتزامات';
      case AccountType.equity:
        return 'حقوق الملكية';
      case AccountType.revenue:
        return 'الإيرادات';
      case AccountType.expense:
        return 'المصروفات';
    }
  }

  /// طبيعة الحساب: مدين أم دائن
  bool get isDebitNature {
    return this == AccountType.asset || this == AccountType.expense;
  }
}

/// حساب في شجرة الحسابات
class Account {
  String id;
  String code; // رقم الحساب
  String name; // اسم الحساب
  AccountType type;
  String? parentId; // الحساب الأب
  bool isPostable; // هل يقبل القيود؟
  double openingBalance; // رصيد افتتاحي
  String currency;

  Account({
    required this.id,
    required this.code,
    required this.name,
    required this.type,
    this.parentId,
    this.isPostable = true,
    this.openingBalance = 0,
    this.currency = 'YER',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'code': code,
        'name': name,
        'type': type.index,
        'parentId': parentId,
        'isPostable': isPostable,
        'openingBalance': openingBalance,
        'currency': currency,
      };

  factory Account.fromMap(Map m) => Account(
        id: m['id'] as String,
        code: m['code'] as String,
        name: m['name'] as String,
        type: AccountType.values[m['type'] as int],
        parentId: m['parentId'] as String?,
        isPostable: m['isPostable'] as bool? ?? true,
        openingBalance: (m['openingBalance'] as num?)?.toDouble() ?? 0,
        currency: m['currency'] as String? ?? 'YER',
      );
}

class AccountAdapter extends TypeAdapter<Account> {
  @override
  final int typeId = 1;

  @override
  Account read(BinaryReader reader) {
    final map = Map<String, dynamic>.from(reader.readMap());
    return Account.fromMap(map);
  }

  @override
  void write(BinaryWriter writer, Account obj) {
    writer.writeMap(obj.toMap());
  }
}
