import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/remote/firestore_service.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final FirestoreService _firestoreService;

  TransactionBloc({required FirestoreService firestoreService})
      : _firestoreService = firestoreService,
        super(TransactionInitial()) {
    on<LoadTransactionsEvent>(_onLoadTransactions);
    on<AddTransactionEvent>(_onAddTransaction);
    on<UpdateTransactionEvent>(_onUpdateTransaction);
    on<DeleteTransactionEvent>(_onDeleteTransaction);
    on<LoadStatisticsEvent>(_onLoadStatistics);
  }

  // Load transactions
  Future<void> _onLoadTransactions(
      LoadTransactionsEvent event,
      Emitter<TransactionState> emit,
      ) async {
    emit(TransactionLoading());

    try {
      await emit.forEach(
        _firestoreService.getTransactions(),
        onData: (transactions) {
          return TransactionLoaded(
            transactions: transactions,
            totalIncome: _calculateTotalIncome(transactions),
            totalExpense: _calculateTotalExpense(transactions),
            balance: _calculateBalance(transactions),
          );
        },
        onError: (error, stackTrace) {
          return TransactionError(message: error.toString());
        },
      );
    } catch (e) {
      emit(TransactionError(message: e.toString()));
    }
  }

  // Add transaction
  Future<void> _onAddTransaction(
      AddTransactionEvent event,
      Emitter<TransactionState> emit,
      ) async {
    try {
      await _firestoreService.addTransaction(event.transaction);
      emit(const TransactionSuccess(message: 'Transaction added successfully',));

      add(LoadTransactionsEvent());
    } catch (e) {
      emit(TransactionError(message: e.toString()));
    }
  }

  // Update transaction
  Future<void> _onUpdateTransaction(
      UpdateTransactionEvent event,
      Emitter<TransactionState> emit,
      ) async {
    try {
      await _firestoreService.updateTransaction(event.transaction);
      emit(const TransactionSuccess(message: 'Transaction updated successfully'));
      add(LoadTransactionsEvent());
    } catch (e) {
      emit(TransactionError(message: e.toString()));
    }
  }

  // Delete transaction
  Future<void> _onDeleteTransaction(
      DeleteTransactionEvent event,
      Emitter<TransactionState> emit,
      ) async {
    try {
      await _firestoreService.deleteTransaction(event.id);
      emit(const TransactionSuccess(message: 'Transaction deleted successfully'));
      add(LoadTransactionsEvent());
    } catch (e) {
      emit(TransactionError(message: e.toString()));
    }
  }

  // Load statistics
  Future<void> _onLoadStatistics(
      LoadStatisticsEvent event,
      Emitter<TransactionState> emit,
      ) async {
    emit(TransactionLoading());

    try {
      final income = await _firestoreService.getTotalIncome();
      final expense = await _firestoreService.getTotalExpense();
      final balance = income - expense;

      // Get transactions and emit loaded state
      _firestoreService.getTransactions().first.then((transactions) {
        emit(TransactionLoaded(
          transactions: transactions,
          totalIncome: income,
          totalExpense: expense,
          balance: balance,
        ));
      });
    } catch (e) {
      emit(TransactionError(message: e.toString()));
    }
  }

  // Helper methods
  double _calculateTotalIncome(List transactions) {
    return transactions
        .where((t) => t.type.toString().contains('income'))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double _calculateTotalExpense(List transactions) {
    return transactions
        .where((t) => t.type.toString().contains('expense'))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double _calculateBalance(List transactions) {
    return _calculateTotalIncome(transactions) -
        _calculateTotalExpense(transactions);
  }
}