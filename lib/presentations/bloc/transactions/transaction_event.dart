import 'package:equatable/equatable.dart';
import '../../../domain/entity/transactions.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

// Load transactions
class LoadTransactionsEvent extends TransactionEvent {}

// Add transaction
class AddTransactionEvent extends TransactionEvent {
  final Transaction transaction;

  const AddTransactionEvent({required this.transaction});

  @override
  List<Object?> get props => [transaction];
}

// Update transaction
class UpdateTransactionEvent extends TransactionEvent {
  final Transaction transaction;

  const UpdateTransactionEvent({required this.transaction});

  @override
  List<Object?> get props => [transaction];
}

// Delete transaction
class DeleteTransactionEvent extends TransactionEvent {
  final String id;

  const DeleteTransactionEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

// Load statistics
class LoadStatisticsEvent extends TransactionEvent {}