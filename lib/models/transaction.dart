// lib/models/transaction.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType { expense, income, transfer, lent, receivedBack }

class AppTransaction {
  final String id;
  final TransactionType type;
  final double amount;
  final String category;
  final String accountId;
  final String? toAccountId; // for transfers
  final String? personName; // for lent / receivedBack
  final String note;
  final DateTime date;
  final String userId;

  AppTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    required this.accountId,
    this.toAccountId,
    this.personName,
    required this.note,
    required this.date,
    required this.userId,
  });

  factory AppTransaction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppTransaction(
      id: doc.id,
      type: TransactionType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => TransactionType.expense,
      ),
      amount: (data['amount'] ?? 0).toDouble(),
      category: data['category'] ?? 'Other',
      accountId: data['accountId'] ?? '',
      toAccountId: data['toAccountId'],
      personName: data['personName'],
      note: data['note'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      userId: data['userId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'amount': amount,
      'category': category,
      'accountId': accountId,
      'toAccountId': toAccountId,
      'personName': personName,
      'note': note,
      'date': Timestamp.fromDate(date),
      'userId': userId,
    };
  }
}

// Predefined categories
const List<Map<String, dynamic>> incomeCategories = [
  {'name': 'Salary', 'icon': '💼'},
  {'name': 'Freelance', 'icon': '💻'},
  {'name': 'Business', 'icon': '🏢'},
  {'name': 'Investment', 'icon': '📈'},
  {'name': 'Gift', 'icon': '🎁'},
  {'name': 'Other Income', 'icon': '💰'},
];

const List<Map<String, dynamic>> expenseCategories = [
  {'name': 'Food', 'icon': '🍔'},
  {'name': 'Transport', 'icon': '🚗'},
  {'name': 'Shopping', 'icon': '🛍️'},
  {'name': 'Bills', 'icon': '📄'},
  {'name': 'Health', 'icon': '💊'},
  {'name': 'Entertainment', 'icon': '🎬'},
  {'name': 'Education', 'icon': '📚'},
  {'name': 'Rent', 'icon': '🏠'},
  {'name': 'Groceries', 'icon': '🛒'},
  {'name': 'EMI', 'icon': '🏦'},
  {'name': 'Fuel', 'icon': '⛽'},
  {'name': 'Other', 'icon': '📦'},
];

const List<Map<String, dynamic>> lentCategories = [
  {'name': 'Friend', 'icon': '👫'},
  {'name': 'Family', 'icon': '👨‍👩‍👧‍👦'},
  {'name': 'Relative', 'icon': '🧑‍🤝‍🧑'},
  {'name': 'Colleague', 'icon': '🧑‍💼'},
  {'name': 'Neighbour', 'icon': '🏘️'},
  {'name': 'Other', 'icon': '📦'},
];

// Used for "Received" (borrowed by you / money received back)
const List<Map<String, dynamic>> receivedCategories = [
  {'name': 'Friend', 'icon': '👫'},
  {'name': 'Family', 'icon': '👨‍👩‍👧‍👦'},
  {'name': 'Relative', 'icon': '🧑‍🤝‍🧑'},
  {'name': 'Colleague', 'icon': '🧑‍💼'},
  {'name': 'Neighbour', 'icon': '🏘️'},
  {'name': 'Other', 'icon': '📦'},
];
