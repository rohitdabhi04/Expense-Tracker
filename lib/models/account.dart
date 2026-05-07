// lib/models/account.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum AccountType { cash, bank, wallet }

class Account {
  final String id;
  final String name;
  final AccountType type;
  final double balance;
  final String? bankName;
  final String? accountNumber; // last 4 digits only
  final String color; // hex color
  final String userId;
  final DateTime createdAt;

  Account({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    this.bankName,
    this.accountNumber,
    required this.color,
    required this.userId,
    required this.createdAt,
  });

  factory Account.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Account(
      id: doc.id,
      name: data['name'] ?? '',
      type: AccountType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => AccountType.cash,
      ),
      balance: (data['balance'] ?? 0).toDouble(),
      bankName: data['bankName'],
      accountNumber: data['accountNumber'],
      color: data['color'] ?? '#6C63FF',
      userId: data['userId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type.name,
      'balance': balance,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'color': color,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Account copyWith({
    String? name,
    AccountType? type,
    double? balance,
    String? bankName,
    String? accountNumber,
    String? color,
  }) {
    return Account(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      color: color ?? this.color,
      userId: userId,
      createdAt: createdAt,
    );
  }
}
