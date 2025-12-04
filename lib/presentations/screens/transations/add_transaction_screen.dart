import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_color.dart';
import '../../../core/utils/validators.dart';
import '../../../data/datasources/remote/firestore_service.dart';
import '../../../domain/entity/transactions.dart' as entity;
import '../../bloc/transactions/transaction_bloc.dart';
import '../../bloc/transactions/transaction_event.dart';
import '../../bloc/transactions/transaction_state.dart';

import '../../widget/common/custom_button.dart';
import '../../widget/common/custom_text_field.dart';

import 'package:firebase_auth/firebase_auth.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  entity.TransactionType _selectedType = entity.TransactionType.expense;
  String _selectedCategory = 'Food';
  DateTime _selectedDate = DateTime.now();

  final List<String> _incomeCategories = [
    'Salary',
    'Business',
    'Investment',
    'Freelance',
    'Gift',
    'Other',
  ];

  final List<String> _expenseCategories = [
    'Food',
    'Shopping',
    'Transport',
    'Entertainment',
    'Bills',
    'Health',
    'Education',
    'Other',
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  List<String> get _currentCategories =>
      _selectedType == entity.TransactionType.income
          ? _incomeCategories
          : _expenseCategories;

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final transaction = entity.Transaction(
        id: const Uuid().v4(),
        userId: FirebaseAuth.instance.currentUser!.uid,
        amount: double.parse(_amountController.text),
        category: _selectedCategory,
        categoryId: _selectedCategory.toLowerCase(),
        type: _selectedType,
        date: _selectedDate,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        receiptUrl: null,
        createdAt: DateTime.now(),
      );

      context.read<TransactionBloc>().add(
        AddTransactionEvent(transaction: transaction),
      );
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TransactionBloc(
        firestoreService: FirestoreService(),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add Transaction'),
        ),
        body: BlocConsumer<TransactionBloc, TransactionState>(
          listener: (context, state) {
            if (state is TransactionSuccess) {
              Navigator.pop(context, true);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.income,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.pop(context, true); // Return true to indicate success
            } else if (state is TransactionError) {
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
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type Selector
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildTypeButton(
                              label: 'Expense',
                              icon: Icons.remove_circle_outline,
                              color: AppColors.expense,
                              isSelected: _selectedType == entity.TransactionType.expense,
                              onTap: () {
                                setState(() {
                                  _selectedType = entity.TransactionType.expense;
                                  _selectedCategory = _expenseCategories.first;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: _buildTypeButton(
                              label: 'Income',
                              icon: Icons.add_circle_outline,
                              color: AppColors.income,
                              isSelected: _selectedType == entity.TransactionType.income,
                              onTap: () {
                                setState(() {
                                  _selectedType = entity.TransactionType.income;
                                  _selectedCategory = _incomeCategories.first;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Amount Field
                    CustomTextField(
                      label: 'Amount',
                      hint: 'Enter amount',
                      controller: _amountController,
                      validator: Validators.validateAmount,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      prefixIcon: Icons.currency_rupee,
                    ),

                    const SizedBox(height: 20),

                    // Category Dropdown
                    Text(
                      'Category',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items: _currentCategories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    // Date Picker
                    Text(
                      'Date',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _selectDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.calendar_today_outlined),
                          suffixIcon: Icon(Icons.arrow_drop_down),
                        ),
                        child: Text(
                          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Notes Field
                    CustomTextField(
                      label: 'Notes (Optional)',
                      hint: 'Add notes',
                      controller: _notesController,
                      maxLines: 3,
                      prefixIcon: Icons.note_outlined,
                    ),

                    const SizedBox(height: 32),

                    // Submit Button
                    FadeInLeft(
                      child: CustomButton(
                        text: 'Add Transaction',
                        onPressed: _handleSubmit,
                        isLoading: state is TransactionLoading,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTypeButton({
    required String label,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: color, width: 2)
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : AppColors.textSecondary,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? color : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}