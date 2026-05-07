// lib/screens/transactions/transactions_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/finance_provider.dart';
import '../../models/transaction.dart';
import '../../utils/theme.dart';
import 'edit_transaction_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _filter = 'All';
  String _searchQuery = '';
  String? _selectedAccountId;
  String _sortMode = 'Date (Newest)';

  // ── Scroll controller to detect bottom-of-list for auto load-more ──────────
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Trigger loadMore when user is within 200px of the bottom
  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      context.read<FinanceProvider>().loadMoreTransactions();
    }
  }

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ── isLoading: show full-screen shimmer on very first load ─────────────
    if (finance.isLoading && finance.transactions.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.bg(isDark),
        appBar: AppBar(
          title: const Text('Transactions'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    var filtered = finance.transactions.where((t) {
      if (_filter == 'Income' && t.type != TransactionType.income) return false;
      if (_filter == 'Expense' && t.type != TransactionType.expense) return false;
      if (_filter == 'Transfer' && t.type != TransactionType.transfer) return false;
      if (_filter == 'Lent' && t.type != TransactionType.lent) return false;
      if (_filter == 'Received' && t.type != TransactionType.receivedBack) return false;

      if (_selectedAccountId != null && _selectedAccountId != 'All') {
        if (t.accountId != _selectedAccountId && t.toAccountId != _selectedAccountId) return false;
      }

      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        if (!t.category.toLowerCase().contains(q) &&
            !t.note.toLowerCase().contains(q)) {
          return false;
        }
      }
      return true;
    }).toList();

    if (_sortMode == 'Date (Newest)') {
      filtered.sort((a, b) => b.date.compareTo(a.date));
    } else if (_sortMode == 'Date (Oldest)') {
      filtered.sort((a, b) => a.date.compareTo(b.date));
    } else if (_sortMode == 'Amount (High)') {
      filtered.sort((a, b) => b.amount.compareTo(a.amount));
    } else if (_sortMode == 'Amount (Low)') {
      filtered.sort((a, b) => a.amount.compareTo(b.amount));
    }

    return Scaffold(
      backgroundColor: AppColors.bg(isDark),
      appBar: AppBar(
        title: const Text('Transactions'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search & Sort Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Search transactions...',
                      prefixIcon: Icon(Icons.search, size: 20, color: AppColors.textTertiary(isDark)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      filled: true,
                      fillColor: AppColors.card(isDark),
                      hintStyle: TextStyle(color: AppColors.textTertiary(isDark)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.border(isDark)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.brand(isDark), width: 1.5),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.card(isDark),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: PopupMenuButton<String>(
                    icon: Icon(Icons.sort, color: AppColors.textPrimary(isDark)),
                    color: AppColors.card(isDark),
                    onSelected: (v) => setState(() => _sortMode = v),
                    itemBuilder: (ctx) => [
                      'Date (Newest)',
                      'Date (Oldest)',
                      'Amount (High)',
                      'Amount (Low)'
                    ]
                        .map((s) => PopupMenuItem(
                      value: s,
                      child: Text(
                        s,
                        style: TextStyle(
                          color: _sortMode == s
                              ? AppColors.brand(isDark)
                              : AppColors.textPrimary(isDark),
                          fontWeight: _sortMode == s
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Account Dropdown
          if (finance.accounts.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.card(isDark),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedAccountId,
                    hint: Text('All Accounts', style: TextStyle(color: AppColors.textTertiary(isDark))),
                    isExpanded: true,
                    dropdownColor: AppColors.card(isDark),
                    style: TextStyle(color: AppColors.textPrimary(isDark), fontSize: 14),
                    items: [
                      DropdownMenuItem(
                          value: 'All', child: Text('All Accounts', style: TextStyle(color: AppColors.textPrimary(isDark)))),
                      ...finance.accounts.map((a) =>
                          DropdownMenuItem(value: a.id, child: Text(a.name, style: TextStyle(color: AppColors.textPrimary(isDark)))))
                    ],
                    onChanged: (v) => setState(() => _selectedAccountId = v),
                  ),
                ),
              ),
            ),

          // Filter chips
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Income', 'Expense', 'Transfer', 'Lent', 'Received']
                    .map((f) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(f),
                    selected: _filter == f,
                    onSelected: (_) => setState(() => _filter = f),
                    selectedColor: AppColors.brand(isDark).withValues(alpha: isDark ? 0.25 : 0.15),
                    checkmarkColor: AppColors.brand(isDark),
                    backgroundColor: AppColors.card(isDark),
                    labelStyle: TextStyle(
                      color: _filter == f
                          ? AppColors.brand(isDark)
                          : AppColors.textSecondary(isDark),
                      fontWeight: _filter == f
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: _filter == f
                            ? AppColors.brand(isDark).withValues(alpha: 0.5)
                            : Colors.transparent,
                      ),
                    ),
                  ),
                ))
                    .toList(),
              ),
            ),
          ),
          SizedBox(height: 8),

          Expanded(
            child: filtered.isEmpty
                ? Center(
                child: Text('No transactions found',
                    style: TextStyle(color: AppColors.textTertiary(isDark))))
            // ── Pull-to-refresh wraps the list ───────────────────────────
                : RefreshIndicator(
              color: AppColors.primaryDark,
              onRefresh: () =>
                  context.read<FinanceProvider>().refreshTransactions(),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                // +1 for the "Load More" footer at the bottom
                itemCount: filtered.length + 1,
                itemBuilder: (ctx, i) {
                  // ── Last item = Load More footer ─────────────────────
                  if (i == filtered.length) {
                    return _LoadMoreFooter(finance: finance);
                  }
                  return _TxnCard(
                    txn: filtered[i],
                    finance: finance,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Load More Footer Widget ────────────────────────────────────────────────────
class _LoadMoreFooter extends StatelessWidget {
  final FinanceProvider finance;
  const _LoadMoreFooter({required this.finance});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Still loading next page — show a small spinner
    if (finance.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    // No more pages — show end-of-list message
    if (!finance.hasMoreTransactions) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text(
            'All transactions loaded',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textTertiary(isDark),
            ),
          ),
        ),
      );
    }

    // Still has more — show manual "Load More" button
    // (auto-scroll also triggers via _onScroll, this is for users who don't scroll far enough)
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: OutlinedButton.icon(
          onPressed: () => context.read<FinanceProvider>().loadMoreTransactions(),
          icon: const Icon(Icons.expand_more_rounded, size: 18),
          label: const Text('Load more'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.brand(isDark),
            side: BorderSide(color: AppColors.brand(isDark).withValues(alpha: 0.4)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Transaction Card (unchanged) ───────────────────────────────────────────────
class _TxnCard extends StatelessWidget {
  final AppTransaction txn;
  final FinanceProvider finance;
  const _TxnCard({required this.txn, required this.finance});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isIncome = txn.type == TransactionType.income;
    final isTransfer = txn.type == TransactionType.transfer;
    final isLent = txn.type == TransactionType.lent;
    final isReceivedBack = txn.type == TransactionType.receivedBack;
    final color = isTransfer
        ? AppTheme.transfer
        : isIncome
        ? AppTheme.income
        : isLent
        ? AppTheme.lent
        : isReceivedBack
        ? AppTheme.receivedBack
        : AppTheme.expense;

    return Dismissible(
      key: Key(txn.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.expense.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline, color: AppTheme.expense),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Transaction?'),
            content: const Text('This will also reverse the balance change.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style:
                ElevatedButton.styleFrom(backgroundColor: AppTheme.expense),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) {
        context.read<FinanceProvider>().deleteTransaction(txn);
      },
      child: GestureDetector(
        onTap: () => _showOptions(context),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.card(isDark),
            borderRadius: BorderRadius.circular(14),
            border: isDark ? Border.all(color: AppColors.darkBorder) : null,
            boxShadow: isDark
                ? []
                : [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _emoji(txn.category),
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(txn.category,
                        style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary(isDark))),
                    const SizedBox(height: 2),
                    if (txn.personName != null && txn.personName!.isNotEmpty)
                      Text(
                        '${isLent ? "→" : "←"} ${txn.personName!}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isLent ? AppColors.lent : AppColors.receivedBack,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    Text(
                      '${finance.getAccountName(txn.accountId)}${isTransfer && txn.toAccountId != null ? ' → ${finance.getAccountName(txn.toAccountId!)}' : ''}',
                      style: TextStyle(fontSize: 11, color: AppColors.textTertiary(isDark)),
                    ),
                    if (txn.note.isNotEmpty)
                      Text(
                        txn.note,
                        style:
                        TextStyle(fontSize: 11, color: AppColors.textTertiary(isDark)),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isIncome ? '+' : isTransfer ? '⇄' : isLent ? '→' : isReceivedBack ? '←' : '-'}${AppConstants.formatFull(txn.amount)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    DateFormat('dd MMM, yyyy').format(txn.date),
                    style: TextStyle(fontSize: 11, color: AppColors.textTertiary(isDark)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface(isDark),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.brand(isDark).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child:
                Icon(Icons.edit_rounded, color: AppColors.brand(isDark)),
              ),
              title: Text('Edit Transaction',
                  style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary(isDark))),
              subtitle: Text('Modify this transaction', style: TextStyle(color: AppColors.textTertiary(isDark))),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  AppSlideUpRoute(page: EditTransactionScreen(transaction: txn)),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.expense.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.delete_outline_rounded,
                    color: AppColors.expense),
              ),
              title: Text('Delete Transaction',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: AppColors.expense)),
              subtitle: Text('This will reverse the balance change', style: TextStyle(color: AppColors.textTertiary(isDark))),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Transaction?'),
        content: const Text('This will also reverse the balance change.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.expense),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<FinanceProvider>().deleteTransaction(txn);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _emoji(String category) {
    final all = [...incomeCategories, ...expenseCategories, ...lentCategories];
    try {
      return all.firstWhere((c) => c['name'] == category)['icon'] as String;
    } catch (_) {
      if (category == 'Received Back') return '💸';
      return '💳';
    }
  }
}