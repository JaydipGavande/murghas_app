import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../providers/business_data_provider.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/payment_card.dart';
import '../widgets/revenue_expense_chart.dart';
import '../widgets/stat_card.dart';
import '../widgets/work_entry_card.dart';
import 'customer_form_screen.dart';
import 'expense_form_screen.dart';
import 'payment_form_screen.dart';
import 'work_detail_screen.dart';
import 'work_form_screen.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback onNavigateToWork;
  final VoidCallback onNavigateToPayments;
  final VoidCallback onNavigateToCustomers;

  const DashboardScreen({
    super.key,
    required this.onNavigateToWork,
    required this.onNavigateToPayments,
    required this.onNavigateToCustomers,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isWeeklyChart = true;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final data = context.watch<BusinessDataProvider>();
    final s = app.strings;
    final theme = Theme.of(context);

    if (data.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (data.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('त्रुटी: ${data.error}'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: data.loadAll,
              child: const Text('पुन्हा प्रयत्न करा'),
            ),
          ],
        ),
      );
    }

    final chartPoints = data.getChartPoints(isWeekly: _isWeeklyChart);
    final recentWorks = data.workEntries.take(4).toList();
    final recentPayments = data.payments.take(4).toList();
    final pendingWorks = data.pendingWorkEntries.take(5).toList();

    return RefreshIndicator(
      onRefresh: data.loadAll,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.deepGreen, AppColors.forestGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(26),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.agriculture,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                app.profile.businessName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                app.profile.village.isNotEmpty
                                    ? '${app.profile.ownerName} • ${app.profile.village}'
                                    : app.profile.ownerName,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.netProfit,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  AppFormatters.currency(data.netProfit),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.limeGreen,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  s.totalProduction,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  AppFormatters.tonsFull(data.totalProductionTons),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Quick Actions
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.quickActions,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _quickAction(
                        context,
                        Icons.add_circle_outline,
                        s.newWork,
                        AppColors.deepGreen,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const WorkFormScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _quickAction(
                        context,
                        Icons.payments_outlined,
                        s.addPayment,
                        AppColors.revenueGreen,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PaymentFormScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _quickAction(
                        context,
                        Icons.receipt_long_outlined,
                        s.addExpense,
                        AppColors.expenseRed,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ExpenseFormScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _quickAction(
                        context,
                        Icons.person_add_outlined,
                        s.addCustomer,
                        AppColors.infoBlue,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CustomerFormScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // KPI Grid (All 8 metrics)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.55,
              children: [
                StatCard(
                  title: s.totalRevenue,
                  value: AppFormatters.currency(data.totalRevenue),
                  subtitle: 'जमा: ${AppFormatters.currency(data.totalCollected)}',
                  icon: Icons.trending_up,
                  color: AppColors.revenueGreen,
                  onTap: widget.onNavigateToWork,
                ),
                StatCard(
                  title: s.totalExpenses,
                  value: AppFormatters.currency(data.totalExpenses),
                  icon: Icons.account_balance_wallet_outlined,
                  color: AppColors.expenseRed,
                ),
                StatCard(
                  title: s.pendingPayments,
                  value: AppFormatters.currency(data.totalPendingPayments),
                  subtitle: '${data.pendingWorkEntries.length} बिले बाकी',
                  icon: Icons.pending_actions,
                  color: AppColors.pendingAmber,
                  onTap: widget.onNavigateToPayments,
                ),
                StatCard(
                  title: s.totalCustomers,
                  value: '${data.totalCustomers}',
                  subtitle: '${data.distinctVillages.length} गावे',
                  icon: Icons.people_outline,
                  color: AppColors.infoBlue,
                  onTap: widget.onNavigateToCustomers,
                ),
                StatCard(
                  title: s.todaysWork,
                  value: AppFormatters.tons(data.todaysWorkTons),
                  subtitle: AppFormatters.currency(data.todaysWorkAmount),
                  icon: Icons.today,
                  color: AppColors.deepGreen,
                  onTap: widget.onNavigateToWork,
                ),
                StatCard(
                  title: s.thisMonthsWork,
                  value: AppFormatters.tons(data.thisMonthWorkTons),
                  subtitle: AppFormatters.currency(data.thisMonthWorkAmount),
                  icon: Icons.calendar_month,
                  color: AppColors.limeGreen,
                  onTap: widget.onNavigateToWork,
                ),
              ],
            ),
          ),

          // Revenue & Expense Chart
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              s.revenueVsExpense,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          SegmentedButton<bool>(
                            segments: [
                              ButtonSegment(value: true, label: Text(s.weekly)),
                              ButtonSegment(value: false, label: Text(s.monthly)),
                            ],
                            selected: {_isWeeklyChart},
                            onSelectionChanged: (val) {
                              setState(() => _isWeeklyChart = val.first);
                            },
                            style: const ButtonStyle(
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _legendDot(AppColors.deepGreen, s.totalRevenue),
                          const SizedBox(width: 16),
                          _legendDot(AppColors.pendingAmber, s.totalExpenses),
                        ],
                      ),
                      const SizedBox(height: 14),
                      RevenueExpenseChart(points: chartPoints),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Pending Payments List
          if (pendingWorks.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          s.pendingList,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        TextButton(
                          onPressed: widget.onNavigateToPayments,
                          child: const Text('सगळे पहा'),
                        ),
                      ],
                    ),
                    ...pendingWorks.map(
                      (w) => WorkEntryCard(
                        work: w,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WorkDetailScreen(workId: w.id),
                          ),
                        ),
                        onCollectPayment: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PaymentFormScreen(
                              initialCustomerId: w.customerId,
                              initialWorkId: w.id,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Recent Work Entries
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        s.recentWork,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      TextButton(
                        onPressed: widget.onNavigateToWork,
                        child: const Text('सर्व पहा'),
                      ),
                    ],
                  ),
                  if (recentWorks.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Center(
                          child: Text(
                            'अजून कामाची नोंद नाही. नवीन मुरघास कटाई काम नोंदवण्यासाठी "${s.newWork}" वर क्लिक करा.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    )
                  else
                    ...recentWorks.map(
                      (w) => WorkEntryCard(
                        work: w,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WorkDetailScreen(workId: w.id),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Recent Payments
          if (recentPayments.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          s.recentPayments,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        TextButton(
                          onPressed: widget.onNavigateToPayments,
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    ...recentPayments.map(
                      (p) => PaymentCard(payment: p, lang: app.languageCode),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _quickAction(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.11),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
