import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_color.dart';

import '../../../data/datasources/remote/firebase_service/firebase_auth_service.dart';
import '../../../domain/entity/transactions.dart' as entity;
import '../../widget/cards/balance_card.dart';
import '../../widget/cards/quick_action_card.dart';
import '../../widget/cards/transaction_card.dart';

import '../auth/login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final user = FirebaseAuth.instance.currentUser;

  // Dummy data (will be replaced with real Firestore data)
  final double totalBalance = 45000.00;
  final double totalIncome = 75000.00;
  final double totalExpense = 30000.00;

  final List<entity.Transaction> recentTransactions = [
    entity.Transaction(
      id: '1',
      userId: 'user1',
      amount: 5000,
      category: 'Salary',
      categoryId: 'cat1',
      type: entity.TransactionType.income,
      date: DateTime.now().subtract(const Duration(days: 1)),
      notes: 'Monthly salary',
      receiptUrl: null,
      createdAt: DateTime.now(),
    ),
    entity.Transaction(
      id: '2',
      userId: 'user1',
      amount: 1500,
      category: 'Food',
      categoryId: 'cat2',
      type: entity.TransactionType.expense,
      date: DateTime.now().subtract(const Duration(days: 2)),
      notes: 'Grocery shopping',
      receiptUrl: null,
      createdAt: DateTime.now(),
    ),
    entity.Transaction(
      id: '3',
      userId: 'user1',
      amount: 2000,
      category: 'Shopping',
      categoryId: 'cat3',
      type: entity.TransactionType.expense,
      date: DateTime.now().subtract(const Duration(days: 3)),
      notes: 'New clothes',
      receiptUrl: null,
      createdAt: DateTime.now(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hello,',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              user?.displayName ?? 'User',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary,
              backgroundImage: user?.photoURL != null
                  ? NetworkImage(user!.photoURL!)
                  : null,
              child: user?.photoURL == null
                  ? Text(
                user?.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              )
                  : null,
            ),
            onPressed: () {
              _showProfileMenu(context);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: Refresh data from Firestore
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Balance Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: BalanceCard(
                  totalBalance: totalBalance,
                  totalIncome: totalIncome,
                  totalExpense: totalExpense,
                ),
              ),

              const SizedBox(height: 24),

              // Quick Actions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: QuickActionCard(
                        icon: Icons.add_circle_outline,
                        label: 'Add Income',
                        color: AppColors.income,
                        onTap: () {
                          // TODO: Navigate to add income
                          _showComingSoon(context, 'Add Income');
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: QuickActionCard(
                        icon: Icons.remove_circle_outline,
                        label: 'Add Expense',
                        color: AppColors.expense,
                        onTap: () {
                          // TODO: Navigate to add expense
                          _showComingSoon(context, 'Add Expense');
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: QuickActionCard(
                        icon: Icons.category_outlined,
                        label: 'Categories',
                        color: AppColors.accent,
                        onTap: () {
                          // TODO: Navigate to categories
                          _showComingSoon(context, 'Categories');
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Recent Transactions Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Transactions',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    TextButton(
                      onPressed: () {
                        // TODO: Navigate to all transactions
                        _showComingSoon(context, 'All Transactions');
                      },
                      child: const Text('See All'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Recent Transactions List
              if (recentTransactions.isEmpty)
                _buildEmptyState()
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentTransactions.length,
                  itemBuilder: (context, index) {
                    return TransactionCard(
                      transaction: recentTransactions[index],
                      onTap: () {
                        // TODO: Navigate to transaction details
                        _showComingSoon(context, 'Transaction Details');
                      },
                    );
                  },
                ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to add transaction
          _showComingSoon(context, 'Add Transaction');
        },
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start adding your income and expenses',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                _showComingSoon(context, 'Profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                _showComingSoon(context, 'Settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.expense),
              title: const Text(
                'Logout',
                style: TextStyle(color: AppColors.expense),
              ),
              onTap: () async {
                Navigator.pop(context);
                await FirebaseAuthService().logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Coming Soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}