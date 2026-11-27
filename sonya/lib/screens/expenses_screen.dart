import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/expense.dart';
import '../providers/app_provider.dart';
import '../providers/business_data_provider.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/expense_card.dart';
import 'expense_form_screen.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  ExpenseCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final data = context.watch<BusinessDataProvider>();
    final s = app.strings;

    final now = DateTime.now();
    final todayTotal = data.expenses
        .where((e) => AppFormatters.isSameDay(e.expenseDate, now))
        .fold(0.0, (sum, e) => sum + e.amount);

    final weekStart = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 6));
    final weekTotal = data.expenses
        .where((e) => !e.expenseDate.isBefore(weekStart))
        .fold(0.0, (sum, e) => sum + e.amount);

    final monthTotal = data.expenses
        .where((e) => AppFormatters.isSameMonth(e.expenseDate, now))
        .fold(0.0, (sum, e) => sum + e.amount);

    final filtered = _selectedCategory == null
        ? data.expenses
        : data.expenses
            .where((e) => e.category == _selectedCategory)
            .toList();

    return Scaffold(
      appBar: AppBar(title: Text(s.expenses)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                _summaryChip(s.today, AppFormatters.currency(todayTotal)),
                const SizedBox(width: 8),
                _summaryChip(s.thisWeek, AppFormatters.currency(weekTotal)),
                const SizedBox(width: 8),
                _summaryChip(s.thisMonth, AppFormatters.currency(monthTotal)),
              ],
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('सर्व'),
                    selected: _selectedCategory == null,
                    onSelected: (_) => setState(() => _selectedCategory = null),
                  ),
                ),
                ...ExpenseCategory.values.map(
                  (cat) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(cat.label(app.languageCode)),
                      selected: _selectedCategory == cat,
                      onSelected: (_) => setState(
                        () => _selectedCategory =
                            _selectedCategory == cat ? null : cat,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filtered.isEmpty
                ? EmptyStateWidget(
                    icon: Icons.receipt_long_outlined,
                    title: 'खर्चाची नोंद नाही',
                    subtitle:
                        'डिझेल, मजुरी, ट्रॅक्टर, मशीन दुरुस्ती आणि इतर खर्चाची नोंद ठेवा.',
                    actionLabel: s.addExpense,
                    onAction: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ExpenseFormScreen(),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 88),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final exp = filtered[i];
                      return ExpenseCard(
                        expense: exp,
                        lang: app.languageCode,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ExpenseFormScreen(expense: exp),
                          ),
                        ),
                        onDelete: () async {
                          final ok = await showConfirmDialog(
                            context,
                            title: s.confirmDelete,
                            message:
                                '${exp.category.label(app.languageCode)} चा ${AppFormatters.currency(exp.amount)} खर्च हटवायचा का?',
                            confirmText: s.delete,
                            cancelText: s.cancel,
                          );
                          if (ok) {
                            await data.deleteExpense(exp.id);
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ExpenseFormScreen()),
        ),
        icon: const Icon(Icons.add),
        label: Text(s.addExpense),
      ),
    );
  }

  Widget _summaryChip(String label, String value) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: AppColors.expenseRed,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
