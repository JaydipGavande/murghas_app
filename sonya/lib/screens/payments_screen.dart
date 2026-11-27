import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../providers/business_data_provider.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/payment_card.dart';
import '../widgets/work_entry_card.dart';
import 'payment_form_screen.dart';
import 'work_detail_screen.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final data = context.watch<BusinessDataProvider>();
    final s = app.strings;

    final pending = data.pendingWorkEntries;
    final payments = data.payments;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(s.payments),
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: AppColors.limeGreen,
            tabs: [
              Tab(text: '${s.paymentHistory} (${payments.length})'),
              Tab(text: '${s.pendingPayments} (${pending.length})'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            payments.isEmpty
                ? EmptyStateWidget(
                    icon: Icons.payments_outlined,
                    title: 'पेमेंटची नोंद नाही',
                    subtitle:
                        'रोख, यूपीआय किंवा बँक ट्रान्सफरद्वारे ग्राहकांचे पेमेंट नोंदवा.',
                    actionLabel: s.recordPayment,
                    onAction: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PaymentFormScreen(),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
                    itemCount: payments.length,
                    itemBuilder: (_, i) {
                      final p = payments[i];
                      return PaymentCard(
                        payment: p,
                        lang: app.languageCode,
                        onDelete: () async {
                          final ok = await showConfirmDialog(
                            context,
                            title: s.confirmDelete,
                            message:
                                '${p.customerName} यांचे ${AppFormatters.currency(p.amount)} पेमेंट हटवायचे का? ग्राहकाची बाकी रक्कम आपोआप अपडेट होईल.',
                            confirmText: s.delete,
                            cancelText: s.cancel,
                          );
                          if (ok) {
                            await data.deletePayment(p);
                          }
                        },
                      );
                    },
                  ),
            pending.isEmpty
                ? const EmptyStateWidget(
                    icon: Icons.check_circle_outline,
                    title: 'सर्व पेमेंट पूर्ण जमा!',
                    subtitle: 'कोणत्याही ग्राहकाकडे बाकी रक्कम नाही.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
                    itemCount: pending.length,
                    itemBuilder: (_, i) {
                      final w = pending[i];
                      return WorkEntryCard(
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
                      );
                    },
                  ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PaymentFormScreen()),
          ),
          icon: const Icon(Icons.add),
          label: Text(s.recordPayment),
        ),
      ),
    );
  }
}
