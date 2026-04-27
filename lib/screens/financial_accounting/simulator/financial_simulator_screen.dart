import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import 'financial_analysis_screen.dart';
import 'financial_statements_screen.dart';
import 'journal_list_screen.dart';
import 'ledger_screen.dart';
import 'trial_balance_screen.dart';

/// شاشة المحاكاة العملية لقسم المحاسبة المالية.
/// تحوي 5 تبويبات:
/// - دفتر اليومية (إدخال + قائمة)
/// - دفتر الأستاذ
/// - ميزان المراجعة
/// - القوائم المالية
/// - التحليل المالي
class FinancialSimulatorScreen extends StatelessWidget {
  const FinancialSimulatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('شاشة المحاكاة العملية'),
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: AppColors.gold,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.book), text: 'اليومية'),
              Tab(icon: Icon(Icons.receipt_long), text: 'الأستاذ'),
              Tab(icon: Icon(Icons.balance), text: 'ميزان المراجعة'),
              Tab(
                  icon: Icon(Icons.account_balance),
                  text: 'القوائم المالية'),
              Tab(icon: Icon(Icons.analytics), text: 'التحليل'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            FaJournalListScreen(),
            FaLedgerScreen(),
            FaTrialBalanceScreen(),
            FaFinancialStatementsScreen(),
            FaFinancialAnalysisScreen(),
          ],
        ),
      ),
    );
  }
}
