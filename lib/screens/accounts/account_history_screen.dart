// lib/screens/accounts/account_history_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/finance_provider.dart';
import '../../models/account.dart';
import '../../models/transaction.dart';
import '../../utils/theme.dart';
import '../transactions/edit_transaction_screen.dart';

class AccountHistoryScreen extends StatefulWidget {
  final Account account;

  const AccountHistoryScreen({super.key, required this.account});

  @override
  State<AccountHistoryScreen> createState() => _AccountHistoryScreenState();
}

class _AccountHistoryScreenState extends State<AccountHistoryScreen> {
  String _filter = 'All';
  String _searchQuery = '';
  String _sortMode = 'Date (Newest)';

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = AppTheme.hexToColor(widget.account.color);

    // All txns for this account
    var txns = finance.getTransactionsForAccount(widget.account.id);

    // Filter by type
    txns = txns.where((t) {
      if (_filter == 'Income' && t.type != TransactionType.income) return false;
      if (_filter == 'Expense' && t.type != TransactionType.expense) return false;
      if (_filter == 'Transfer' && t.type != TransactionType.transfer) return false;
      if (_filter == 'Lent' && t.type != TransactionType.lent) return false;
      if (_filter == 'Received' && t.type != TransactionType.receivedBack) return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        if (!t.category.toLowerCase().contains(q) &&
            !t.note.toLowerCase().contains(q) &&
            !(t.personName?.toLowerCase().contains(q) ?? false)) {
          return false;
        }
      }
      return true;
    }).toList();

    // Sort
    if (_sortMode == 'Date (Newest)') {
      txns.sort((a, b) => b.date.compareTo(a.date));
    } else if (_sortMode == 'Date (Oldest)') {
      txns.sort((a, b) => a.date.compareTo(b.date));
    } else if (_sortMode == 'Amount (High)') {
      txns.sort((a, b) => b.amount.compareTo(a.amount));
    } else if (_sortMode == 'Amount (Low)') {
      txns.sort((a, b) => a.amount.compareTo(b.amount));
    }

    // Stats (unfiltered)
    final allTxns = finance.getTransactionsForAccount(widget.account.id);
    final totalIn = allTxns
        .where((t) =>
    t.type == TransactionType.income ||
        t.type == TransactionType.receivedBack ||
        (t.type == TransactionType.transfer && t.toAccountId == widget.account.id))
        .fold(0.0, (s, t) => s + t.amount);
    final totalOut = allTxns
        .where((t) =>
    t.type == TransactionType.expense ||
        t.type == TransactionType.lent ||
        (t.type == TransactionType.transfer && t.accountId == widget.account.id))
        .fold(0.0, (s, t) => s + t.amount);

    return Scaffold(
      backgroundColor: AppColors.bg(isDark),
      body: CustomScrollView(
        slivers: [
          // ── Collapsible header ──────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: color,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: _AccountHeader(
                account: widget.account,
                color: color,
                totalIn: totalIn,
                totalOut: totalOut,
                txnCount: allTxns.length,
              ),
            ),
            title: Text(
              widget.account.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            actions: [
              PopupMenuButton<String>(
                icon: Icon(Icons.sort, color: Colors.white),
                color: AppColors.card(isDark),
                onSelected: (v) => setState(() => _sortMode = v),
                itemBuilder: (_) => [
                  'Date (Newest)',
                  'Date (Oldest)',
                  'Amount (High)',
                  'Amount (Low)',
                ]
                    .map((s) => PopupMenuItem(
                  value: s,
                  child: Text(
                    s,
                    style: TextStyle(
                      color: _sortMode == s ? AppColors.primary : null,
                      fontWeight: _sortMode == s
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ))
                    .toList(),
              ),
            ],
          ),

          // ── Search bar ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Search transactions...',
                  prefixIcon: Icon(Icons.search, size: 20),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  filled: true,
                  fillColor: AppColors.card(isDark),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),

          // ── Filter chips ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    'All',
                    'Income',
                    'Expense',
                    'Transfer',
                    'Lent',
                    'Received',
                  ].map((f) {
                    final selected = _filter == f;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(f),
                        selected: selected,
                        onSelected: (_) => setState(() => _filter = f),
                        selectedColor: color.withValues(alpha: 0.15),
                        checkmarkColor: color,
                        backgroundColor:
                        isDark ? AppColors.darkCard : Colors.white,
                        labelStyle: TextStyle(
                          color: selected ? color : AppColors.textTertiary(isDark),
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: selected
                                ? color.withValues(alpha: 0.5)
                                : Colors.transparent,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          // ── Transaction count label ────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Text(
                '${txns.length} transaction${txns.length != 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textTertiary(isDark),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // ── Transaction list ───────────────────────────────────────────
          txns.isEmpty
              ? SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🔍',
                      style: TextStyle(fontSize: 40)),
                  SizedBox(height: 12),
                  Text(
                    'No transactions found',
                    style: TextStyle(color: AppColors.textTertiary(isDark)),
                  ),
                ],
              ),
            ),
          )
              : SliverList(
            delegate: SliverChildBuilderDelegate(
                  (ctx, i) => _HistoryTxnCard(
                txn: txns[i],
                finance: finance,
                accountId: widget.account.id,
                isDark: isDark,
              ),
              childCount: txns.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

// ── HEADER ─────────────────────────────────────────────────────────────────────

class _AccountHeader extends StatelessWidget {
  final Account account;
  final Color color;
  final double totalIn;
  final double totalOut;
  final int txnCount;

  const _AccountHeader({
    required this.account,
    required this.color,
    required this.totalIn,
    required this.totalOut,
    required this.txnCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 56, 20, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Account type badge
          Row(
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      account.type == AccountType.cash
                          ? Icons.money_rounded
                          : account.type == AccountType.bank
                          ? Icons.account_balance_rounded
                          : Icons.account_balance_wallet_rounded,
                      size: 12,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      account.type.name[0].toUpperCase() +
                          account.type.name.substring(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (account.bankName != null) ...[
                const SizedBox(width: 8),
                Text(
                  account.bankName!,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),

          // Balance
          Text(
            AppConstants.formatFull(account.balance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            'Current Balance · $txnCount transactions',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 10),

          // In / Out stats
          Row(
            children: [
              Expanded(
                child: _StatChip(
                  label: 'Total In',
                  amount: totalIn,
                  icon: Icons.arrow_downward_rounded,
                  isPositive: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatChip(
                  label: 'Total Out',
                  amount: totalOut,
                  icon: Icons.arrow_upward_rounded,
                  isPositive: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final bool isPositive;

  const _StatChip({
    required this.label,
    required this.amount,
    required this.icon,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 12, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  AppConstants.formatFull(amount),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── TRANSACTION CARD ───────────────────────────────────────────────────────────

class _HistoryTxnCard extends StatelessWidget {
  final AppTransaction txn;
  final FinanceProvider finance;
  final String accountId;
  final bool isDark;

  const _HistoryTxnCard({
    required this.txn,
    required this.finance,
    required this.accountId,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = txn.type == TransactionType.income;
    final isTransfer = txn.type == TransactionType.transfer;
    final isLent = txn.type == TransactionType.lent;
    final isReceivedBack = txn.type == TransactionType.receivedBack;

    // For transfers, show direction relative to this account
    final isTransferIn =
        isTransfer && txn.toAccountId == accountId;

    final color = isTransfer
        ? AppTheme.transfer
        : isIncome
        ? AppTheme.income
        : isLent
        ? AppTheme.lent
        : isReceivedBack
        ? AppTheme.receivedBack
        : AppTheme.expense;

    final amountSign = isIncome || isReceivedBack || isTransferIn
        ? '+'
        : isTransfer
        ? '⇄'
        : isLent
        ? '→'
        : '-';

    return Dismissible(
      key: Key(txn.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        decoration: BoxDecoration(
          color: AppTheme.expense.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline, color: AppTheme.expense),
      ),
      confirmDismiss: (_) async => await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Delete Transaction?'),
          content:
          const Text('This will also reverse the balance change.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.expense),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete'),
            ),
          ],
        ),
      ),
      onDismissed: (_) =>
          context.read<FinanceProvider>().deleteTransaction(txn),
      child: GestureDetector(
        onTap: () => _showOptions(context),
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.card(isDark),
            borderRadius: BorderRadius.circular(14),
            border:
            isDark ? Border.all(color: AppColors.darkBorder) : null,
            boxShadow: isDark
                ? []
                : [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8),
            ],
          ),
          child: Row(
            children: [
              // Icon
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
              const SizedBox(width: 12),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(txn.category,
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14,
                            color: AppColors.textPrimary(isDark))),
                    const SizedBox(height: 2),
                    if (txn.personName != null &&
                        txn.personName!.isNotEmpty)
                      Text(
                        '${isLent ? '→' : '←'} ${txn.personName!}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isLent
                              ? AppColors.lent
                              : AppColors.receivedBack,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    if (isTransfer)
                      Text(
                        isTransferIn
                            ? '← From ${finance.getAccountName(txn.accountId)}'
                            : '→ To ${finance.getAccountName(txn.toAccountId!)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.transfer.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    if (txn.note.isNotEmpty)
                      Text(
                        txn.note,
                        style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textTertiary(isDark)),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),

              // Amount + date
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$amountSign${AppConstants.formatFull(txn.amount)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    DateFormat('dd MMM, yyyy').format(txn.date),
                    style: TextStyle(
                        fontSize: 11, color: AppColors.textTertiary(isDark)),
                  ),
                  Text(
                    DateFormat('hh:mm a').format(txn.date),
                    style: TextStyle(
                        fontSize: 10, color: AppColors.textTertiary(isDark)),
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
          borderRadius:
          const BorderRadius.vertical(top: Radius.circular(20)),
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
                child: Icon(Icons.edit_rounded,
                    color: AppColors.primaryDark),
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
                child: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.expense),
              ),
              title: Text('Delete Transaction',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.expense)),
              subtitle:
              Text('This will reverse the balance change', style: TextStyle(color: AppColors.textTertiary(isDark))),
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
        content:
        const Text('This will also reverse the balance change.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.expense),
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
    final all = [
      ...incomeCategories,
      ...expenseCategories,
      ...lentCategories,
      ...receivedCategories,
    ];
    try {
      return all
          .firstWhere((c) => c['name'] == category)['icon'] as String;
    } catch (_) {
      return '💳';
    }
  }
}