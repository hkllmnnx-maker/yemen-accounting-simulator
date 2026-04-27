import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/account.dart';
import '../models/journal_entry.dart';
import '../models/partner.dart';
import '../models/item.dart';
import '../models/invoice.dart';
import '../models/voucher.dart';
import '../models/company.dart';
import '../models/progress.dart';
import '../seed/seed_accounts.dart';
import '../seed/yemeni_data.dart';

/// خدمة قاعدة البيانات المركزية - Hive + SharedPreferences
class DatabaseService {
  static const String accountsBox = 'accounts';
  static const String journalsBox = 'journals';
  static const String partnersBox = 'partners';
  static const String itemsBox = 'items';
  static const String invoicesBox = 'invoices';
  static const String vouchersBox = 'vouchers';

  static const String _kInitialized = 'db_initialized_v1';
  static const String _kCompany = 'company_settings';
  static const String _kProgress = 'user_progress';
  static const String _kCounters = 'counters';
  static const String _kIntroSeen = 'intro_seen';

  // مفاتيح قسم المحاسبة المالية (المسار التعليمي)
  static const String _kFaCompletedExercises = 'fa_completed_exercises';
  static const String _kFaCompletedLessons = 'fa_completed_lessons';
  static const String _kFaSimJournal = 'fa_simulator_journal_v1';

  static late Box accountsBoxRef;
  static late Box journalsBoxRef;
  static late Box partnersBoxRef;
  static late Box itemsBoxRef;
  static late Box invoicesBoxRef;
  static late Box vouchersBoxRef;
  static late SharedPreferences prefs;

