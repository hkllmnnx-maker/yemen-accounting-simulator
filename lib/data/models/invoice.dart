import 'package:hive/hive.dart';

enum InvoiceKind { sale, purchase, saleReturn, purchaseReturn }

enum InvoicePaymentType { cash, credit, mixed }

/// سطر فاتورة
class InvoiceLine {
  String itemId;
  String itemName;
  double quantity;
  double unitPrice;
  double discount;

  InvoiceLine({
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.unitPrice,
    this.discount = 0,
  });

  double get total => (quantity * unitPrice) - discount;

  Map<String, dynamic> toMap() => {
    'itemId': itemId,
    'itemName': itemName,
    'quantity': quantity,
    'unitPrice': unitPrice,
    'discount': discount,
  };

  factory InvoiceLine.fromMap(Map m) => InvoiceLine(
    itemId: m['itemId'] as String,
    itemName: m['itemName'] as String? ?? '',
    quantity: (m['quantity'] as num?)?.toDouble() ?? 0,
    unitPrice: (m['unitPrice'] as num?)?.toDouble() ?? 0,
    discount: (m['discount'] as num?)?.toDouble() ?? 0,
  );
}

/// فاتورة بيع/شراء/مرتجع
class Invoice {
  String id;
  int number;
  InvoiceKind kind;
  DateTime date;
  String partnerId;
  String partnerName;
  List<InvoiceLine> lines;
  InvoicePaymentType paymentType;
  double paidAmount; // المبلغ المدفوع نقدًا (للمختلطة)
  String? notes;
  bool posted;
  String currency;
  String? journalEntryId;

  Invoice({
    required this.id,
    required this.number,
    required this.kind,
    required this.date,
    required this.partnerId,
    required this.partnerName,
    required this.lines,
    this.paymentType = InvoicePaymentType.cash,
    this.paidAmount = 0,
    this.notes,
    this.posted = false,
    this.currency = 'YER',
    this.journalEntryId,
  });

  double get total => lines.fold(0.0, (s, l) => s + l.total);
  double get remaining {
    if (paymentType == InvoicePaymentType.cash) return 0;
    if (paymentType == InvoicePaymentType.credit) return total;
    return total - paidAmount;
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'number': number,
    'kind': kind.index,
    'date': date.millisecondsSinceEpoch,
    'partnerId': partnerId,
    'partnerName': partnerName,
    'lines': lines.map((l) => l.toMap()).toList(),
    'paymentType': paymentType.index,
    'paidAmount': paidAmount,
    'notes': notes,
    'posted': posted,
    'currency': currency,
    'journalEntryId': journalEntryId,
  };

  factory Invoice.fromMap(Map m) => Invoice(
    id: m['id'] as String,
    number: m['number'] as int,
    kind: InvoiceKind.values[m['kind'] as int],
    date: DateTime.fromMillisecondsSinceEpoch(m['date'] as int),
    partnerId: m['partnerId'] as String,
    partnerName: m['partnerName'] as String? ?? '',
    lines: ((m['lines'] as List?) ?? [])
        .map((e) => InvoiceLine.fromMap(Map.from(e as Map)))
        .toList(),
    paymentType: InvoicePaymentType.values[m['paymentType'] as int? ?? 0],
    paidAmount: (m['paidAmount'] as num?)?.toDouble() ?? 0,
    notes: m['notes'] as String?,
    posted: m['posted'] as bool? ?? false,
    currency: m['currency'] as String? ?? 'YER',
    journalEntryId: m['journalEntryId'] as String?,
  );
}

class InvoiceAdapter extends TypeAdapter<Invoice> {
  @override
  final int typeId = 5;

  @override
  Invoice read(BinaryReader reader) {
    return Invoice.fromMap(Map<String, dynamic>.from(reader.readMap()));
  }

  @override
  void write(BinaryWriter writer, Invoice obj) {
    writer.writeMap(obj.toMap());
  }
}
