import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/partner.dart';
import '../../../providers/accounting_provider.dart';

class PartnerStatementScreen extends StatelessWidget {
  final String partnerId;
  const PartnerStatementScreen({super.key, required this.partnerId});

  @override
  Widget build(BuildContext context) {
    final acc = context.watch<AccountingProvider>();
    final p = acc.partnerById(partnerId);
    if (p == null) {
      return const Scaffold(body: Center(child: Text('الحساب غير موجود')));
    }
    // اجمع كل سطور القيود التي تخص هذا الحساب
    final movements = <_Move>[];
    for (final j in acc.journals.where((j) => j.posted)) {
      for (final l in j.lines) {
        if (l.accountId == p.accountId) {
          movements.add(_Move(
            date: j.date,
            desc: j.description,
            debit: l.debit,
            credit: l.credit,
            number: j.number,
            source: j.source,
          ));
        }
      }
    }
    movements.sort((a, b) => a.date.compareTo(b.date));
    double running = p.openingBalance;
    final isCustomer = p.kind == PartnerKind.customer;
    for (final m in movements) {
      // العميل: مدين => مديونية تزيد، دائن => تنقص
      // المورد: دائن => علينا تزيد، مدين => تنقص
      if (isCustomer) {
        running += m.debit - m.credit;
      } else {
        running += m.credit - m.debit;
      }
      m.balance = running;
    }
    final balance = isCustomer
        ? acc.accountBalance(p.accountId)
        : acc.accountBalance(p.accountId);

    return Scaffold(
      appBar: AppBar(
        title: Text('كشف حساب ${p.name}'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isCustomer
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : AppColors.warning.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('${p.city} • ${p.code} • ${p.currency}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('الرصيد الحالي: ',
                          style: TextStyle(fontSize: 13)),
                      Text(
                        Formatters.currency(balance.abs(), decimals: 0),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: balance > 0
                              ? (isCustomer
                                  ? AppColors.error
                                  : AppColors.warning)
                              : AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        balance > 0
                            ? (isCustomer ? '(مديونية)' : '(علينا)')
                            : (balance < 0
                                ? (isCustomer ? '(له لدينا)' : '(لنا لديه)')
                                : '(مسوّى)'),
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textLight),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Header row
            Container(
              color: AppColors.primary.withValues(alpha: 0.06),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: const Row(
                children: [
                  SizedBox(
                      width: 80,
                      child: Text('التاريخ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 11))),
                  Expanded(
                      child: Text('البيان',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 11))),
                  SizedBox(
                      width: 60,
                      child: Text('مدين',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              color: AppColors.debit))),
                  SizedBox(
                      width: 60,
                      child: Text('دائن',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              color: AppColors.credit))),
                  SizedBox(
                      width: 70,
                      child: Text('الرصيد',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 11))),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: movements.isEmpty
                  ? const Center(
                      child: Text(
                        'لا توجد حركات على هذا الحساب بعد',
                        style: TextStyle(color: AppColors.textLight),
                      ),
                    )
                  : ListView.separated(
                      itemCount: movements.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final m = movements[i];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                  width: 80,
                                  child: Text(Formatters.date(m.date),
                                      style: const TextStyle(fontSize: 11))),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(m.desc,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 12)),
                                    Text(m.source,
                                        style: const TextStyle(
                                            fontSize: 10,
                                            color: AppColors.textLight)),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 60,
                                child: Text(
                                  m.debit == 0
                                      ? '-'
                                      : Formatters.number(m.debit, decimals: 0),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 11, color: AppColors.debit),
                                ),
                              ),
                              SizedBox(
                                width: 60,
                                child: Text(
                                  m.credit == 0
                                      ? '-'
                                      : Formatters.number(m.credit, decimals: 0),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 11, color: AppColors.credit),
                                ),
                              ),
                              SizedBox(
                                width: 70,
                                child: Text(
                                  Formatters.number(m.balance, decimals: 0),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Move {
  final DateTime date;
  final String desc;
  final double debit;
  final double credit;
  final int number;
  final String source;
  double balance = 0;
  _Move({
    required this.date,
    required this.desc,
    required this.debit,
    required this.credit,
    required this.number,
    required this.source,
  });
}
