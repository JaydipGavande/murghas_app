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
            icon: const Icon(Icons.print_outlined),
            tooltip: s.printReceipt,
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
          ),
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
          // Clean Summary Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              work.customerName,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${work.village} • ${work.customerMobile}',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: (work.isPaid
                                  ? AppColors.revenueGreen
                                  : AppColors.pendingAmber)
                              .withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          work.isPaid ? 'पूर्ण जमा' : 'येणे बाकी',
                          style: TextStyle(
                            color: work.isPaid
                                ? AppColors.revenueGreen
                                : AppColors.pendingAmber,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.deepGreen.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _amountBox(
                          'एकूण बिल',
                          AppFormatters.currency(work.totalAmount),
                          AppColors.deepGreen,
                        ),
                        _amountBox(
                          'जमा',
                          AppFormatters.currency(work.receivedAmount),
                          AppColors.revenueGreen,
                        ),
                        _amountBox(
                          'बाकी',
                          AppFormatters.currency(work.remainingBalance),
                          work.remainingBalance > 0
                              ? AppColors.pendingAmber
                              : AppColors.revenueGreen,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Simple Work Details Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _row('तारीख', AppFormatters.date(work.workDate)),
                  _row('मशीन / ट्रॅक्टर', work.machineName),
                  _row(
                    'कटाई प्रमाण',
                    '${AppFormatters.tonsFull(work.quantityTons)} × ${AppFormatters.currency(work.ratePerTon)}',
                  ),
                  if (work.additionalCharges > 0)
                    _row(
                      'अतिरिक्त शुल्क',
                      AppFormatters.currency(work.additionalCharges),
                    ),
                  if (work.discount > 0)
                    _row('सवलत', '- ${AppFormatters.currency(work.discount)}'),
                  if (work.notes.isNotEmpty) _row('टीप', work.notes),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          if (!work.isPaid)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
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

          // Clean 2-Button PDF Row
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final pdf = await pdfService.buildWorkReceiptPdf(
                      profile: app.profile,
                      work: work,
                      payments: payments,
                    );
                    await pdfService.sharePdf(
                      pdf,
                      'receipt_${work.id.substring(0, 8)}.pdf',
                      '${app.profile.businessName} - ${work.customerName} यांची मुरघास पावती',
                    );
                  },
                  icon: const Icon(Icons.picture_as_pdf),
                  label: Text(s.sharePdf),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
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
              ),
            ],
          ),

          if (payments.isNotEmpty) ...[
            const SizedBox(height: 20),
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

  Widget _amountBox(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
