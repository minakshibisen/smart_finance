import 'package:equatable/equatable.dart';

enum TransactionType { income, expense }

class Transaction extends Equatable {
  final String id;
  final String userId;
  final double amount;
  final String category;
  final String categoryId;
  final TransactionType type;
  final DateTime date;
  final String? notes;
  final String? receiptUrl;
  final DateTime createdAt;

  const Transaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.category,
    required this.categoryId,
    required this.type,
    required this.date,
    this.notes,
    this.receiptUrl,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    amount,
    category,
    categoryId,
    type,
    date,
    notes,
    receiptUrl,
    createdAt,
  ];
}