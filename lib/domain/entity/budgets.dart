import 'package:equatable/equatable.dart';

class Budget extends Equatable {
  final String id;
  final String userId;
  final String category;
  final double amount;
  final DateTime month;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Budget({
    required this.id,
    required this.userId,
    required this.category,
    required this.amount,
    required this.month,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    category,
    amount,
    month,
    createdAt,
    updatedAt,
  ];

  Budget copyWith({
    String? id,
    String? userId,
    String? category,
    double? amount,
    DateTime? month,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Budget(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      month: month ?? this.month,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}