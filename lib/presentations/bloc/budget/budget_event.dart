import 'package:equatable/equatable.dart';
import '../../../domain/entity/budgets.dart';

abstract class BudgetEvent extends Equatable {
  const BudgetEvent();

  @override
  List<Object?> get props => [];
}

// Load budgets
class LoadBudgetsEvent extends BudgetEvent {
  final DateTime? month;

  const LoadBudgetsEvent({this.month});

  @override
  List<Object?> get props => [month];
}

// Add budget
class AddBudgetEvent extends BudgetEvent {
  final Budget budget;

  const AddBudgetEvent({required this.budget});

  @override
  List<Object?> get props => [budget];
}

// Update budget
class UpdateBudgetEvent extends BudgetEvent {
  final Budget budget;

  const UpdateBudgetEvent({required this.budget});

  @override
  List<Object?> get props => [budget];
}

// Delete budget
class DeleteBudgetEvent extends BudgetEvent {
  final String id;

  const DeleteBudgetEvent({required this.id});

  @override
  List<Object?> get props => [id];
}