import 'package:flutter/material.dart';
import '../../../core/constants/app_color.dart';
import '../../../core/utils/currency_formatter.dart';

class BalanceCard extends StatelessWidget {
  final double totalBalance;
  final double totalIncome;
  final double totalExpense;

  const BalanceCard({
    super.key,
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpense,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Balance',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.format(totalBalance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildInfoTile(
                  icon: Icons.arrow_downward,
                  label: 'Income',
                  amount: totalIncome,
                  color: Colors.greenAccent,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoTile(
                  icon: Icons.arrow_upward,
                  label: 'Expense',
                  amount: totalExpense,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required double amount,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            CurrencyFormatter.formatWithoutDecimals(amount),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}