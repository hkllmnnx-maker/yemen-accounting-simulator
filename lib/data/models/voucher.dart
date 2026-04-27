import 'package:hive/hive.dart';

enum VoucherKind { receipt, payment }

/// سند قبض أو سند صرف
class Voucher {
  String id;
  int number;
  VoucherKind kind;
  DateTime date;
  String partnerId;
  String partnerName;
  String cashAccountId; // الصندوق أو البنك
  String cashAccountName;
  double amount;
  String? notes;
  bool posted;
  String currency;
  String? journalEntryId;

  Voucher({
    required this.id,
    required this.number,
    required this.kind,
    required this.date,
    required this.partnerId,
    required this.partnerName,
    required this.cashAccountId,
    required this.cashAccountName,
    required this.amount,
    this.notes,
    this.posted = false,
    this.currency = 'YER',
    this.journalEntryId,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'number': number,
        'kind': kind.index,
        'date': date.millisecondsSinceEpoch,
        'partnerId': partnerId,
        'partnerName': partnerName,
        'cashAccountId': cashAccountId,
        'cashAccountName': cashAccountName,
        'amount': amount,
        'notes': notes,
        'posted': posted,
        'currency': currency,
        'journalEntryId': journalEntryId,
      };

  factory Voucher.fromMap(Map m) => Voucher(
        id: m['id'] as String,
        number: m['number'] as int,
        kind: VoucherKind.values[m['kind'] as int],
        date: DateTime.fromMillisecondsSinceEpoch(m['date'] as int),
        partnerId: m['partnerId'] as String,
        partnerName: m['partnerName'] as String? ?? '',
        cashAccountId: m['cashAccountId'] as String,
        cashAccountName: m['cashAccountName'] as String? ?? '',
        amount: (m['amount'] as num?)?.toDouble() ?? 0,
        notes: m['notes'] as String?,
        posted: m['posted'] as bool? ?? false,
        currency: m['currency'] as String? ?? 'YER',
        journalEntryId: m['journalEntryId'] as String?,
      );
}

class VoucherAdapter extends TypeAdapter<Voucher> {
  @override
  final int typeId = 6;

  @override
  Voucher read(BinaryReader reader) {
    return Voucher.fromMap(Map<String, dynamic>.from(reader.readMap()));
  }

  @override
  void write(BinaryWriter writer, Voucher obj) {
    writer.writeMap(obj.toMap());
  }
}
