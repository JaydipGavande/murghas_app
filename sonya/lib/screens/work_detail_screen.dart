import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/work_entry.dart';
import '../providers/app_provider.dart';
import '../providers/business_data_provider.dart';
import '../services/pdf_service.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/payment_card.dart';
import 'payment_form_screen.dart';
import 'work_form_screen.dart';

class WorkDetailScreen extends StatelessWidget {
  final String workId;
  const WorkDetailScreen({super.key, required this.workId});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final data = context.watch<BusinessDataProvider>();
    final s = app.strings;
    final pdfService = PdfService();

    final WorkEntry? work = data.workEntries
        .cast<WorkEntry?>()
        .firstWhere((w) => w?.id == workId, orElse: () => null);

    if (work == null) {
      return Scaffold(
        appBar: AppBar(title: Text(s.work)),
        body: const Center(child: Text('कामाची नोंद सापडली नाही')),
      );
    }

    final payments = data.paymentsForWork(work.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(work.customerName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => WorkFormScreen(workEntry: work),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final ok = await showConfirmDialog(
                context,
                title: s.confirmDelete,
                message: 'ही कामाची नोंद आणि संबंधित पेमेंट्स हटवायचे का?',
                confirmText: s.delete,
                cancelText: s.cancel,
              );
              if (ok && context.mounted) {
                await data.deleteWorkEntry(work.id);
                if (context.mounted) Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppFormatters.date(work.workDate),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Chip(
                        label: Text(
                          work.isPaid ? 'पूर्ण जमा' : 'येणे बाकी',
                          style: TextStyle(
                            color: work.isPaid
                                ? AppColors.revenueGreen
                                : AppColors.pendingAmber,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  _row('ग्राहक', work.customerName),
                  _row('मोबाईल', work.customerMobile),
                  _row('गाव', work.village),
                  _row('मशीन / ट्रॅक्टर', work.machineName),
                  _row('प्रमाण', AppFormatters.tonsFull(work.quantityTons)),
                  _row('दर प्रति टन', AppFormatters.currency(work.ratePerTon)),
                  if (work.additionalCharges > 0)
                    _row(
                      'अतिरिक्त शुल्क',
                      AppFormatters.currency(work.additionalCharges),
                    ),
                  if (work.discount > 0)
                    _row('सवलत', '- ${AppFormatters.currency(work.discount)}'),
                  const Divider(),
                  _row(
                    s.totalBillAmount,
                    AppFormatters.currency(work.totalAmount),
                    bold: true,
                  ),
                  _row(
                    s.totalReceived,
                    AppFormatters.currency(work.receivedAmount),
                    color: AppColors.revenueGreen,
                  ),
                  _row(
                    s.remainingBalance,
                    AppFormatters.currency(work.remainingBalance),
                    bold: true,
                    color: work.remainingBalance > 0
                        ? AppColors.pendingAmber
                        : AppColors.revenueGreen,
                  ),
                  if (work.notes.isNotEmpty) ...[
                    const Divider(),
                    Text('टीप: ${work.notes}'),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          if (!work.isPaid)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PaymentFormScreen(
                        initialCustomerId: work.customerId,
                        initialWorkId: work.id,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.payments),
                  label: Text(s.recordPayment),
                ),
              ),
            ),

          // PDF & WhatsApp Actions
          Text(
            'पावती आणि शेअरिंग',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  final pdf = await pdfService.buildWorkReceiptPdf(
                    profile: app.profile,
                    work: work,
                    payments: payments,
                  );
                  await pdfService.sharePdf(
                    pdf,
                    'receipt_${work.id.substring(0, 8)}.pdf',
                    'Murghas Receipt for ${work.customerName}',
                  );
                },
                icon: const Icon(Icons.picture_as_pdf),
                label: Text(s.sharePdf),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  final pdf = await pdfService.buildWorkReceiptPdf(
                    profile: app.profile,
                    work: work,
                    payments: payments,
                  );
                  final file = await pdfService.savePdfToFile(
                    pdf,
                    'receipt_${work.id.substring(0, 8)}.pdf',
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('PDF सेव्ह केली: ${file.path}')),
                    );
                  }
                },
                icon: const Icon(Icons.download),
                label: Text(s.downloadPdf),
              ),
              OutlinedButton.icon(
                onPressed: () => pdfService.shareViaWhatsAppText(
                  profile: app.profile,
                  work: work,
                ),
                icon: const Icon(Icons.chat, color: AppColors.revenueGreen),
                label: Text(s.shareWhatsApp),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  final pdf = await pdfService.buildWorkReceiptPdf(
                    profile: app.profile,
                    work: work,
                    payments: payments,
                  );
                  await pdfService.printPdf(
                    pdf,
                    'Receipt_${work.customerName}',
                  );
                },
                icon: const Icon(Icons.print),
                label: Text(s.printReceipt),
              ),
            ],
          ),

          if (payments.isNotEmpty) ...[
            const SizedBox(height: 18),
            Text(
              s.paymentHistory,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            ...payments.map(
              (p) => PaymentCard(payment: p, lang: app.languageCode),
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              fontSize: bold ? 16 : 14,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
