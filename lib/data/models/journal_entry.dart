import 'package:hive/hive.dart';

/// سطر قيد محاسبي (مدين أو دائن)
class JournalLine {
  String accountId;
  String accountName; // ذاكرة لاسم الحساب وقت القيد
  double debit;
  double credit;
  String? description;

  JournalLine({
    required this.accountId,
    required this.accountName,
    this.debit = 0,
    this.credit = 0,
    this.description,
  });

  Map<String, dynamic> toMap() => {
    'accountId': accountId,
    'accountName': accountName,
    'debit': debit,
    'credit': credit,
    'description': description,
  };

  factory JournalLine.fromMap(Map m) => JournalLine(
    accountId: m['accountId'] as String,
    accountName: m['accountName'] as String? ?? '',
    debit: (m['debit'] as num?)?.toDouble() ?? 0,
    credit: (m['credit'] as num?)?.toDouble() ?? 0,
    description: m['description'] as String?,
  );
}

/// قيد يومية
class JournalEntry {
  String id;
  int number;
  DateTime date;
  String description;
  List<JournalLine> lines;
  bool posted;
  String source; // مصدر القيد: يدوي، فاتورة بيع، فاتورة شراء، سند قبض، سند صرف
  String? sourceId;
  String currency;

  JournalEntry({
    required this.id,
    required this.number,
    required this.date,
    required this.description,
    required this.lines,
    this.posted = false,
    this.source = 'يدوي',
    this.sourceId,
    this.currency = 'YER',
  });

  double get totalDebit => lines.fold(0.0, (s, l) => s + l.debit);
  double get totalCredit => lines.fold(0.0, (s, l) => s + l.credit);
  bool get isBalanced => (totalDebit - totalCredit).abs() < 0.001;

  Map<String, dynamic> toMap() => {
    'id': id,
    'number': number,
    'date': date.millisecondsSinceEpoch,
    'description': description,
    'lines': lines.map((l) => l.toMap()).toList(),
    'posted': posted,
    'source': source,
    'sourceId': sourceId,
    'currency': currency,
  };

  factory JournalEntry.fromMap(Map m) => JournalEntry(
    id: m['id'] as String,
    number: m['number'] as int,
    date: DateTime.fromMillisecondsSinceEpoch(m['date'] as int),
    description: m['description'] as String? ?? '',
    lines: ((m['lines'] as List?) ?? [])
        .map((e) => JournalLine.fromMap(Map.from(e as Map)))
        .toList(),
    posted: m['posted'] as bool? ?? false,
    source: m['source'] as String? ?? 'يدوي',
    sourceId: m['sourceId'] as String?,
    currency: m['currency'] as String? ?? 'YER',
  );
}

class JournalEntryAdapter extends TypeAdapter<JournalEntry> {
  @override
  final int typeId = 2;

  @override
  JournalEntry read(BinaryReader reader) {
    return JournalEntry.fromMap(Map<String, dynamic>.from(reader.readMap()));
  }

  @override
  void write(BinaryWriter writer, JournalEntry obj) {
    writer.writeMap(obj.toMap());
  }
}
