import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;

import '../../domain/entity/transactions.dart';

class TransactionModel extends Transaction {
  const TransactionModel({
    required super.id,
    required super.userId,
    required super.amount,
    required super.category,
    required super.categoryId,
    required super.type,
    required super.date,
    super.notes,
    super.receiptUrl,
    required super.createdAt,
  });

  // From Firestore
  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return TransactionModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      category: data['category'] ?? '',
      categoryId: data['categoryId'] ?? '',
      type: data['type'] == 'income'
          ? TransactionType.income
          : TransactionType.expense,
      date: (data['date'] as Timestamp).toDate(),
      notes: data['notes'],
      receiptUrl: data['receiptUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'amount': amount,
      'category': category,
      'categoryId': categoryId,
      'type': type == TransactionType.income ? 'income' : 'expense',
      'date': Timestamp.fromDate(date),
      'notes': notes,
      'receiptUrl': receiptUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // From Entity
  factory TransactionModel.fromEntity(Transaction transaction) {
    return TransactionModel(
      id: transaction.id,
      userId: transaction.userId,
      amount: transaction.amount,
      category: transaction.category,
      categoryId: transaction.categoryId,
      type: transaction.type,
      date: transaction.date,
      notes: transaction.notes,
      receiptUrl: transaction.receiptUrl,
      createdAt: transaction.createdAt,
    );
  }
}