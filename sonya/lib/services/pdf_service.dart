import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/business_profile.dart';
import '../models/payment.dart';
import '../models/work_entry.dart';
import '../utils/formatters.dart';

class PdfService {
  static final PdfColor _deepGreen = PdfColor.fromHex('#1B5E20');
  static final PdfColor _limeGreen = PdfColor.fromHex('#7CB342');
  static final PdfColor _lightCream = PdfColor.fromHex('#F4F8EF');
  static final PdfColor _borderGrey = PdfColor.fromHex('#D5E0D0');

  Future<pw.ThemeData> _buildTheme() async {
    try {
      final base = await PdfGoogleFonts.notoSansDevanagariRegular();
      final bold = await PdfGoogleFonts.notoSansDevanagariBold();
      return pw.ThemeData.withFont(base: base, bold: bold);
    } catch (_) {
      return pw.ThemeData.base();
    }
  }

  Future<pw.Document> buildWorkReceiptPdf({
    required BusinessProfile profile,
    required WorkEntry work,
    List<Payment> payments = const [],
  }) async {
    final theme = await _buildTheme();
    final pdf = pw.Document(theme: theme);

    pw.MemoryImage? logoImage;
    if (!kIsWeb &&
        profile.logoPath != null &&
        File(profile.logoPath!).existsSync()) {
      logoImage = pw.MemoryImage(File(profile.logoPath!).readAsBytesSync());
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // Header Banner
              pw.Container(
                padding: const pw.EdgeInsets.all(18),
                decoration: pw.BoxDecoration(
                  color: _deepGreen,
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Row(
                      children: [
                        if (logoImage != null) ...[
                          pw.Container(
                            width: 48,
                            height: 48,
                            decoration: pw.BoxDecoration(
                              color: PdfColors.white,
                              borderRadius: pw.BorderRadius.circular(8),
                            ),
                            padding: const pw.EdgeInsets.all(3),
                            child: pw.Image(logoImage, fit: pw.BoxFit.contain),
                          ),
                          pw.SizedBox(width: 12),
                        ],
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              profile.businessName.toUpperCase(),
                              style: pw.TextStyle(
                                color: PdfColors.white,
                                fontSize: 18,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            if (profile.ownerName.isNotEmpty)
                              pw.Text(
                                'प्रोप्रा: ${profile.ownerName}',
                                style: const pw.TextStyle(
                                  color: PdfColors.white,
                                  fontSize: 10,
                                ),
                              )
                            else
                              pw.Text(
                                'प्रोप्रा: सोन्या',
                                style: const pw.TextStyle(
                                  color: PdfColors.white,
                                  fontSize: 10,
                                ),
                              ),
                            if (profile.mobile.isNotEmpty ||
                                profile.village.isNotEmpty)
                              pw.Text(
                                [
                                  if (profile.village.isNotEmpty) profile.village,
                                  if (profile.mobile.isNotEmpty)
                                    'Mo: ${profile.mobile}',
                                ].join(' | '),
                                style: const pw.TextStyle(
                                  color: PdfColors.white,
                                  fontSize: 10,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: pw.BoxDecoration(
                        color: _limeGreen,
                        borderRadius: pw.BorderRadius.circular(6),
                      ),
                      child: pw.Text(
                        'MURGHAS RECEIPT',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 18),

              // Customer & Work Info
              pw.Container(
                padding: const pw.EdgeInsets.all(14),
                decoration: pw.BoxDecoration(
                  color: _lightCream,
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: _borderGrey),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'CUSTOMER DETAILS',
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: _deepGreen,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          work.customerName,
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text('Mobile: ${work.customerMobile}'),
                        pw.Text('Village: ${work.village}'),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'WORK DETAILS',
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: _deepGreen,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text('Date: ${AppFormatters.date(work.workDate)}'),
                        pw.Text('Machine: ${work.machineName}'),
                        pw.Text(
                          'Receipt #: ${work.id.substring(0, 8).toUpperCase()}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 18),

              // Billing Table
              pw.Table(
                border: pw.TableBorder.all(color: _borderGrey),
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: _deepGreen),
                    children: [
                      _tableHeader('Description'),
                      _tableHeader('Quantity / Details', alignRight: true),
                      _tableHeader('Amount', alignRight: true),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _tableCell('Maize Silage (Murghas) Cutting'),
                      _tableCell(
                        '${work.quantityTons.toStringAsFixed(2)} Tons × ${AppFormatters.currency(work.ratePerTon)}',
                        alignRight: true,
                      ),
                      _tableCell(
                        AppFormatters.currency(work.quantityTons * work.ratePerTon),
                        alignRight: true,
                      ),
                    ],
                  ),
                  if (work.additionalCharges > 0)
                    pw.TableRow(
                      children: [
                        _tableCell('Additional Charges'),
                        _tableCell('-', alignRight: true),
                        _tableCell(
                          AppFormatters.currency(work.additionalCharges),
                          alignRight: true,
                        ),
                      ],
                    ),
                  if (work.discount > 0)
                    pw.TableRow(
                      children: [
                        _tableCell('Discount'),
                        _tableCell('-', alignRight: true),
                        _tableCell(
                          '- ${AppFormatters.currency(work.discount)}',
                          alignRight: true,
                        ),
                      ],
                    ),
                ],
              ),
              pw.SizedBox(height: 14),

              // Totals Box
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Container(
                  width: 240,
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: _lightCream,
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(color: _borderGrey),
                  ),
                  child: pw.Column(
                    children: [
                      _summaryRow(
                        'Total Bill Amount',
                        AppFormatters.currency(work.totalAmount),
                        bold: true,
                      ),
                      pw.SizedBox(height: 4),
                      _summaryRow(
                        'Received Amount',
                        AppFormatters.currency(work.receivedAmount),
                      ),
                      pw.Divider(color: _borderGrey),
                      _summaryRow(
                        'Remaining Balance',
                        AppFormatters.currency(work.remainingBalance),
                        bold: true,
                        valueColor: work.remainingBalance > 0
                            ? PdfColors.red800
                            : _deepGreen,
                      ),
                    ],
                  ),
                ),
              ),

              if (payments.isNotEmpty) ...[
                pw.SizedBox(height: 18),
                pw.Text(
                  'PAYMENT HISTORY',
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    color: _deepGreen,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Table(
                  border: pw.TableBorder.all(color: _borderGrey),
                  children: [
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: _lightCream),
                      children: [
                        _tableCell('Date', bold: true),
                        _tableCell('Method', bold: true),
                        _tableCell('Notes', bold: true),
                        _tableCell('Amount', alignRight: true, bold: true),
                      ],
                    ),
                    ...payments.map(
                      (pay) => pw.TableRow(
                        children: [
                          _tableCell(AppFormatters.date(pay.paymentDate)),
                          _tableCell(pay.method.labelEn),
                          _tableCell(pay.notes.isEmpty ? '-' : pay.notes),
                          _tableCell(
                            AppFormatters.currency(pay.amount),
                            alignRight: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],

              if (work.notes.isNotEmpty) ...[
                pw.SizedBox(height: 12),
                pw.Text(
                  'Notes: ${work.notes}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],

              pw.Spacer(),
              pw.Divider(color: _borderGrey),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Thank you for your business!',
                    style: pw.TextStyle(
                      color: _deepGreen,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                  pw.Text(
                    'Generated by ${profile.businessName}',
                    style: const pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
    return pdf;
  }

  Future<pw.Document> buildBusinessReportPdf({
    required BusinessProfile profile,
    required String periodLabel,
    required double totalTons,
    required double totalRevenue,
    required double totalExpenses,
    required double netProfit,
    required double pendingPayments,
    required List<Map<String, dynamic>> customerSummary,
  }) async {
    final theme = await _buildTheme();
    final pdf = pw.Document(theme: theme);
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (context) => [
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: _deepGreen,
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      profile.businessName,
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'Business Report - $periodLabel',
                      style: const pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                pw.Text(
                  'Date: ${AppFormatters.date(DateTime.now())}',
                  style: const pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 16),
          pw.Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _kpiBox('Total Production', AppFormatters.tonsFull(totalTons)),
              _kpiBox('Total Revenue', AppFormatters.currency(totalRevenue)),
              _kpiBox('Total Expenses', AppFormatters.currency(totalExpenses)),
              _kpiBox('Net Profit', AppFormatters.currency(netProfit)),
              _kpiBox(
                'Pending Payments',
                AppFormatters.currency(pendingPayments),
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            'Customer-wise Business Summary',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: _deepGreen,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(color: _borderGrey),
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: _deepGreen),
                children: [
                  _tableHeader('Customer'),
                  _tableHeader('Village'),
                  _tableHeader('Tons', alignRight: true),
                  _tableHeader('Billed', alignRight: true),
                  _tableHeader('Pending', alignRight: true),
                ],
              ),
              ...customerSummary.map(
                (row) => pw.TableRow(
                  children: [
                    _tableCell(row['name'] as String),
                    _tableCell(row['village'] as String),
                    _tableCell(
                      (row['tons'] as double).toStringAsFixed(1),
                      alignRight: true,
                    ),
                    _tableCell(
                      AppFormatters.currency(row['billed'] as double),
                      alignRight: true,
                    ),
                    _tableCell(
                      AppFormatters.currency(row['pending'] as double),
                      alignRight: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
    return pdf;
  }

  Future<File> savePdfToFile(pw.Document pdf, String fileName) async {
    if (kIsWeb) {
      final bytes = await pdf.save();
      await Printing.sharePdf(bytes: bytes, filename: fileName);
      return File(fileName);
    }
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, fileName));
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  Future<void> sharePdf(pw.Document pdf, String fileName, String text) async {
    if (kIsWeb) {
      final bytes = await pdf.save();
      await Printing.sharePdf(bytes: bytes, filename: fileName);
      return;
    }
    final dir = await getTemporaryDirectory();
    final file = File(p.join(dir.path, fileName));
    await file.writeAsBytes(await pdf.save());
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/pdf')],
        text: text,
      ),
    );
  }

  Future<void> printPdf(pw.Document pdf, String title) async {
    await Printing.layoutPdf(
      name: title,
      onLayout: (format) async => pdf.save(),
    );
  }

  Future<void> shareViaWhatsAppText({
    required BusinessProfile profile,
    required WorkEntry work,
  }) async {
    final message =
        '*${profile.businessName}*\n'
        'Murghas Cutting Receipt\n'
        'Customer: ${work.customerName} (${work.village})\n'
        'Date: ${AppFormatters.date(work.workDate)}\n'
        'Machine: ${work.machineName}\n'
        'Quantity: ${work.quantityTons.toStringAsFixed(2)} Tons @ ${AppFormatters.currency(work.ratePerTon)}/Ton\n'
        'Total Bill: ${AppFormatters.currency(work.totalAmount)}\n'
        'Received: ${AppFormatters.currency(work.receivedAmount)}\n'
        'Remaining Balance: ${AppFormatters.currency(work.remainingBalance)}\n'
        'Thank you!';

    final digits = work.customerMobile.replaceAll(RegExp(r'\D'), '');
    final phone = digits.length == 10 ? '91$digits' : digits;
    final uri = Uri.parse(
      'https://wa.me/$phone?text=${Uri.encodeComponent(message)}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      await SharePlus.instance.share(ShareParams(text: message));
    }
  }

  pw.Widget _tableHeader(String text, {bool alignRight = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        textAlign: alignRight ? pw.TextAlign.right : pw.TextAlign.left,
        style: pw.TextStyle(
          color: PdfColors.white,
          fontWeight: pw.FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  pw.Widget _tableCell(
    String text, {
    bool alignRight = false,
    bool bold = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        textAlign: alignRight ? pw.TextAlign.right : pw.TextAlign.left,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  pw.Widget _summaryRow(
    String label,
    String value, {
    bool bold = false,
    PdfColor? valueColor,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 11,
            color: valueColor ?? PdfColors.black,
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
      ],
    );
  }

  pw.Widget _kpiBox(String label, String value) {
    return pw.Container(
      width: 165,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: _lightCream,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: _borderGrey),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
              color: _deepGreen,
            ),
          ),
        ],
      ),
    );
  }
}
