import 'package:flutter/material.dart';
import '../../../core/constants/app_color.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formetter.dart';
import '../../../domain/entity/transactions.dart' as entity;

class TransactionCard extends StatelessWidget {
  final entity.Transaction transaction;
  final VoidCallback? onTap;

  const TransactionCard({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == entity.TransactionType.income;
    final color = isIncome ? AppColors.income : AppColors.expense;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Category icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getCategoryIcon(transaction.category),
                  color: color,
                  size: 24,
                ),
              ),

              const SizedBox(width: 16),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.category,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormatter.format(transaction.date),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (transaction.notes != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        transaction.notes!,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Amount
              Text(
                '${isIncome ? '+' : '-'} ${CurrencyFormatter.formatWithoutDecimals(transaction.amount)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'shopping':
        return Icons.shopping_bag;
      case 'transport':
        return Icons.directions_car;
      case 'entertainment':
        return Icons.movie;
      case 'bills':
        return Icons.receipt_long;
      case 'salary':
        return Icons.attach_money;
      case 'business':
        return Icons.business_center;
      case 'investment':
        return Icons.trending_up;
      default:
        return Icons.category;
    }
  }
}