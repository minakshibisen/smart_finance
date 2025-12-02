import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entity/budgets.dart';

class BudgetModel extends Budget {
  const BudgetModel({
    required super.id,
    required super.userId,
    required super.category,
    required super.amount,
    required super.month,
    required super.createdAt,
    required super.updatedAt,
  });

  // From Firestore
  factory BudgetModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return BudgetModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      category: data['category'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      month: (data['month'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  // To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'category': category,
      'amount': amount,
      'month': Timestamp.fromDate(month),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // From Entity
  factory BudgetModel.fromEntity(Budget budget) {
    return BudgetModel(
      id: budget.id,
      userId: budget.userId,
      category: budget.category,
      amount: budget.amount,
      month: budget.month,
      createdAt: budget.createdAt,
      updatedAt: budget.updatedAt,
    );
  }
}