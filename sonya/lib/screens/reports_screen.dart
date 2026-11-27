import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../providers/business_data_provider.dart';
import '../services/pdf_service.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/stat_card.dart';

enum ReportPeriod { daily, weekly, monthly, all }

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  ReportPeriod _period = ReportPeriod.monthly;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final data = context.watch<BusinessDataProvider>();
    final s = app.strings;
    final now = DateTime.now();

    bool inPeriod(DateTime dt) {
      switch (_period) {
        case ReportPeriod.daily:
          return AppFormatters.isSameDay(dt, now);
        case ReportPeriod.weekly:
          final start = DateTime(now.year, now.month, now.day)
              .subtract(const Duration(days: 6));
          return !dt.isBefore(start);
        case ReportPeriod.monthly:
          return AppFormatters.isSameMonth(dt, now);
        case ReportPeriod.all:
          return true;
      }
    }

    final works = data.workEntries.where((w) => inPeriod(w.workDate)).toList();
    final expenses =
        data.expenses.where((e) => inPeriod(e.expenseDate)).toList();

    final totalTons = works.fold(0.0, (sum, w) => sum + w.quantityTons);
    final totalRevenue = works.fold(0.0, (sum, w) => sum + w.totalAmount);
    final totalExpenses = expenses.fold(0.0, (sum, e) => sum + e.amount);
    final netProfit = totalRevenue - totalExpenses;
    final pendingPayments =
        works.fold(0.0, (sum, w) => sum + w.remainingBalance);

    // Customer-wise summary for period
    final Map<String, Map<String, dynamic>> customerMap = {};
    for (final w in works) {
      final entry = customerMap.putIfAbsent(
        w.customerId,
        () => {
          'name': w.customerName,
          'village': w.village,
          'tons': 0.0,
          'billed': 0.0,
          'pending': 0.0,
        },
      );
      entry['tons'] = (entry['tons'] as double) + w.quantityTons;
      entry['billed'] = (entry['billed'] as double) + w.totalAmount;
      entry['pending'] = (entry['pending'] as double) + w.remainingBalance;
    }
    final customerSummary = customerMap.values.toList()
      ..sort((a, b) =>
          (b['billed'] as double).compareTo(a['billed'] as double));

    String periodLabel() {
      switch (_period) {
        case ReportPeriod.daily:
          return 'दैनिक (${AppFormatters.date(now)})';
        case ReportPeriod.weekly:
          return 'मागील ७ दिवस';
        case ReportPeriod.monthly:
          return 'मासिक (${AppFormatters.monthYear(now)})';
        case ReportPeriod.all:
          return 'संपूर्ण कालावधी';
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(s.reports),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: s.exportPdf,
            onPressed: () async {
              final pdfService = PdfService();
              final pdf = await pdfService.buildBusinessReportPdf(
                profile: app.profile,
                periodLabel: periodLabel(),
                totalTons: totalTons,
                totalRevenue: totalRevenue,
                totalExpenses: totalExpenses,
                netProfit: netProfit,
                pendingPayments: pendingPayments,
                customerSummary: customerSummary,
              );
              await pdfService.sharePdf(
                pdf,
                'murghas_report_${_period.name}.pdf',
                '${app.profile.businessName} - ${periodLabel()} Report',
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<ReportPeriod>(
            segments: const [
              ButtonSegment(value: ReportPeriod.daily, label: Text('दैनिक')),
              ButtonSegment(value: ReportPeriod.weekly, label: Text('साप्ताहिक')),
              ButtonSegment(
                  value: ReportPeriod.monthly, label: Text('मासिक')),
              ButtonSegment(value: ReportPeriod.all, label: Text('सर्व')),
            ],
            selected: {_period},
            onSelectionChanged: (v) => setState(() => _period = v.first),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.6,
            children: [
              StatCard(
                title: s.totalProduction,
                value: AppFormatters.tonsFull(totalTons),
                icon: Icons.grass,
                color: AppColors.deepGreen,
              ),
              StatCard(
                title: s.totalRevenue,
                value: AppFormatters.currency(totalRevenue),
                icon: Icons.trending_up,
                color: AppColors.revenueGreen,
              ),
              StatCard(
                title: s.totalExpenses,
                value: AppFormatters.currency(totalExpenses),
                icon: Icons.money_off,
                color: AppColors.expenseRed,
              ),
              StatCard(
                title: s.netProfit,
                value: AppFormatters.currency(netProfit),
                icon: Icons.account_balance,
                color: netProfit >= 0
                    ? AppColors.revenueGreen
                    : AppColors.expenseRed,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Card(
            child: ListTile(
              leading: const Icon(Icons.pending_actions,
                  color: AppColors.pendingAmber),
              title: Text(s.pendingPayments),
              trailing: Text(
                AppFormatters.currency(pendingPayments),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: AppColors.pendingAmber,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (totalRevenue > 0 || totalExpenses > 0)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'उत्पन्न विरुद्ध खर्च विभागणी',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 180,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 3,
                          centerSpaceRadius: 36,
                          sections: [
                            PieChartSectionData(
                              value: totalRevenue > 0 ? totalRevenue : 0.1,
                              color: AppColors.deepGreen,
                              title: 'उत्पन्न',
                              radius: 50,
                              titleStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            PieChartSectionData(
                              value: totalExpenses > 0 ? totalExpenses : 0.1,
                              color: AppColors.expenseRed,
                              title: 'खर्च',
                              radius: 50,
                              titleStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          Text(
            'ग्राहकनिहाय अहवाल',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          if (customerSummary.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: Text('या कालावधीत नोंदी नाहीत')),
              ),
            )
          else
            ...customerSummary.map(
              (row) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(
                    row['name'] as String,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    '${row['village']} • ${(row['tons'] as double).toStringAsFixed(1)} टन',
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        AppFormatters.currency(row['billed'] as double),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.deepGreen,
                        ),
                      ),
                      if ((row['pending'] as double) > 0)
                        Text(
                          'बाकी: ${AppFormatters.currency(row['pending'] as double)}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.pendingAmber,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () async {
                final pdfService = PdfService();
                final pdf = await pdfService.buildBusinessReportPdf(
                  profile: app.profile,
                  periodLabel: periodLabel(),
                  totalTons: totalTons,
                  totalRevenue: totalRevenue,
                  totalExpenses: totalExpenses,
                  netProfit: netProfit,
                  pendingPayments: pendingPayments,
                  customerSummary: customerSummary,
                );
                await pdfService.sharePdf(
                  pdf,
                  'murghas_report_${_period.name}.pdf',
                  '${app.profile.businessName} - ${periodLabel()} Report',
                );
              },
              icon: const Icon(Icons.picture_as_pdf),
              label: Text(s.exportPdf),
            ),
          ),
        ],
      ),
    );
  }
}
