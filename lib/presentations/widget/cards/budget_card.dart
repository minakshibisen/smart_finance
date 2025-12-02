import 'package:flutter/material.dart';
import '../../../core/constants/app_color.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/entity/budgets.dart';

class BudgetCard extends StatelessWidget {
  final Budget budget;
  final double spent;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const BudgetCard({
    super.key,
    required this.budget,
    required this.spent,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (spent / budget.amount * 100).clamp(0, 100);
    final remaining = budget.amount - spent;
    final isOverBudget = spent > budget.amount;

    Color getProgressColor() {
      if (isOverBudget) return AppColors.expense;
      if (percentage >= 80) return Colors.orange;
      return AppColors.income;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: getProgressColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getCategoryIcon(budget.category),
                          color: getProgressColor(),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            budget.category,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            CurrencyFormatter.formatWithoutDecimals(budget.amount),
                            style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      color: AppColors.expense,
                      onPressed: onDelete,
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: percentage / 100,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(getProgressColor()),
                ),
              ),

              const SizedBox(height: 12),

              // Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Spent',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        CurrencyFormatter.formatCompact(spent),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: getProgressColor(),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        isOverBudget ? 'Over Budget' : 'Remaining',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        CurrencyFormatter.formatCompact(remaining.abs()),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: isOverBudget
                              ? AppColors.expense
                              : AppColors.income,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
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
      case 'health':
        return Icons.local_hospital;
      case 'education':
        return Icons.school;
      default:
        return Icons.category;
    }
  }
}