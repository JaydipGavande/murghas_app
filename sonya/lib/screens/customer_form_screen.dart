import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/customer.dart';
import '../providers/app_provider.dart';
import '../providers/business_data_provider.dart';

class CustomerFormScreen extends StatefulWidget {
  final Customer? customer;
  const CustomerFormScreen({super.key, this.customer});

  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _mobileCtrl;
  late final TextEditingController _villageCtrl;
  late final TextEditingController _addressCtrl;
  bool _saving = false;

  bool get isEditing => widget.customer != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.customer?.name ?? '');
    _mobileCtrl = TextEditingController(text: widget.customer?.mobile ?? '');
    _villageCtrl = TextEditingController(text: widget.customer?.village ?? '');
    _addressCtrl = TextEditingController(text: widget.customer?.address ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _mobileCtrl.dispose();
    _villageCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final data = context.read<BusinessDataProvider>();
      if (isEditing) {
        final updated = widget.customer!.copyWith(
          name: _nameCtrl.text.trim(),
          mobile: _mobileCtrl.text.trim(),
          village: _villageCtrl.text.trim(),
          address: _addressCtrl.text.trim(),
        );
        await data.updateCustomer(updated);
        if (mounted) Navigator.pop(context, updated);
      } else {
        final created = await data.addCustomer(
          name: _nameCtrl.text.trim(),
          mobile: _mobileCtrl.text.trim(),
          village: _villageCtrl.text.trim(),
          address: _addressCtrl.text.trim(),
        );
        if (mounted) Navigator.pop(context, created);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppProvider>().strings;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? s.editCustomer : s.addCustomer),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: '${s.customerName} *',
                prefixIcon: const Icon(Icons.person_outline),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'कृपया ग्राहकाचे नाव टाका'
                  : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _mobileCtrl,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              decoration: InputDecoration(
                labelText: '${s.mobileNumber} *',
                prefixIcon: const Icon(Icons.phone_outlined),
                counterText: '',
              ),
              validator: (v) {
                final val = (v ?? '').trim();
                if (val.isEmpty) {
                  return 'कृपया मोबाईल नंबर टाका';
                }
                if (!RegExp(r'^[6-9]\d{9}$').hasMatch(val)) {
                  return 'योग्य १० अंकी मोबाईल नंबर टाका (६ ते ९ ने सुरू होणारा)';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _villageCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: '${s.village} *',
                prefixIcon: const Icon(Icons.location_on_outlined),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'कृपया गावाचे नाव टाका'
                  : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _addressCtrl,
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: s.address,
                prefixIcon: const Icon(Icons.home_outlined),
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
