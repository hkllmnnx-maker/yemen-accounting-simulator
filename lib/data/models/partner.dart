import 'package:hive/hive.dart';

enum PartnerKind { customer, supplier }

/// عميل أو مورد
class Partner {
  String id;
  String code;
  String name;
  PartnerKind kind;
  String city;
  String? phone;
  bool isCredit; // آجل
  double creditLimit;
  String currency;
  double openingBalance; // (موجب = له مديونية على العميل / علينا للمورد)
  String accountId; // الحساب المرتبط في شجرة الحسابات

  Partner({
    required this.id,
    required this.code,
    required this.name,
    required this.kind,
    required this.city,
    required this.accountId,
    this.phone,
    this.isCredit = true,
    this.creditLimit = 0,
    this.currency = 'YER',
    this.openingBalance = 0,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'code': code,
    'name': name,
    'kind': kind.index,
    'city': city,
    'phone': phone,
    'isCredit': isCredit,
    'creditLimit': creditLimit,
    'currency': currency,
    'openingBalance': openingBalance,
    'accountId': accountId,
  };

  factory Partner.fromMap(Map m) => Partner(
    id: m['id'] as String,
    code: m['code'] as String,
    name: m['name'] as String,
    kind: PartnerKind.values[m['kind'] as int],
    city: m['city'] as String? ?? '',
    phone: m['phone'] as String?,
    isCredit: m['isCredit'] as bool? ?? true,
    creditLimit: (m['creditLimit'] as num?)?.toDouble() ?? 0,
    currency: m['currency'] as String? ?? 'YER',
    openingBalance: (m['openingBalance'] as num?)?.toDouble() ?? 0,
    accountId: m['accountId'] as String,
  );
}

class PartnerAdapter extends TypeAdapter<Partner> {
  @override
  final int typeId = 3;

  @override
  Partner read(BinaryReader reader) {
    return Partner.fromMap(Map<String, dynamic>.from(reader.readMap()));
  }

  @override
  void write(BinaryWriter writer, Partner obj) {
    writer.writeMap(obj.toMap());
  }
}
