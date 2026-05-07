// lib/providers/finance_provider.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/account.dart';
import '../models/transaction.dart';

class FinanceProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  List<Account> _accounts = [];
  List<AppTransaction> _transactions = [];

  // ── FIX 1: _isLoading is now a proper mutable field ───────────────────────
  bool _isLoading = false;

  String? _userId;
  double _monthlyBudget = 0.0;

  // ── FIX 2: Pagination state for "Load More" ────────────────────────────────
  static const int _pageSize = 20;
  DocumentSnapshot? _lastTransactionDoc; // cursor for next page
  bool _hasMoreTransactions = true;      // false when all docs are loaded
  bool _isLoadingMore = false;           // separate flag for pagination loader

  // Stream subscriptions — cancel on logout
  StreamSubscription? _accountsSub;
  StreamSubscription? _transactionsSub;

  List<Account> get accounts => _accounts;
  List<AppTransaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMoreTransactions => _hasMoreTransactions;
  double get monthlyBudget => _monthlyBudget;

  // ── Firestore paths ────────────────────────────────────────────────────────
  CollectionReference get _accountsRef =>
      _db.collection('users').doc(_userId).collection('accounts');

  CollectionReference get _transactionsRef =>
      _db.collection('users').doc(_userId).collection('transactions');

  // ── FIX 3: Budget stored in Firestore (not SharedPreferences) ─────────────
  DocumentReference get _settingsRef =>
      _db.collection('users').doc(_userId).collection('settings').doc('prefs');

  // ── Computed getters ───────────────────────────────────────────────────────

  double get totalBalance =>
      _accounts.fold(0, (sum, acc) => sum + acc.balance);

  double get totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0, (sum, t) => sum + t.amount);

  double get totalExpense => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0, (sum, t) => sum + t.amount);

  double get monthlyIncome {
    final now = DateTime.now();
    return _transactions
        .where((t) =>
    t.type == TransactionType.income &&
        t.date.month == now.month &&
        t.date.year == now.year)
        .fold(0, (sum, t) => sum + t.amount);
  }

  double get monthlyExpense {
    final now = DateTime.now();
    return _transactions
        .where((t) =>
    t.type == TransactionType.expense &&
        t.date.month == now.month &&
        t.date.year == now.year)
        .fold(0, (sum, t) => sum + t.amount);
  }

  Map<String, double> get monthlyCategoryExpense {
    final now = DateTime.now();
    final map = <String, double>{};
    for (var t in _transactions) {
      if (t.type == TransactionType.expense &&
          t.date.month == now.month &&
          t.date.year == now.year) {
        map[t.category] = (map[t.category] ?? 0) + t.amount;
      }
    }
    return map;
  }

  List<AppTransaction> get recentTransactions =>
      _transactions.take(10).toList();

  List<AppTransaction> getTransactionsForAccount(String accountId) {
    return _transactions
        .where((t) => t.accountId == accountId || t.toAccountId == accountId)
        .toList();
  }

  String getAccountName(String id) {
    try {
      return _accounts.firstWhere((a) => a.id == id).name;
    } catch (_) {
      return 'Unknown';
    }
  }

  // ── People / Lending getters ───────────────────────────────────────────────

  double get totalLent => _transactions
      .where((t) => t.type == TransactionType.lent)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalReceivedBack => _transactions
      .where((t) => t.type == TransactionType.receivedBack)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get outstandingLent => totalLent - totalReceivedBack;

  List<AppTransaction> get lentTransactions => _transactions
      .where((t) =>
  t.type == TransactionType.lent ||
      t.type == TransactionType.receivedBack)
      .toList();

  Map<String, double> get lentByPerson {
    final map = <String, double>{};
    for (var t in _transactions) {
      if (t.personName == null || t.personName!.isEmpty) continue;
      final name = t.personName!;
      if (t.type == TransactionType.lent) {
        map[name] = (map[name] ?? 0) + t.amount;
      } else if (t.type == TransactionType.receivedBack) {
        map[name] = (map[name] ?? 0) - t.amount;
      }
    }
    map.removeWhere((_, v) => v.abs() < 0.01);
    return map;
  }

  List<AppTransaction> getTransactionsForPerson(String personName) {
    return _transactions
        .where((t) =>
    (t.type == TransactionType.lent ||
        t.type == TransactionType.receivedBack) &&
        t.personName?.toLowerCase() == personName.toLowerCase())
        .toList();
  }

  List<String> get allPersonNames {
    final names = <String>{};
    for (var t in _transactions) {
      if ((t.type == TransactionType.lent ||
          t.type == TransactionType.receivedBack) &&
          t.personName != null &&
          t.personName!.isNotEmpty) {
        names.add(t.personName!);
      }
    }
    return names.toList()..sort();
  }

  // ── Init — called after login ──────────────────────────────────────────────

  void init(String userId) {
    _userId = userId;
    _listenToAccounts();
    _initialLoadTransactions(); // FIX 2: first page load (replaces stream with limit)
    _loadBudget();              // FIX 3: load from Firestore
  }

  // ── FIX 3: Budget — load from Firestore ────────────────────────────────────

  Future<void> _loadBudget() async {
    if (_userId == null) return;
    try {
      final doc = await _settingsRef.get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        _monthlyBudget = (data?['monthlyBudget'] ?? 0).toDouble();
      }
    } catch (e) {
      debugPrint('Load budget error: $e');
    }
    notifyListeners();
  }

  Future<void> setMonthlyBudget(double amount) async {
    if (_userId == null) return;
    // Save to Firestore — works across devices automatically
    await _settingsRef.set({'monthlyBudget': amount}, SetOptions(merge: true));
    _monthlyBudget = amount;
    notifyListeners();
  }

  // ── FIX 1 + 2: Accounts listener (unchanged) ──────────────────────────────

  void _listenToAccounts() {
    _accountsSub?.cancel();
    _isLoading = true;           // FIX 1: set loading true
    notifyListeners();

    _accountsSub = _accountsRef
        .orderBy('createdAt')
        .snapshots()
        .listen((snap) {
      _accounts = snap.docs.map((d) => Account.fromFirestore(d)).toList();
      _isLoading = false;        // FIX 1: clear after first data arrives
      notifyListeners();
    }, onError: (e) {
      _isLoading = false;
      debugPrint('Accounts listen error: $e');
      notifyListeners();
    });
  }

  // ── FIX 2: Pagination — initial load (first _pageSize docs) ───────────────
  //
  // Strategy: We replaced the always-on stream with a one-shot query for
  // the initial page. New transactions added by the user are appended
  // locally in addTransaction(), so the list stays fresh without a live
  // stream sitting on all 200+ docs.
  //
  // Call loadMoreTransactions() from UI when the user scrolls to the bottom.

  Future<void> _initialLoadTransactions() async {
    if (_userId == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      final snap = await _transactionsRef
          .orderBy('date', descending: true)
          .limit(_pageSize)
          .get();

      _transactions = snap.docs
          .map((d) => AppTransaction.fromFirestore(d))
          .toList();

      _lastTransactionDoc = snap.docs.isNotEmpty ? snap.docs.last : null;
      _hasMoreTransactions = snap.docs.length == _pageSize;
    } catch (e) {
      debugPrint('Initial transactions load error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── FIX 2: Load next page — call from UI "Load More" button / scroll ───────

  Future<void> loadMoreTransactions() async {
    if (_userId == null) return;
    if (_isLoadingMore) return;          // prevent double-tap
    if (!_hasMoreTransactions) return;   // nothing left to load
    if (_lastTransactionDoc == null) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final snap = await _transactionsRef
          .orderBy('date', descending: true)
          .startAfterDocument(_lastTransactionDoc!)
          .limit(_pageSize)
          .get();

      final newTxns = snap.docs
          .map((d) => AppTransaction.fromFirestore(d))
          .toList();

      _transactions.addAll(newTxns);
      _lastTransactionDoc = snap.docs.isNotEmpty ? snap.docs.last : _lastTransactionDoc;
      _hasMoreTransactions = snap.docs.length == _pageSize;
    } catch (e) {
      debugPrint('Load more transactions error: $e');
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  // ── Refresh — pull-to-refresh from UI ─────────────────────────────────────

  Future<void> refreshTransactions() async {
    _lastTransactionDoc = null;
    _hasMoreTransactions = true;
    _transactions = [];
    await _initialLoadTransactions();
  }

  // ── ACCOUNTS ───────────────────────────────────────────────────────────────

  Future<void> addAccount({
    required String name,
    required AccountType type,
    required double initialBalance,
    String? bankName,
    String? accountNumber,
    required String color,
  }) async {
    final id = _uuid.v4();
    final account = Account(
      id: id,
      name: name,
      type: type,
      balance: initialBalance,
      bankName: bankName,
      accountNumber: accountNumber,
      color: color,
      userId: _userId!,
      createdAt: DateTime.now(),
    );
    await _accountsRef.doc(id).set(account.toMap());
  }

  Future<void> updateAccount({
    required String accountId,
    required String name,
    required AccountType type,
    String? bankName,
    String? accountNumber,
    required String color,
  }) async {
    await _accountsRef.doc(accountId).update({
      'name': name,
      'type': type.name,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'color': color,
    });
  }

  Future<void> deleteAccount(String accountId) async {
    final batch = _db.batch();

    batch.delete(_accountsRef.doc(accountId));

    final txns = await _transactionsRef
        .where('accountId', isEqualTo: accountId)
        .get();
    for (var doc in txns.docs) {
      batch.delete(doc.reference);
    }

    final toTxns = await _transactionsRef
        .where('toAccountId', isEqualTo: accountId)
        .get();
    for (var doc in toTxns.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();

    // Also remove from local list
    _transactions.removeWhere(
            (t) => t.accountId == accountId || t.toAccountId == accountId);
    notifyListeners();
  }

  // ── TRANSACTIONS ───────────────────────────────────────────────────────────

  Future<void> addTransaction({
    required TransactionType type,
    required double amount,
    required String category,
    required String accountId,
    String? toAccountId,
    String? personName,
    required String note,
    required DateTime date,
  }) async {
    final id = _uuid.v4();
    final txn = AppTransaction(
      id: id,
      type: type,
      amount: amount,
      category: category,
      accountId: accountId,
      toAccountId: toAccountId,
      personName: personName,
      note: note,
      date: date,
      userId: _userId!,
    );

    final batch = _db.batch();

    batch.set(_transactionsRef.doc(id), txn.toMap());

    final accountRef = _accountsRef.doc(accountId);
    if (type == TransactionType.income) {
      batch.update(accountRef, {'balance': FieldValue.increment(amount)});
    } else if (type == TransactionType.expense) {
      batch.update(accountRef, {'balance': FieldValue.increment(-amount)});
    } else if (type == TransactionType.transfer && toAccountId != null) {
      batch.update(accountRef, {'balance': FieldValue.increment(-amount)});
      batch.update(
        _accountsRef.doc(toAccountId),
        {'balance': FieldValue.increment(amount)},
      );
    } else if (type == TransactionType.lent) {
      batch.update(accountRef, {'balance': FieldValue.increment(-amount)});
    } else if (type == TransactionType.receivedBack) {
      batch.update(accountRef, {'balance': FieldValue.increment(amount)});
    }

    await batch.commit();

    // FIX 2: Insert new transaction at the top of the local list immediately
    // so UI updates without waiting for a full reload
    _transactions.insert(0, txn);
    notifyListeners();
  }

  Future<void> updateTransaction({
    required AppTransaction oldTxn,
    required TransactionType newType,
    required double newAmount,
    required String newCategory,
    required String newAccountId,
    String? newToAccountId,
    String? newPersonName,
    required String newNote,
    required DateTime newDate,
  }) async {
    final batch = _db.batch();

    // 1. Reverse old balance impact
    final oldAccountRef = _accountsRef.doc(oldTxn.accountId);
    if (oldTxn.type == TransactionType.income) {
      batch.update(oldAccountRef, {'balance': FieldValue.increment(-oldTxn.amount)});
    } else if (oldTxn.type == TransactionType.expense) {
      batch.update(oldAccountRef, {'balance': FieldValue.increment(oldTxn.amount)});
    } else if (oldTxn.type == TransactionType.transfer && oldTxn.toAccountId != null) {
      batch.update(oldAccountRef, {'balance': FieldValue.increment(oldTxn.amount)});
      batch.update(_accountsRef.doc(oldTxn.toAccountId!), {'balance': FieldValue.increment(-oldTxn.amount)});
    } else if (oldTxn.type == TransactionType.lent) {
      batch.update(oldAccountRef, {'balance': FieldValue.increment(oldTxn.amount)});
    } else if (oldTxn.type == TransactionType.receivedBack) {
      batch.update(oldAccountRef, {'balance': FieldValue.increment(-oldTxn.amount)});
    }

    // 2. Update Firestore doc
    final txnRef = _transactionsRef.doc(oldTxn.id);
    batch.update(txnRef, {
      'type': newType.name,
      'amount': newAmount,
      'category': newCategory,
      'accountId': newAccountId,
      'toAccountId': newToAccountId,
      'personName': newPersonName,
      'note': newNote,
      'date': Timestamp.fromDate(newDate),
    });

    // 3. Apply new balance impact
    final newAccountRef = _accountsRef.doc(newAccountId);
    if (newType == TransactionType.income) {
      batch.update(newAccountRef, {'balance': FieldValue.increment(newAmount)});
    } else if (newType == TransactionType.expense) {
      batch.update(newAccountRef, {'balance': FieldValue.increment(-newAmount)});
    } else if (newType == TransactionType.transfer && newToAccountId != null) {
      batch.update(newAccountRef, {'balance': FieldValue.increment(-newAmount)});
      batch.update(_accountsRef.doc(newToAccountId), {'balance': FieldValue.increment(newAmount)});
    } else if (newType == TransactionType.lent) {
      batch.update(newAccountRef, {'balance': FieldValue.increment(-newAmount)});
    } else if (newType == TransactionType.receivedBack) {
      batch.update(newAccountRef, {'balance': FieldValue.increment(newAmount)});
    }

    await batch.commit();

    // FIX 2: Update local list in-place so UI reflects edit immediately
    final idx = _transactions.indexWhere((t) => t.id == oldTxn.id);
    if (idx != -1) {
      _transactions[idx] = AppTransaction(
        id: oldTxn.id,
        type: newType,
        amount: newAmount,
        category: newCategory,
        accountId: newAccountId,
        toAccountId: newToAccountId,
        personName: newPersonName,
        note: newNote,
        date: newDate,
        userId: oldTxn.userId,
      );
      notifyListeners();
    }
  }

  Future<void> deleteTransaction(AppTransaction txn) async {
    final batch = _db.batch();

    batch.delete(_transactionsRef.doc(txn.id));

    final accountRef = _accountsRef.doc(txn.accountId);
    if (txn.type == TransactionType.income) {
      batch.update(accountRef, {'balance': FieldValue.increment(-txn.amount)});
    } else if (txn.type == TransactionType.expense) {
      batch.update(accountRef, {'balance': FieldValue.increment(txn.amount)});
    } else if (txn.type == TransactionType.transfer &&
        txn.toAccountId != null) {
      batch.update(accountRef, {'balance': FieldValue.increment(txn.amount)});
      batch.update(
        _accountsRef.doc(txn.toAccountId!),
        {'balance': FieldValue.increment(-txn.amount)},
      );
    } else if (txn.type == TransactionType.lent) {
      batch.update(accountRef, {'balance': FieldValue.increment(txn.amount)});
    } else if (txn.type == TransactionType.receivedBack) {
      batch.update(accountRef, {'balance': FieldValue.increment(-txn.amount)});
    }

    await batch.commit();

    // FIX 2: Remove from local list immediately
    _transactions.removeWhere((t) => t.id == txn.id);
    notifyListeners();
  }

  // ── Clear — called on logout ───────────────────────────────────────────────

  void clear() {
    _accountsSub?.cancel();
    _transactionsSub?.cancel();
    _accountsSub = null;
    _transactionsSub = null;
    _accounts = [];
    _transactions = [];
    _lastTransactionDoc = null;
    _hasMoreTransactions = true;
    _isLoading = false;
    _isLoadingMore = false;
    _userId = null;
    notifyListeners();
  }
}