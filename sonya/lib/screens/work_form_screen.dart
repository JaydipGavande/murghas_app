import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/customer.dart';
import '../models/payment.dart';
import '../models/work_entry.dart';
import '../providers/app_provider.dart';
import '../providers/business_data_provider.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';
import 'customer_form_screen.dart';

class WorkFormScreen extends StatefulWidget {
  final WorkEntry? workEntry;
  final String? initialCustomerId;

  const WorkFormScreen({
    super.key,
    this.workEntry,
    this.initialCustomerId,
  });

  @override
  State<WorkFormScreen> createState() => _WorkFormScreenState();
}

class _WorkFormScreenState extends State<WorkFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCustomerId;
  late DateTime _workDate;
  late final TextEditingController _machineCtrl;
  late final TextEditingController _qtyCtrl;
  late final TextEditingController _rateCtrl;
  late final TextEditingController _extraCtrl;
  late final TextEditingController _discountCtrl;
  late final TextEditingController _advanceCtrl;
  late final TextEditingController _notesCtrl;
  PaymentMethod _advanceMethod = PaymentMethod.cash;
  bool _saving = false;

  bool get isEditing => widget.workEntry != null;

  @override
  void initState() {
    super.initState();
    final w = widget.workEntry;
    final defaultRate =
        context.read<AppProvider>().profile.defaultRatePerTon;

    _selectedCustomerId = w?.customerId ?? widget.initialCustomerId;
    _workDate = w?.workDate ?? DateTime.now();
    _machineCtrl = TextEditingController(text: w?.machineName ?? 'ट्रॅक्टर हार्वेस्टर');
    _qtyCtrl = TextEditingController(
      text: w != null ? w.quantityTons.toString() : '',
    );
    _rateCtrl = TextEditingController(
      text: (w?.ratePerTon ?? defaultRate).toStringAsFixed(0),
    );
    _extraCtrl = TextEditingController(
      text: w != null && w.additionalCharges > 0
          ? w.additionalCharges.toStringAsFixed(0)
          : '0',
    );
    _discountCtrl = TextEditingController(
      text: w != null && w.discount > 0 ? w.discount.toStringAsFixed(0) : '0',
    );
    _advanceCtrl = TextEditingController(
      text: w != null ? w.receivedAmount.toStringAsFixed(0) : '0',
    );
    _notesCtrl = TextEditingController(text: w?.notes ?? '');
  }

  @override
  void dispose() {
    _machineCtrl.dispose();
    _qtyCtrl.dispose();
    _rateCtrl.dispose();
    _extraCtrl.dispose();
    _discountCtrl.dispose();
    _advanceCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  double _parse(TextEditingController c) =>
      double.tryParse(c.text.trim()) ?? 0.0;

  double get _totalAmount => WorkEntry.calculateTotal(
        quantityTons: _parse(_qtyCtrl),
        ratePerTon: _parse(_rateCtrl),
        additionalCharges: _parse(_extraCtrl),
        discount: _parse(_discountCtrl),
      );

  double get _receivedAmount => isEditing
      ? (widget.workEntry!.receivedAmount)
      : _parse(_advanceCtrl);

  double get _remainingBalance => WorkEntry.calculateRemaining(
        totalAmount: _totalAmount,
        receivedAmount: _receivedAmount,
      );

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _workDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => _workDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCustomerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('कृपया ग्राहक निवडा')),
      );
      return;
    }

    final data = context.read<BusinessDataProvider>();
    final customer = data.customers.firstWhere(
      (c) => c.id == _selectedCustomerId,
    );

    if (!isEditing && _parse(_advanceCtrl) > _totalAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('अॅडव्हान्स रक्कम एकूण बिलापेक्षा जास्त असू शकत नाही'),
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      if (isEditing) {
        final updated = widget.workEntry!.copyWith(
          customerId: customer.id,
          customerName: customer.name,
          customerMobile: customer.mobile,
          village: customer.village,
          workDate: _workDate,
          machineName: _machineCtrl.text.trim(),
          quantityTons: _parse(_qtyCtrl),
          ratePerTon: _parse(_rateCtrl),
          additionalCharges: _parse(_extraCtrl),
          discount: _parse(_discountCtrl),
          notes: _notesCtrl.text.trim(),
        );
        await data.updateWorkEntry(updated);
      } else {
        await data.addWorkEntry(
          customer: customer,
          workDate: _workDate,
          machineName: _machineCtrl.text.trim(),
          quantityTons: _parse(_qtyCtrl),
          ratePerTon: _parse(_rateCtrl),
          additionalCharges: _parse(_extraCtrl),
          discount: _parse(_discountCtrl),
          advancePayment: _parse(_advanceCtrl),
          advanceMethod: _advanceMethod,
          notes: _notesCtrl.text.trim(),
        );
      }
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final data = context.watch<BusinessDataProvider>();
    final s = app.strings;
    final customers = data.customers;

    Customer? selectedCustomer;
    if (_selectedCustomerId != null) {
      selectedCustomer = customers
          .cast<Customer?>()
          .firstWhere((c) => c?.id == _selectedCustomerId, orElse: () => null);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? s.updateWork : s.newWork),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    key: ValueKey(selectedCustomer?.id),
                    initialValue: selectedCustomer?.id,
                    hint: Text(
                      customers.isEmpty
                          ? 'आधी उजवीकडे + दाबून ग्राहक जोडा'
                          : s.selectCustomer,
                    ),
                    decoration: InputDecoration(
                      labelText: '${s.selectCustomer} *',
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                    items: customers
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text('${c.name} (${c.village})'),
                          ),
                        )
                        .toList(),
                    onChanged: customers.isEmpty
                        ? null
                        : (val) => setState(() => _selectedCustomerId = val),
                    validator: (v) =>
                        v == null ? 'कृपया ग्राहक निवडा' : null,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  onPressed: () async {
                    final created = await Navigator.push<Customer>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CustomerFormScreen(),
                      ),
                    );
                    if (created != null && mounted) {
                      setState(() => _selectedCustomerId = created.id);
                    }
                  },
                  icon: const Icon(Icons.person_add),
                  tooltip: s.addCustomer,
                ),
              ],
            ),
            if (customers.isEmpty) ...[
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () async {
                  final created = await Navigator.push<Customer>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CustomerFormScreen(),
                    ),
                  );
                  if (created != null && mounted) {
                    setState(() => _selectedCustomerId = created.id);
                  }
                },
                icon: const Icon(Icons.person_add),
                label: Text('${s.addCustomer} (नवीन ग्राहक जोडा)'),
              ),
            ],
            if (selectedCustomer != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.deepGreen.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        size: 18, color: AppColors.deepGreen),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${selectedCustomer.village}  •  मो: ${selectedCustomer.mobile}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 14),
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: s.workDate,
                  prefixIcon: const Icon(Icons.calendar_today),
                ),
                child: Text(AppFormatters.date(_workDate)),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _qtyCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'टन (प्रमाण) *',
                      prefixIcon: Icon(Icons.scale),
                    ),
                    onChanged: (_) => setState(() {}),
                    validator: (v) {
                      final val = double.tryParse(v ?? '');
                      if (val == null || val <= 0) return 'योग्य टन टाका';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _rateCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'दर / टन (₹) *',
                      prefixIcon: Icon(Icons.currency_rupee),
                    ),
                    onChanged: (_) => setState(() {}),
                    validator: (v) {
                      final val = double.tryParse(v ?? '');
                      if (val == null || val <= 0) return 'योग्य दर टाका';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            if (!isEditing) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _advanceCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'अॅडव्हान्स जमा (₹)',
                        prefixIcon: Icon(Icons.payments_outlined),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<PaymentMethod>(
                      initialValue: _advanceMethod,
                      decoration: InputDecoration(labelText: s.paymentMethod),
                      items: PaymentMethod.values
                          .map(
                            (m) => DropdownMenuItem(
                              value: m,
                              child: Text(m.label(app.languageCode)),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _advanceMethod = v);
                      },
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Card(
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 14),
                childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                leading: const Icon(Icons.tune, color: AppColors.deepGreen),
                title: const Text(
                  'अधिक तपशील (मशीन, सवलत, टीप)',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                children: [
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _machineCtrl,
                    decoration: InputDecoration(
                      labelText: s.machineName,
                      prefixIcon: const Icon(Icons.agriculture),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _extraCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: InputDecoration(
                            labelText: s.additionalCharges,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _discountCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: InputDecoration(
                            labelText: s.discount,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _notesCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: s.notes,
                      prefixIcon: const Icon(Icons.note_outlined),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Live Calculation Card
            Card(
              color: AppColors.deepGreen.withValues(alpha: 0.08),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _calcRow(
                      s.totalBillAmount,
                      AppFormatters.currency(_totalAmount),
                      bold: true,
                      color: AppColors.deepGreen,
                    ),
                    const SizedBox(height: 6),
                    _calcRow(
                      s.totalReceived,
                      AppFormatters.currency(_receivedAmount),
                      color: AppColors.revenueGreen,
                    ),
                    const Divider(),
                    _calcRow(
                      s.remainingBalance,
                      AppFormatters.currency(_remainingBalance),
                      bold: true,
                      color: _remainingBalance > 0
                          ? AppColors.pendingAmber
                          : AppColors.revenueGreen,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(isEditing ? s.updateWork : s.saveWork),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _calcRow(
    String label,
    String value, {
    bool bold = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: bold ? 18 : 15,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
