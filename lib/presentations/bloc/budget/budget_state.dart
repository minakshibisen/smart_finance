import 'package:equatable/equatable.dart';
import '../../../domain/entity/budgets.dart';

abstract class BudgetState extends Equatable {
  const BudgetState();

  @override
  List<Object?> get props => [];
}

// Initial state
class BudgetInitial extends BudgetState {}

// Loading state
class BudgetLoading extends BudgetState {}

// Loaded state
class BudgetLoaded extends BudgetState {
  final List<Budget> budgets;
  final Map<String, double> spending;
  final double totalBudget;
  final double totalSpending;

  const BudgetLoaded({
    required this.budgets,
    required this.spending,
    required this.totalBudget,
    required this.totalSpending,
  });

  @override
  List<Object?> get props => [budgets, spending, totalBudget, totalSpending];
}

// Success state
class BudgetSuccess extends BudgetState {
  final String message;

  const BudgetSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

// Error state
class BudgetError extends BudgetState {
  final String message;

  const BudgetError({required this.message});

  @override
  List<Object?> get props => [message];
}