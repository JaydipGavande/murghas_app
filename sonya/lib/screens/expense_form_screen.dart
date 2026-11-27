import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/expense.dart';
import '../providers/app_provider.dart';
import '../providers/business_data_provider.dart';
import '../utils/formatters.dart';

class ExpenseFormScreen extends StatefulWidget {
  final Expense? expense;
  const ExpenseFormScreen({super.key, this.expense});

  @override
  State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _expenseDate;
  late ExpenseCategory _category;
  late final TextEditingController _amountCtrl;
  late final TextEditingController _descCtrl;
  String? _receiptPath;
  bool _saving = false;

  bool get isEditing => widget.expense != null;

  @override
  void initState() {
    super.initState();
    final e = widget.expense;
    _expenseDate = e?.expenseDate ?? DateTime.now();
    _category = e?.category ?? ExpenseCategory.diesel;
    _amountCtrl = TextEditingController(
      text: e != null ? e.amount.toStringAsFixed(0) : '',
    );
    _descCtrl = TextEditingController(text: e?.description ?? '');
    _receiptPath = e?.receiptPath;
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expenseDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) setState(() => _expenseDate = picked);
  }

  Future<void> _pickReceipt() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() => _receiptPath = file.path);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final data = context.read<BusinessDataProvider>();
      final amount = double.parse(_amountCtrl.text.trim());
      if (isEditing) {
        final updated = widget.expense!.copyWith(
          expenseDate: _expenseDate,
          category: _category,
          amount: amount,
          description: _descCtrl.text.trim(),
          receiptPath: _receiptPath,
        );
        await data.updateExpense(updated);
      } else {
        await data.addExpense(
          expenseDate: _expenseDate,
          category: _category,
          amount: amount,
          description: _descCtrl.text.trim(),
          receiptPath: _receiptPath,
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
    final s = app.strings;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? '${s.edit} ${s.expenses}' : s.addExpense),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: s.expenseDate,
                  prefixIcon: const Icon(Icons.calendar_today),
                ),
                child: Text(AppFormatters.date(_expenseDate)),
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<ExpenseCategory>(
              initialValue: _category,
              decoration: InputDecoration(
                labelText: s.expenseCategory,
                prefixIcon: const Icon(Icons.category_outlined),
              ),
              items: ExpenseCategory.values
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text(c.label(app.languageCode)),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _category = v);
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _amountCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: '${s.amount} *',
                prefixIcon: const Icon(Icons.currency_rupee),
              ),
              validator: (v) {
                final val = double.tryParse(v ?? '');
                if (val == null || val <= 0) return 'योग्य रक्कम टाका';
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _descCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: s.description,
                prefixIcon: const Icon(Icons.notes),
              ),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: _pickReceipt,
              icon: const Icon(Icons.attach_file),
              label: Text(
                _receiptPath == null
                    ? 'पावती फोटो जोडा (ऐच्छिक)'
                    : 'पावती फोटो बदला',
              ),
            ),
            if (!kIsWeb &&
                _receiptPath != null &&
                File(_receiptPath!).existsSync()) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(_receiptPath!),
                  height: 160,
                  fit: BoxFit.cover,
                ),
              ),
            ],
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
                    : const Icon(Icons.save),
                label: Text(s.save),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
