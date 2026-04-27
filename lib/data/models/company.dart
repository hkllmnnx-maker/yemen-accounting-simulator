/// إعدادات الشركة - تخزن في SharedPreferences
class CompanySettings {
  String name;
  String city;
  String baseCurrency;
  int fiscalYear;
  Map<String, double> exchangeRates; // معدلات الصرف بالنسبة للريال اليمني

  CompanySettings({
    this.name = 'مؤسسة النور التجارية',
    this.city = 'صنعاء',
    this.baseCurrency = 'YER',
    this.fiscalYear = 2024,
    Map<String, double>? exchangeRates,
  }) : exchangeRates = exchangeRates ??
            {
              'YER': 1.0,
              'USD': 530.0, // سعر الدولار بالريال اليمني (تقريبي تدريبي)
              'SAR': 141.0, // سعر الريال السعودي
            };

  Map<String, dynamic> toMap() => {
        'name': name,
        'city': city,
        'baseCurrency': baseCurrency,
        'fiscalYear': fiscalYear,
        'exchangeRates': exchangeRates,
      };

  factory CompanySettings.fromMap(Map<String, dynamic> m) => CompanySettings(
        name: m['name'] as String? ?? 'مؤسسة النور التجارية',
        city: m['city'] as String? ?? 'صنعاء',
        baseCurrency: m['baseCurrency'] as String? ?? 'YER',
        fiscalYear: m['fiscalYear'] as int? ?? 2024,
        exchangeRates: (m['exchangeRates'] as Map?)
            ?.map((k, v) => MapEntry(k as String, (v as num).toDouble())),
      );
}
