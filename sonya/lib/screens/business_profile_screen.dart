import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';

class BusinessProfileScreen extends StatefulWidget {
  const BusinessProfileScreen({super.key});

  @override
  State<BusinessProfileScreen> createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends State<BusinessProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _bizCtrl;
  late final TextEditingController _ownerCtrl;
  late final TextEditingController _mobileCtrl;
  late final TextEditingController _villageCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _rateCtrl;
  String? _logoPath;

  @override
  void initState() {
    super.initState();
    final p = context.read<AppProvider>().profile;
    _bizCtrl = TextEditingController(text: p.businessName);
    _ownerCtrl = TextEditingController(text: p.ownerName);
    _mobileCtrl = TextEditingController(text: p.mobile);
    _villageCtrl = TextEditingController(text: p.village);
    _addressCtrl = TextEditingController(text: p.address);
    _rateCtrl =
        TextEditingController(text: p.defaultRatePerTon.toStringAsFixed(0));
    _logoPath = p.logoPath;
  }

  @override
  void dispose() {
    _bizCtrl.dispose();
    _ownerCtrl.dispose();
    _mobileCtrl.dispose();
    _villageCtrl.dispose();
    _addressCtrl.dispose();
    _rateCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() => _logoPath = file.path);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final app = context.read<AppProvider>();
    final updated = app.profile.copyWith(
      businessName: _bizCtrl.text.trim(),
      ownerName: _ownerCtrl.text.trim(),
      mobile: _mobileCtrl.text.trim(),
      village: _villageCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      defaultRatePerTon: double.tryParse(_rateCtrl.text.trim()) ?? 1200.0,
      logoPath: _logoPath,
    );
    await app.updateProfile(updated);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('व्यवसाय प्रोफाइल जतन केले')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppProvider>().strings;

    return Scaffold(
      appBar: AppBar(title: Text(s.businessProfile)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickLogo,
                child: CircleAvatar(
                  radius: 44,
                  backgroundImage: !kIsWeb &&
                          _logoPath != null &&
                          File(_logoPath!).existsSync()
                      ? FileImage(File(_logoPath!))
                      : null,
                  child: kIsWeb ||
                          _logoPath == null ||
                          !File(_logoPath!).existsSync()
                      ? const Icon(Icons.add_a_photo, size: 30)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 6),
            const Center(
              child: Text(
                'व्यवसाय लोगो अपलोड करण्यासाठी टॅप करा',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _bizCtrl,
              decoration: const InputDecoration(
                labelText: 'व्यवसायाचे नाव *',
                prefixIcon: Icon(Icons.storefront),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'व्यवसायाचे नाव टाका' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _ownerCtrl,
              decoration: const InputDecoration(
                labelText: 'मालकाचे नाव *',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'मालकाचे नाव टाका' : null,
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
                labelText: s.mobileNumber,
                prefixIcon: const Icon(Icons.phone_outlined),
                counterText: '',
              ),
              validator: (v) {
                final val = (v ?? '').trim();
                if (val.isNotEmpty && !RegExp(r'^[6-9]\d{9}$').hasMatch(val)) {
                  return 'योग्य १० अंकी मोबाईल नंबर टाका';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _villageCtrl,
              decoration: InputDecoration(
                labelText: s.village,
                prefixIcon: const Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _addressCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: s.address,
                prefixIcon: const Icon(Icons.home_outlined),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _rateCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'डीफॉल्ट दर प्रति टन (₹) *',
                prefixIcon: Icon(Icons.currency_rupee),
              ),
              validator: (v) {
                final val = double.tryParse(v ?? '');
                if (val == null || val <= 0) return 'योग्य दर टाका';
                return null;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: Text(s.save),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
