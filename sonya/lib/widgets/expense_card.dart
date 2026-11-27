import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';

class ExpenseCard extends StatelessWidget {
  final Expense expense;
  final String lang;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const ExpenseCard({
    super.key,
    required this.expense,
    required this.lang,
    this.onTap,
    this.onDelete,
  });

  IconData _iconForCategory(ExpenseCategory cat) {
    switch (cat) {
      case ExpenseCategory.diesel:
        return Icons.local_gas_station;
      case ExpenseCategory.labour:
        return Icons.groups;
      case ExpenseCategory.tractor:
        return Icons.agriculture;
      case ExpenseCategory.maintenance:
        return Icons.build;
      case ExpenseCategory.transportation:
        return Icons.local_shipping;
      case ExpenseCategory.foodAndOther:
        return Icons.restaurant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: AppColors.expenseRed.withValues(alpha: 0.12),
          child: Icon(
            _iconForCategory(expense.category),
            color: AppColors.expenseRed,
          ),
        ),
        title: Text(
          expense.category.label(lang),
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppFormatters.date(expense.expenseDate),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (expense.description.isNotEmpty)
              Text(
                expense.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall,
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '- ${AppFormatters.currency(expense.amount)}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.expenseRed,
              ),
            ),
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                color: Colors.red.shade400,
                onPressed: onDelete,
              ),
          ],
        ),
      ),
    );
  }
}
