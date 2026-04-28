import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/company.dart';
import '../../data/seed/yemeni_data.dart';
import '../../providers/accounting_provider.dart';
import '../../providers/progress_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _yearCtrl;
  late String _city;
  late String _currency;
  late TextEditingController _usdRate;
  late TextEditingController _sarRate;

  @override
  void initState() {
    super.initState();
    final c = context.read<AccountingProvider>().company;
    _nameCtrl = TextEditingController(text: c.name);
    _yearCtrl = TextEditingController(text: c.fiscalYear.toString());
    _city = c.city;
    _currency = c.baseCurrency;
    _usdRate = TextEditingController(
        text: (c.exchangeRates['USD'] ?? 530).toString());
    _sarRate = TextEditingController(
        text: (c.exchangeRates['SAR'] ?? 141).toString());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _yearCtrl.dispose();
    _usdRate.dispose();
    _sarRate.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final acc = context.read<AccountingProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final newSettings = CompanySettings(
      name: _nameCtrl.text.trim().isEmpty
          ? YemeniData.defaultCompanyName
          : _nameCtrl.text.trim(),
      city: _city,
      baseCurrency: _currency,
      fiscalYear: int.tryParse(_yearCtrl.text) ?? 2024,
      exchangeRates: {
        'YER': 1.0,
        'USD': double.tryParse(_usdRate.text) ?? 530,
        'SAR': double.tryParse(_sarRate.text) ?? 141,
      },
    );
    await acc.saveCompany(newSettings);
    if (!mounted) return;
    messenger.showSnackBar(
      const SnackBar(content: Text('تم حفظ الإعدادات')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.settings)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _Section(title: 'بيانات الشركة', icon: Icons.business),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'اسم الشركة'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _city,
              decoration: const InputDecoration(labelText: 'المدينة'),
              items: YemeniData.cities
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _city = v ?? _city),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _currency,
              decoration: const InputDecoration(labelText: 'العملة الأساسية'),
              items: const [
                DropdownMenuItem(value: 'YER', child: Text('ريال يمني (YER)')),
                DropdownMenuItem(value: 'USD', child: Text('دولار أمريكي (USD)')),
                DropdownMenuItem(value: 'SAR', child: Text('ريال سعودي (SAR)')),
              ],
              onChanged: (v) => setState(() => _currency = v ?? _currency),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _yearCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'السنة المالية'),
            ),
            const SizedBox(height: 24),
            const _Section(title: 'أسعار الصرف (مقابل الريال اليمني)',
                icon: Icons.currency_exchange),
            TextField(
              controller: _usdRate,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'سعر الدولار',
                suffixText: 'ر.ي',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _sarRate,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'سعر الريال السعودي',
                suffixText: 'ر.ي',
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text(AppStrings.save),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _save,
              ),
            ),
            const SizedBox(height: 12),
            const Divider(),
            const _Section(title: 'إدارة البيانات',
                icon: Icons.settings_backup_restore),
            Card(
              color: AppColors.errorLight,
              child: ListTile(
                leading: const Icon(Icons.delete_forever, color: AppColors.error),
                title: const Text(
                  'إعادة ضبط البيانات والتدريب',
                  style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('يحذف كل البيانات ويعيد البيانات الافتراضية'),
                onTap: () => _confirmReset(context),
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'محاكي المحاسبة اليمني • الإصدار 1.0.0',
                style: TextStyle(color: AppColors.textLight, fontSize: 12),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                'العملة الافتراضية: ${Formatters.currencyName(_currency)}',
                style:
                    const TextStyle(color: AppColors.textLight, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    // Capture providers BEFORE the async showDialog to avoid using the
    // BuildContext across async gaps later.
    final accProvider = context.read<AccountingProvider>();
    final progProvider = context.read<ProgressProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('تأكيد إعادة الضبط'),
        content: const Text(
            'سيتم حذف جميع العملاء، الموردين، الفواتير، السندات، القيود، وتقدّم التدريب. هل أنت متأكد؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text(AppStrings.confirm),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await accProvider.resetAll();
    await progProvider.resetProgress();
    if (!mounted) return;
    messenger.showSnackBar(
      const SnackBar(content: Text('تمت إعادة الضبط')),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  const _Section({required this.title, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: AppColors.textPrimary,
              )),
        ],
      ),
    );
  }
}
