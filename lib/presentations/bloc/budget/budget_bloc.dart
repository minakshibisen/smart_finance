import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/remote/firestore_service.dart';
import 'budget_event.dart';
import 'budget_state.dart';

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  final FirestoreService _firestoreService;

  BudgetBloc({required FirestoreService firestoreService})
      : _firestoreService = firestoreService,
        super(BudgetInitial()) {
    on<LoadBudgetsEvent>(_onLoadBudgets);
    on<AddBudgetEvent>(_onAddBudget);
    on<UpdateBudgetEvent>(_onUpdateBudget);
    on<DeleteBudgetEvent>(_onDeleteBudget);
  }

  // Load budgets
  Future<void> _onLoadBudgets(
      LoadBudgetsEvent event,
      Emitter<BudgetState> emit,
      ) async {
    emit(BudgetLoading());

    try {
      final month = event.month ?? DateTime.now();
      final budgets = await _firestoreService.getBudgetsForMonth(month);

      // Get spending for each budget category
      Map<String, double> spending = {};
      for (var budget in budgets) {
        final spent = await _firestoreService.getCategorySpending(
          budget.category,
          month,
        );
        spending[budget.category] = spent;
      }

      final totalBudget = budgets.fold<double>(
        0.0,
            (sum, budget) => sum + budget.amount,
      );

      final totalSpending = spending.values.fold<double>(
        0.0,
            (sum, spent) => sum + spent,
      );

      emit(BudgetLoaded(
        budgets: budgets,
        spending: spending,
        totalBudget: totalBudget,
        totalSpending: totalSpending,
      ));
    } catch (e) {
      emit(BudgetError(message: e.toString()));
    }
  }

  // Add budget
  Future<void> _onAddBudget(
      AddBudgetEvent event,
      Emitter<BudgetState> emit,
      ) async {
    try {
      await _firestoreService.addBudget(event.budget);
      emit(const BudgetSuccess(message: 'Budget added successfully'));
      add(LoadBudgetsEvent(month: event.budget.month));
    } catch (e) {
      emit(BudgetError(message: e.toString()));
    }
  }

  // Update budget
  Future<void> _onUpdateBudget(
      UpdateBudgetEvent event,
      Emitter<BudgetState> emit,
      ) async {
    try {
      await _firestoreService.updateBudget(event.budget);
      emit(const BudgetSuccess(message: 'Budget updated successfully'));
      add(LoadBudgetsEvent(month: event.budget.month));
    } catch (e) {
      emit(BudgetError(message: e.toString()));
    }
  }

  // Delete budget
  Future<void> _onDeleteBudget(
      DeleteBudgetEvent event,
      Emitter<BudgetState> emit,
      ) async {
    try {
      await _firestoreService.deleteBudget(event.id);
      emit(const BudgetSuccess(message: 'Budget deleted successfully'));
      add(LoadBudgetsEvent());
    } catch (e) {
      emit(BudgetError(message: e.toString()));
    }
  }
}