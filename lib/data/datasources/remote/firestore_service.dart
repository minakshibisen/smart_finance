import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../domain/entity/transactions.dart' as entity;
import '../../model/transaction_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // ==================== TRANSACTIONS ====================

  // Add transaction
  Future<String> addTransaction(entity.Transaction transaction) async {
    try {
      final model = TransactionModel.fromEntity(transaction);
      final docRef = await _firestore
          .collection('transactions')
          .add(model.toFirestore());

      return docRef.id;
    } catch (e) {
      throw 'Failed to add transaction: $e';
    }
  }

  // Get all transactions for current user
  Stream<List<entity.Transaction>> getTransactions() {
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('transactions')
        .where('userId', isEqualTo: currentUserId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .toList();
    });
  }

  // Get transactions by date range
  Stream<List<entity.Transaction>> getTransactionsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('transactions')
        .where('userId', isEqualTo: currentUserId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .toList();
    });
  }

  // Get transactions by type
  Stream<List<entity.Transaction>> getTransactionsByType(
      entity.TransactionType type,
      ) {
    if (currentUserId == null) {
      return Stream.value([]);
    }

    final typeString = type == entity.TransactionType.income ? 'income' : 'expense';

    return _firestore
        .collection('transactions')
        .where('userId', isEqualTo: currentUserId)
        .where('type', isEqualTo: typeString)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .toList();
    });
  }

  // Get single transaction
  Future<entity.Transaction?> getTransaction(String id) async {
    try {
      final doc = await _firestore.collection('transactions').doc(id).get();

      if (!doc.exists) return null;

      return TransactionModel.fromFirestore(doc);
    } catch (e) {
      throw 'Failed to get transaction: $e';
    }
  }

  // Update transaction
  Future<void> updateTransaction(entity.Transaction transaction) async {
    try {
      final model = TransactionModel.fromEntity(transaction);
      await _firestore
          .collection('transactions')
          .doc(transaction.id)
          .update(model.toFirestore());
    } catch (e) {
      throw 'Failed to update transaction: $e';
    }
  }

  // Delete transaction
  Future<void> deleteTransaction(String id) async {
    try {
      await _firestore.collection('transactions').doc(id).delete();
    } catch (e) {
      throw 'Failed to delete transaction: $e';
    }
  }

  // Get total income
  Future<double> getTotalIncome() async {
    if (currentUserId == null) return 0.0;

    try {
      final snapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: currentUserId)
          .where('type', isEqualTo: 'income')
          .get();

      double total = 0.0;
      for (var doc in snapshot.docs) {
        total += (doc.data()['amount'] ?? 0).toDouble();
      }

      return total;
    } catch (e) {
      return 0.0;
    }
  }

  // Get total expense
  Future<double> getTotalExpense() async {
    if (currentUserId == null) return 0.0;

    try {
      final snapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: currentUserId)
          .where('type', isEqualTo: 'expense')
          .get();

      double total = 0.0;
      for (var doc in snapshot.docs) {
        total += (doc.data()['amount'] ?? 0).toDouble();
      }

      return total;
    } catch (e) {
      return 0.0;
    }
  }

  // Get balance
  Future<double> getBalance() async {
    final income = await getTotalIncome();
    final expense = await getTotalExpense();
    return income - expense;
  }

  // Get monthly statistics
  Future<Map<String, double>> getMonthlyStats(DateTime month) async {
    if (currentUserId == null) {
      return {'income': 0.0, 'expense': 0.0};
    }

    final startDate = DateTime(month.year, month.month, 1);
    final endDate = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    try {
      final snapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: currentUserId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      double income = 0.0;
      double expense = 0.0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final amount = (data['amount'] ?? 0).toDouble();
        if (data['type'] == 'income') {
          income += amount;
        } else {
          expense += amount;
        }
      }

      return {'income': income, 'expense': expense};
    } catch (e) {
      return {'income': 0.0, 'expense': 0.0};
    }
  }

  // Get category-wise spending
  Future<Map<String, double>> getCategoryWiseSpending() async {
    if (currentUserId == null) return {};

    try {
      final snapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: currentUserId)
          .where('type', isEqualTo: 'expense')
          .get();

      Map<String, double> categoryTotals = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final category = data['category'] as String;
        final amount = (data['amount'] ?? 0).toDouble();

        categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
      }

      return categoryTotals;
    } catch (e) {
      return {};
    }
  }

  // Get last 6 months data
  Future<Map<String, Map<int, double>>> getLast6MonthsData() async {
    if (currentUserId == null) {
      return {'income': {}, 'expense': {}};
    }

    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month - 5, 1);

    try {
      final snapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: currentUserId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .get();

      Map<int, double> monthlyIncome = {};
      Map<int, double> monthlyExpense = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final date = (data['date'] as Timestamp).toDate();
        final amount = (data['amount'] ?? 0).toDouble();
        final type = data['type'] as String;
        final month = date.month;

        if (type == 'income') {
          monthlyIncome[month] = (monthlyIncome[month] ?? 0) + amount;
        } else {
          monthlyExpense[month] = (monthlyExpense[month] ?? 0) + amount;
        }
      }

      return {
        'income': monthlyIncome,
        'expense': monthlyExpense,
      };
    } catch (e) {
      return {'income': {}, 'expense': {}};
    }
  }
}