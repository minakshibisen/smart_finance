import 'package:equatable/equatable.dart';
import '../../../domain/entity/transactions.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object?> get props => [];
}

// Initial state
class TransactionInitial extends TransactionState {}

// Loading state
class TransactionLoading extends TransactionState {}

// Loaded state
class TransactionLoaded extends TransactionState {
  final List<Transaction> transactions;
  final double totalIncome;
  final double totalExpense;
  final double balance;

  const TransactionLoaded({
    required this.transactions,
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
  });

  @override
  List<Object?> get props => [transactions, totalIncome, totalExpense, balance];
}

// Success state (for add/update/delete)
class TransactionSuccess extends TransactionState {
  final String message;

  const TransactionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

// Error state
class TransactionError extends TransactionState {
  final String message;

  const TransactionError({required this.message});

  @override
  List<Object?> get props => [message];
}