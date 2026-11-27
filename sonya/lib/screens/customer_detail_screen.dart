import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/customer.dart';
import '../providers/app_provider.dart';
import '../providers/business_data_provider.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/payment_card.dart';
import '../widgets/work_entry_card.dart';
import 'customer_form_screen.dart';
import 'payment_form_screen.dart';
import 'work_detail_screen.dart';
import 'work_form_screen.dart';

class CustomerDetailScreen extends StatelessWidget {
  final String customerId;
  const CustomerDetailScreen({super.key, required this.customerId});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final data = context.watch<BusinessDataProvider>();
    final s = app.strings;

    final Customer? customer = data.customers
        .cast<Customer?>()
        .firstWhere((c) => c?.id == customerId, orElse: () => null);

    if (customer == null) {
      return Scaffold(
        appBar: AppBar(title: Text(s.customers)),
        body: const Center(child: Text('ग्राहक सापडला नाही')),
      );
    }

    final works = data.workEntriesForCustomer(customer.id);
    final payments = data.paymentsForCustomer(customer.id);
    final billed = data.customerTotalBilled(customer.id);
    final received = data.customerTotalReceived(customer.id);
    final balance = data.customerRemainingBalance(customer.id);
    final totalTons = data.customerTotalTons(customer.id);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(customer.name),
          actions: [
            IconButton(
              icon: const Icon(Icons.phone),
              onPressed: () async {
                final uri = Uri.parse('tel:${customer.mobile}');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CustomerFormScreen(customer: customer),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final ok = await showConfirmDialog(
                  context,
                  title: s.confirmDelete,
                  message:
                      '${customer.name} यांना हटवायचे का? त्यांच्या सर्व कामाच्या आणि पेमेंटच्या नोंदी देखील हटवल्या जातील.',
                  confirmText: s.delete,
                  cancelText: s.cancel,
                );
                if (ok && context.mounted) {
                  await data.deleteCustomer(customer.id);
                  if (context.mounted) Navigator.pop(context);
                }
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.deepGreen, AppColors.forestGreen],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.white70, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${customer.village}  •  ${customer.mobile}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                  if (customer.address.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      customer.address,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _summaryTile(s.totalBilled, AppFormatters.currency(billed)),
                      _summaryTile(
                          s.totalReceived, AppFormatters.currency(received)),
                      _summaryTile(
                        s.remainingBalance,
                        AppFormatters.currency(balance),
                        highlight: balance > 0,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'एकूण मका कटाई: ${AppFormatters.tonsFull(totalTons)} (${works.length} नोंदी)',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              WorkFormScreen(initialCustomerId: customer.id),
                        ),
                      ),
                      icon: const Icon(Icons.agriculture),
                      label: Text(s.newWork),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: balance <= 0
                          ? null
                          : () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PaymentFormScreen(
                                    initialCustomerId: customer.id,
                                  ),
                                ),
                              ),
                      icon: const Icon(Icons.payments),
                      label: Text(s.addPayment),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            TabBar(
              tabs: [
                Tab(text: '${s.workHistory} (${works.length})'),
                Tab(text: '${s.paymentHistory} (${payments.length})'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  works.isEmpty
                      ? const Center(child: Text('अजून कामाची नोंद नाही'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: works.length,
                          itemBuilder: (_, i) => WorkEntryCard(
                            work: works[i],
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    WorkDetailScreen(workId: works[i].id),
                              ),
                            ),
                          ),
                        ),
                  payments.isEmpty
                      ? const Center(child: Text('अजून पेमेंटची नोंद नाही'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: payments.length,
                          itemBuilder: (_, i) => PaymentCard(
                            payment: payments[i],
                            lang: app.languageCode,
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryTile(String label, String value, {bool highlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: highlight ? Colors.amberAccent : Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
