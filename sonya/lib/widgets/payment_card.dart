import 'package:flutter/material.dart';
import '../models/payment.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';

class PaymentCard extends StatelessWidget {
  final Payment payment;
  final String lang;
  final VoidCallback? onDelete;

  const PaymentCard({
    super.key,
    required this.payment,
    required this.lang,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: AppColors.revenueGreen.withValues(alpha: 0.14),
          child: const Icon(
            Icons.currency_rupee,
            color: AppColors.revenueGreen,
          ),
        ),
        title: Text(
          payment.customerName,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              '${AppFormatters.date(payment.paymentDate)} • ${payment.method.label(lang)}${payment.isAdvance ? ' (अॅडव्हान्स)' : ''}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (payment.notes.isNotEmpty)
              Text(
                payment.notes,
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
              '+ ${AppFormatters.currency(payment.amount)}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.revenueGreen,
              ),
            ),
            if (onDelete != null) ...[
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                color: Colors.red.shade400,
                onPressed: onDelete,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