  static Future<void> init({String? testPath}) async {
    if (testPath != null) {
      Hive.init(testPath);
    } else {
      await Hive.initFlutter();
    }

    // تسجيل المحوّلات
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(AccountAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(JournalEntryAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(PartnerAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(ItemAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(InvoiceAdapter());
    }
    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(VoucherAdapter());
    }

    accountsBoxRef = await Hive.openBox(accountsBox);
    journalsBoxRef = await Hive.openBox(journalsBox);
    partnersBoxRef = await Hive.openBox(partnersBox);
    itemsBoxRef = await Hive.openBox(itemsBox);
    invoicesBoxRef = await Hive.openBox(invoicesBox);
    vouchersBoxRef = await Hive.openBox(vouchersBox);

    prefs = await SharedPreferences.getInstance();

    if (!(prefs.getBool(_kInitialized) ?? false)) {
      await _seedInitialData();
      await prefs.setBool(_kInitialized, true);
    }
  }

  static Future<void> _seedInitialData() async {
    // الحسابات
    for (final a in defaultAccountsTree()) {
      await accountsBoxRef.put(a.id, a);
    }

    // أصناف افتراضية
    int idx = 1;
    for (final m in YemeniData.sampleItems) {
      final id = 'item_${idx.toString().padLeft(3, '0')}';
      final code = 'P${idx.toString().padLeft(4, '0')}';
      await itemsBoxRef.put(
        id,
        Item(
          id: id,
          code: code,
          name: m['name'] as String,
          unit: m['unit'] as String,
          cost: (m['cost'] as num).toDouble(),
          price: (m['price'] as num).toDouble(),
          quantity: 50, // كمية افتتاحية
        ),
      );
      idx++;
    }

    // إنشاء حسابات فرعية للعملاء/الموردين الافتراضيين
    // عميل افتراضي: محلات البركة
    final cust1Account = Account(
      id: 'a113_001',
      code: '113001',
      name: 'محلات البركة',
      type: AccountType.asset,
      parentId: 'a113',
    );
    await accountsBoxRef.put(cust1Account.id, cust1Account);

    final cust1 = Partner(
      id: 'cust_001',
      code: 'C0001',
      name: 'محلات البركة',
      kind: PartnerKind.customer,
      city: 'تعز',
      phone: '777111222',
      isCredit: true,
      creditLimit: 500000,
      accountId: cust1Account.id,
      openingBalance: 0,
    );
    await partnersBoxRef.put(cust1.id, cust1);

    // مورد افتراضي: مؤسسة سبأ للتوريدات
    final supp1Account = Account(
      id: 'a21_001',
      code: '21001',
      name: 'مؤسسة سبأ للتوريدات',
      type: AccountType.liability,
      parentId: 'a21',
    );
    await accountsBoxRef.put(supp1Account.id, supp1Account);

    final supp1 = Partner(
      id: 'supp_001',
      code: 'S0001',
      name: 'مؤسسة سبأ للتوريدات',
      kind: PartnerKind.supplier,
      city: 'صنعاء',
      phone: '777333444',
      isCredit: true,
      creditLimit: 0,
      accountId: supp1Account.id,
      openingBalance: 0,
    );
    await partnersBoxRef.put(supp1.id, supp1);

    // إعدادات الشركة الافتراضية
    final company = CompanySettings();
    await prefs.setString(_kCompany, jsonEncode(company.toMap()));

    // تقدّم المستخدم
    final progress = UserProgress();
    await prefs.setString(_kProgress, jsonEncode(progress.toMap()));

    // عدّادات
    await prefs.setString(
      _kCounters,
      jsonEncode({
        'journal': 0,
        'invoice': 0,
        'voucher': 0,
        'customer': 1,
        'supplier': 1,
        'account': 0,
        'item': YemeniData.sampleItems.length,
      }),
    );
  }

  // ============ Counters ============
  static int nextCounter(String key) {
    final raw = prefs.getString(_kCounters) ?? '{}';
    final map = Map<String, dynamic>.from(jsonDecode(raw) as Map);
    final current = (map[key] as int? ?? 0) + 1;
    map[key] = current;
    prefs.setString(_kCounters, jsonEncode(map));
    return current;
  }

  // ============ Company ============
  static CompanySettings getCompany() {
    final raw = prefs.getString(_kCompany);
    if (raw == null) return CompanySettings();
    return CompanySettings.fromMap(
      Map<String, dynamic>.from(jsonDecode(raw) as Map),
    );
  }

  static Future<void> saveCompany(CompanySettings c) async {
    await prefs.setString(_kCompany, jsonEncode(c.toMap()));
  }

  // ============ Progress ============
  static UserProgress getProgress() {
    final raw = prefs.getString(_kProgress);
    if (raw == null) return UserProgress();
    return UserProgress.fromMap(
      Map<String, dynamic>.from(jsonDecode(raw) as Map),
    );
  }

  static Future<void> saveProgress(UserProgress p) async {
    await prefs.setString(_kProgress, jsonEncode(p.toMap()));
  }

  // ============ Intro Seen ============
  static bool isIntroSeen() => prefs.getBool(_kIntroSeen) ?? false;
  static Future<void> markIntroSeen() async => prefs.setBool(_kIntroSeen, true);

  // ============ Financial Accounting Section ============
  /// قائمة معرّفات التمارين المنجَزة في قسم المحاسبة المالية.
  static List<String> getFaCompletedExercises() {
    return prefs.getStringList(_kFaCompletedExercises) ?? const [];
  }

  static Future<void> setFaCompletedExercises(List<String> ids) async {
    await prefs.setStringList(_kFaCompletedExercises, ids);
  }

  /// قائمة معرّفات المستويات المنجَزة في قسم المحاسبة المالية.
  static List<String> getFaCompletedLessons() {
    return prefs.getStringList(_kFaCompletedLessons) ?? const [];
  }

  static Future<void> setFaCompletedLessons(List<String> ids) async {
    await prefs.setStringList(_kFaCompletedLessons, ids);
  }

  /// قيود يومية المحاكاة الخاصة بقسم المحاسبة المالية (JSON String).
  static String? getFaSimJournalRaw() => prefs.getString(_kSimJournalKey);

  static Future<void> setFaSimJournalRaw(String json) async {
    await prefs.setString(_kSimJournalKey, json);
  }

  static Future<void> clearFaSimJournal() async {
    await prefs.remove(_kSimJournalKey);
  }

  // اسم مستعار داخلي لتوحيد الاستخدام أعلاه.
  static const String _kSimJournalKey = _kFaSimJournal;

  // ============ Reset all data ============
  static Future<void> resetAll() async {
    await accountsBoxRef.clear();
    await journalsBoxRef.clear();
    await partnersBoxRef.clear();
    await itemsBoxRef.clear();
    await invoicesBoxRef.clear();
    await vouchersBoxRef.clear();
    await prefs.remove(_kInitialized);
    await prefs.remove(_kCompany);
    await prefs.remove(_kProgress);
    await prefs.remove(_kCounters);
    await _seedInitialData();
    await prefs.setBool(_kInitialized, true);
  }
}
