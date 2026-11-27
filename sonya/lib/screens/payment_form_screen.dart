import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/payment.dart';
import '../models/work_entry.dart';
import '../providers/app_provider.dart';
import '../providers/business_data_provider.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';

class PaymentFormScreen extends StatefulWidget {
  final String? initialCustomerId;
  final String? initialWorkId;

  const PaymentFormScreen({
    super.key,
    this.initialCustomerId,
    this.initialWorkId,
  });

  @override
  State<PaymentFormScreen> createState() => _PaymentFormScreenState();
}

class _PaymentFormScreenState extends State<PaymentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCustomerId;
  String? _selectedWorkId;
  late final TextEditingController _amountCtrl;
  late final TextEditingController _notesCtrl;
  DateTime _paymentDate = DateTime.now();
  PaymentMethod _method = PaymentMethod.cash;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedCustomerId = widget.initialCustomerId;
    _selectedWorkId = widget.initialWorkId;
    _amountCtrl = TextEditingController();
    _notesCtrl = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_selectedWorkId != null) {
        final data = context.read<BusinessDataProvider>();
        final work = data.workEntries
            .cast<WorkEntry?>()
            .firstWhere((w) => w?.id == _selectedWorkId, orElse: () => null);
        if (work != null && work.remainingBalance > 0) {
          _amountCtrl.text = work.remainingBalance.toStringAsFixed(0);
        }
      }
    });
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _paymentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) setState(() => _paymentDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCustomerId == null) return;

    final data = context.read<BusinessDataProvider>();
    final customer =
        data.customers.firstWhere((c) => c.id == _selectedCustomerId);
    final WorkEntry? work = _selectedWorkId == null
        ? null
        : data.workEntries.cast<WorkEntry?>().firstWhere(
              (w) => w?.id == _selectedWorkId,
              orElse: () => null,
            );

    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0.0;
    setState(() => _saving = true);

    try {
      final err = await data.addPayment(
        customer: customer,
        workEntry: work,
        amount: amount,
        paymentDate: _paymentDate,
        method: _method,
        notes: _notesCtrl.text.trim(),
      );

      if (!mounted) return;
      if (err != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err), backgroundColor: AppColors.expenseRed),
        );
      } else {
        Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final data = context.watch<BusinessDataProvider>();
    final s = app.strings;

    final customersWithBalance = data.customers
        .where((c) => data.customerRemainingBalance(c.id) > 0.01)
        .toList();
    final customerList = customersWithBalance.isNotEmpty
        ? customersWithBalance
        : data.customers;

    final pendingWorksForCustomer = _selectedCustomerId == null
        ? <WorkEntry>[]
        : data
            .workEntriesForCustomer(_selectedCustomerId!)
            .where((w) => w.remainingBalance > 0.01)
            .toList();

    final maxAllowed = _selectedWorkId != null
        ? (pendingWorksForCustomer
                .cast<WorkEntry?>()
                .firstWhere((w) => w?.id == _selectedWorkId, orElse: () => null)
                ?.remainingBalance ??
            0.0)
        : (_selectedCustomerId != null
            ? data.customerRemainingBalance(_selectedCustomerId!)
            : 0.0);

    return Scaffold(
      appBar: AppBar(title: Text(s.recordPayment)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              initialValue: customerList.any((c) => c.id == _selectedCustomerId)
                  ? _selectedCustomerId
                  : null,
              decoration: InputDecoration(
                labelText: '${s.selectCustomer} *',
                prefixIcon: const Icon(Icons.person_outline),
              ),
              items: customerList
                  .map(
                    (c) => DropdownMenuItem(
                      value: c.id,
                      child: Text(
                        '${c.name} (Due: ${AppFormatters.currency(data.customerRemainingBalance(c.id))})',
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (val) {
                setState(() {
                  _selectedCustomerId = val;
                  _selectedWorkId = null;
                  if (val != null) {
                    final bal = data.customerRemainingBalance(val);
                    if (bal > 0) {
                      _amountCtrl.text = bal.toStringAsFixed(0);
                    }
                  }
                });
              },
              validator: (v) => v == null ? 'ग्राहक निवडा' : null,
            ),
            const SizedBox(height: 14),
            if (_selectedCustomerId != null &&
                pendingWorksForCustomer.isNotEmpty) ...[
              DropdownButtonFormField<String?>(
                initialValue: pendingWorksForCustomer
                        .any((w) => w.id == _selectedWorkId)
                    ? _selectedWorkId
                    : null,
                decoration: InputDecoration(
                  labelText: s.selectWorkEntry,
                  prefixIcon: const Icon(Icons.agriculture_outlined),
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('बाकी बिलांवर आपोआप जमा करा'),
                  ),
                  ...pendingWorksForCustomer.map(
                    (w) => DropdownMenuItem<String?>(
                      value: w.id,
                      child: Text(
                        '${AppFormatters.date(w.workDate)} • ${w.quantityTons} टन • बाकी ${AppFormatters.currency(w.remainingBalance)}',
                      ),
                    ),
                  ),
                ],
                onChanged: (val) {
                  setState(() {
                    _selectedWorkId = val;
                    if (val != null) {
                      final w = pendingWorksForCustomer
                          .firstWhere((item) => item.id == val);
                      _amountCtrl.text =
                          w.remainingBalance.toStringAsFixed(0);
                    }
                  });
                },
              ),
              const SizedBox(height: 14),
            ],
            TextFormField(
              controller: _amountCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: '${s.paymentAmount} *',
                prefixIcon: const Icon(Icons.currency_rupee),
                helperText: _selectedCustomerId != null
                    ? 'जास्तीत जास्त देय: ${AppFormatters.currency(maxAllowed)}'
                    : null,
              ),
              validator: (v) {
                final val = double.tryParse(v ?? '');
                if (val == null || val <= 0) return 'योग्य रक्कम टाका';
                if (maxAllowed > 0 && val > maxAllowed + 0.01) {
                  return '${AppFormatters.currency(maxAllowed)} पेक्षा जास्त असू शकत नाही';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: s.paymentDate,
                  prefixIcon: const Icon(Icons.calendar_today),
                ),
                child: Text(AppFormatters.date(_paymentDate)),
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<PaymentMethod>(
              initialValue: _method,
              decoration: InputDecoration(
                labelText: s.paymentMethod,
                prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
              ),
              items: PaymentMethod.values
                  .map(
                    (m) => DropdownMenuItem(
                      value: m,
                      child: Text(m.label(app.languageCode)),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _method = v);
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _notesCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: s.notes,
                prefixIcon: const Icon(Icons.note_outlined),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                label: Text(s.save),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
