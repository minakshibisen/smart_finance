import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_color.dart';
import '../../../data/datasources/remote/firebase_service/firebase_auth_service.dart';
import '../../bloc/transactions/transaction_bloc.dart';
import '../../bloc/transactions/transaction_event.dart';
import '../../bloc/transactions/transaction_state.dart';
import '../../widget/cards/balance_card.dart';
import '../../widget/cards/transaction_card.dart';
import '../auth/login_screen.dart';
import '../settings/setting_screens.dart';
import '../analytics/analytics_screen.dart';
import '../budget/budget_screen.dart';
import '../reports/export_screen.dart';
import '../profile/profile_edit_screen.dart';
import '../transations/add_transaction_screen.dart';
import '../transations/transaction_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    context.read<TransactionBloc>().add(LoadTransactionsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if (state is TransactionLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TransactionError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: AppColors.expense),
                  const SizedBox(height: 16),
                  Text('Error loading data', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(state.message, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => context.read<TransactionBloc>().add(LoadTransactionsEvent()),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is TransactionLoaded) {
            final transactions = state.transactions.take(5).toList();

            return CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  expandedHeight: 80,
                  floating: false,
                  pinned: true,
                  elevation: 0,
                  backgroundColor: AppColors.primary,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary.withOpacity(0.1),
                          ],
                        ),
                      ),
                    ),
                      title: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
                              );
                            },
                            child: CircleAvatar(
                              radius: 20,
                              backgroundImage:
                              user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                              child: user?.photoURL == null
                                  ? Text(
                                user?.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                                style: const TextStyle(color: Colors.white),
                              )
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Welcome', style: TextStyle(fontSize: 12, color: Colors.white)),
                              Text(
                                user?.displayName ?? "User",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                    titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined,color: Colors.white,),
                      onPressed: () {
                        _showComingSoon(context, 'Notifications');
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert,color: Colors.white,),
                      onPressed: () => _showProfileMenu(context),
                    ),
                  ],
                ),

                // Main Content
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),

                      // Balance Card
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: BalanceCard(
                          totalBalance: state.balance,
                          totalIncome: state.totalIncome,
                          totalExpense: state.totalExpense,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Quick Actions Grid
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.5,
                          children: [
                            _buildActionCard(
                              context: context,
                              icon: Icons.add_circle,
                              title: 'Add Income',
                              subtitle: 'Record income',
                              gradient: LinearGradient(
                                colors: [AppColors.income, AppColors.income.withOpacity(0.7)],
                              ),
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
                                );
                                if (result == true) {
                                  context.read<TransactionBloc>().add(LoadTransactionsEvent());
                                }
                              },
                            ),
                            _buildActionCard(
                              context: context,
                              icon: Icons.remove_circle,
                              title: 'Add Expense',
                              subtitle: 'Track spending',
                              gradient: LinearGradient(
                                colors: [AppColors.expense, AppColors.expense.withOpacity(0.7)],
                              ),
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
                                );
                                if (result == true) {
                                  context.read<TransactionBloc>().add(LoadTransactionsEvent());
                                }
                              },
                            ),
                            _buildActionCard(
                              context: context,
                              icon: Icons.pie_chart,
                              title: 'Analytics',
                              subtitle: 'View insights',
                              gradient: LinearGradient(
                                colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
                                );
                              },
                            ),
                            _buildActionCard(
                              context: context,
                              icon: Icons.account_balance_wallet,
                              title: 'Budget',
                              subtitle: 'Manage budget',
                              gradient: LinearGradient(
                                colors: [Colors.purple, Colors.purple.withOpacity(0.7)],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const BudgetScreen()),
                                );
                              },
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
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const TransactionListScreen()),
                                );
                              },
                              icon: const Icon(Icons.arrow_forward, size: 16),
                              label: const Text('See All'),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Recent Transactions List
                      if (transactions.isEmpty)
                        _buildEmptyState()
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: transactions.length,
                          itemBuilder: (context, index) {
                            return TransactionCard(
                              transaction: transactions[index],
                              onTap: () {
                                _showComingSoon(context, 'Transaction Details');
                              },
                            );
                          },
                        ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            );
          }

          return const SizedBox();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: SizedBox(
        height: 100,
        width: 200,
        child: Padding(
          padding: const EdgeInsets.only(right: 8, bottom: 8),
          child: FloatingActionButton.extended(
            onPressed: () {},
            label: const Text("Add Transaction"),
            icon: const Icon(Icons.add),
          ),
        ),
      ),

    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.blue, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey)
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 60,
              color: AppColors.primary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start tracking your finances by adding\nyour first transaction',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
              );
              if (result == true) {
                context.read<TransactionBloc>().add(LoadTransactionsEvent());
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Transaction'),
          ),
        ],
      ),
    );
  }

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: const Icon(Icons.person, color: AppColors.primary),
              ),
              title: const Text('Edit Profile'),
              onTap: () async {
                Navigator.pop(context);
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
                );
                if (result == true) setState(() {});
              },
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.secondary.withOpacity(0.1),
                child: const Icon(Icons.download, color: AppColors.secondary),
              ),
              title: const Text('Export Reports'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ExportScreen()),
                );
              },
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: const Icon(Icons.settings, color: AppColors.primary),
              ),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.expense.withOpacity(0.1),
                child: const Icon(Icons.logout, color: AppColors.expense),
              ),
              title: const Text('Logout', style: TextStyle(color: AppColors.expense)),
              onTap: () async {
                Navigator.pop(context);
                await FirebaseAuthService().logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
            ),
            const SizedBox(height: 16),
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