import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_color.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/datasources/remote/firestore_service.dart';
import '../../bloc/budget/budget_bloc.dart';
import '../../bloc/budget/budget_event.dart';
import '../../bloc/budget/budget_state.dart';

import '../../widget/cards/budget_card.dart';
import 'add_budget_screen.dart';


class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  DateTime _selectedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BudgetBloc(
        firestoreService: FirestoreService(),
      )..add(LoadBudgetsEvent(month: _selectedMonth)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Budget Manager'),
          actions: [
            IconButton(
              icon: const Icon(Icons.calendar_month),
              onPressed: _selectMonth,
            ),
          ],
        ),
        body: BlocConsumer<BudgetBloc, BudgetState>(
          listener: (context, state) {
            if (state is BudgetSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.income,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else if (state is BudgetError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.expense,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is BudgetLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is BudgetLoaded) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<BudgetBloc>().add(
                    LoadBudgetsEvent(month: _selectedMonth),
                  );
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),

                      // Month Selector
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.chevron_left),
                                  onPressed: () {
                                    setState(() {
                                      _selectedMonth = DateTime(
                                        _selectedMonth.year,
                                        _selectedMonth.month - 1,
                                      );
                                    });
                                    context.read<BudgetBloc>().add(
                                      LoadBudgetsEvent(month: _selectedMonth),
                                    );
                                  },
                                ),
                                Text(
                                  _getMonthYearString(_selectedMonth),
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.chevron_right),
                                  onPressed: _selectedMonth.month ==
                                      DateTime.now().month
                                      ? null
                                      : () {
                                    setState(() {
                                      _selectedMonth = DateTime(
                                        _selectedMonth.year,
                                        _selectedMonth.month + 1,
                                      );
                                    });
                                    context.read<BudgetBloc>().add(
                                      LoadBudgetsEvent(
                                          month: _selectedMonth),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Total Budget Overview
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primary.withOpacity(0.8),
                                AppColors.secondary.withOpacity(0.8),
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
                            children: [
                              const Text(
                                'Total Budget',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                CurrencyFormatter.format(state.totalBudget),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildOverviewTile(
                                      label: 'Spent',
                                      amount: state.totalSpending,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildOverviewTile(
                                      label: 'Remaining',
                                      amount: state.totalBudget -
                                          state.totalSpending,
                                      color: Colors.greenAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Budget List
                      if (state.budgets.isEmpty)
                        _buildEmptyState()
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.budgets.length,
                          itemBuilder: (context, index) {
                            final budget = state.budgets[index];
                            final spent =
                                state.spending[budget.category] ?? 0.0;

                            return BudgetCard(
                              budget: budget,
                              spent: spent,
                              onDelete: () => _showDeleteDialog(
                                context,
                                budget.id,
                              ),
                            );
                          },
                        ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              );
            }

            return const SizedBox();
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddBudgetScreen(month: _selectedMonth),
              ),
            );

            if (result == true) {
              context.read<BudgetBloc>().add(
                LoadBudgetsEvent(month: _selectedMonth),
              );
            }
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Budget'),
        ),
      ),
    );
  }

  Widget _buildOverviewTile({
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
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            CurrencyFormatter.formatCompact(amount),
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No budgets set',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a budget to track your spending',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String budgetId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Budget'),
        content: const Text(
          'Are you sure you want to delete this budget?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<BudgetBloc>().add(
                DeleteBudgetEvent(id: budgetId),
              );
              Navigator.pop(dialogContext);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.expense,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
    );

    if (picked != null) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month);
      });
      context.read<BudgetBloc>().add(
        LoadBudgetsEvent(month: _selectedMonth),
      );
    }}
    String _getMonthYearString(DateTime date) {
      const months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December'
      ];
      return '${months[date.month - 1]} ${date.year}';
    }
  }