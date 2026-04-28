import 'package:hive/hive.dart';

/// صنف في المخزون
class Item {
  String id;
  String code;
  String name;
  String unit; // وحدة القياس: كرتون، حبة، كجم...
  double cost; // تكلفة الشراء
  double price; // سعر البيع
  double quantity; // الكمية المتوفرة
  String? category;
  String currency;

  Item({
    required this.id,
    required this.code,
    required this.name,
    required this.unit,
    this.cost = 0,
    this.price = 0,
    this.quantity = 0,
    this.category,
    this.currency = 'YER',
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'code': code,
    'name': name,
    'unit': unit,
    'cost': cost,
    'price': price,
    'quantity': quantity,
    'category': category,
    'currency': currency,
  };

  factory Item.fromMap(Map m) => Item(
    id: m['id'] as String,
    code: m['code'] as String,
    name: m['name'] as String,
    unit: m['unit'] as String? ?? 'حبة',
    cost: (m['cost'] as num?)?.toDouble() ?? 0,
    price: (m['price'] as num?)?.toDouble() ?? 0,
    quantity: (m['quantity'] as num?)?.toDouble() ?? 0,
    category: m['category'] as String?,
    currency: m['currency'] as String? ?? 'YER',
  );
}

class ItemAdapter extends TypeAdapter<Item> {
  @override
  final int typeId = 4;

  @override
  Item read(BinaryReader reader) {
    return Item.fromMap(Map<String, dynamic>.from(reader.readMap()));
  }

  @override
  void write(BinaryWriter writer, Item obj) {
    writer.writeMap(obj.toMap());
  }
}
