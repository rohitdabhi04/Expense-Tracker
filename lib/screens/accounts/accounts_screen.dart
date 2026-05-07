// lib/screens/accounts/accounts_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/finance_provider.dart';
import '../../models/account.dart';
import '../../utils/theme.dart';
import 'account_history_screen.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final bg      = isDark ? AppColors.darkBg : AppColors.lightBg;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg(isDark),
        title: Text(
          'My Accounts',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary(isDark),
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add_rounded,
                color: AppColors.textPrimary(isDark)),
            onPressed: () => _showAddAccountDialog(context),
          ),
        ],
      ),
      body: finance.accounts.isEmpty
          ? _EmptyState(isDark: isDark, onAdd: () => _showAddAccountDialog(context))
          : Column(
              children: [
                // Net worth banner
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.account_balance_wallet_rounded,
                            color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Net Worth',
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 12),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              AppConstants.formatFull(finance.totalBalance),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 24,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${finance.accounts.length} account${finance.accounts.length != 1 ? 's' : ''}',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    itemCount: finance.accounts.length,
                    itemBuilder: (ctx, i) => _AccountCard(
                      account: finance.accounts[i],
                      finance: finance,
                      isDark: isDark,
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAccountDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddAccountDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddAccountSheet(),
    );
  }
}

// ── EMPTY STATE ────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final bool isDark;
  final VoidCallback onAdd;

  const _EmptyState({required this.isDark, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.brand(isDark).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🏦', style: TextStyle(fontSize: 44)),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'No accounts yet',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: AppColors.textPrimary(isDark),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Add your cash, bank accounts\nor wallets to get started',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textTertiary(isDark),
                fontSize: 13,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add Account'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── ACCOUNT CARD ───────────────────────────────────────────────────────────────

class _AccountCard extends StatelessWidget {
  final Account account;
  final FinanceProvider finance;
  final bool isDark;

  const _AccountCard({
    required this.account,
    required this.finance,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.hexToColor(account.color);
    final txns  = finance.getTransactionsForAccount(account.id);
    final cardBg = isDark ? AppColors.darkCard : Colors.white;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        AppPageRoute(page: AccountHistoryScreen(account: account)),
      ),
      child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
        boxShadow: [
          if (!isDark)
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05), blurRadius: 12),
        ],
      ),
      child: Column(
        children: [
          // Colored header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    account.type == AccountType.cash
                        ? Icons.money_rounded
                        : account.type == AccountType.bank
                            ? Icons.account_balance_rounded
                            : Icons.account_balance_wallet_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      if (account.bankName != null)
                        Text(
                          account.bankName!,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  icon: Icon(Icons.more_vert, color: Colors.white),
                  color: cardBg,
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_rounded, color: AppColors.brand(isDark)),
                          SizedBox(width: 8),
                          Text('Edit Account'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline,
                              color: AppColors.expense),
                          SizedBox(width: 8),
                          Text('Delete Account'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (v) {
                    if (v == 'edit') _showEditSheet(context);
                    if (v == 'delete') _confirmDelete(context);
                  },
                ),
              ],
            ),
          ),

          // Balance + stats
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Balance',
                        style: TextStyle(
                            color: AppColors.textTertiary(isDark), fontSize: 12),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppConstants.formatFull(account.balance),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                          color: account.balance >= 0
                              ? AppColors.income
                              : AppColors.expense,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${txns.length} transactions',
                      style: TextStyle(
                          color: AppColors.textTertiary(isDark), fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'View History',
                            style: TextStyle(
                              color: color,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(Icons.chevron_right_rounded,
                              size: 13, color: color),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ), // end GestureDetector
    );
  }

  void _showEditSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditAccountSheet(account: account),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account?'),
        content: Text(
          'This will delete "${account.name}" and all its transactions. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.expense,
                foregroundColor: Colors.white),
            onPressed: () {
              context.read<FinanceProvider>().deleteAccount(account.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ── ADD ACCOUNT SHEET ──────────────────────────────────────────────────────────

class _AddAccountSheet extends StatefulWidget {
  const _AddAccountSheet();

  @override
  State<_AddAccountSheet> createState() => _AddAccountSheetState();
}

class _AddAccountSheetState extends State<_AddAccountSheet> {
  final _nameCtrl      = TextEditingController();
  final _bankNameCtrl  = TextEditingController();
  final _accountNoCtrl = TextEditingController();
  final _balanceCtrl   = TextEditingController(text: '0');
  AccountType _type    = AccountType.cash;
  String _color        = AppTheme.accountColors[0];

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final bg      = isDark ? AppColors.darkSurface : Colors.white;
    final textCol = AppColors.textPrimary(isDark);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      builder: (_, ctrl) => Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: ListView(
          controller: ctrl,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Add Account',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textCol),
            ),
            const SizedBox(height: 20),

            // Type selector
            Text(
              'Account Type',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: textCol),
            ),
            const SizedBox(height: 10),
            Row(
              children: AccountType.values.map((t) {
                final selected = _type == t;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _type = t),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary
                            : AppColors.primary.withOpacity(
                                isDark ? 0.15 : 0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : Colors.transparent,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            t == AccountType.cash
                                ? '💵'
                                : t == AccountType.bank
                                    ? '🏦'
                                    : '👛',
                            style: const TextStyle(fontSize: 22),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            t.name[0].toUpperCase() + t.name.substring(1),
                            style: TextStyle(
                              fontSize: 11,
                              color: selected
                                  ? Colors.white
                                  : AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _nameCtrl,
              style: TextStyle(color: textCol),
              decoration: InputDecoration(
                hintText: _type == AccountType.cash
                    ? 'e.g. My Wallet'
                    : _type == AccountType.bank
                        ? 'e.g. SBI Savings'
                        : 'e.g. PhonePe',
                labelText: 'Account Name',
              ),
            ),
            if (_type == AccountType.bank) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _bankNameCtrl,
                style: TextStyle(color: textCol),
                decoration: const InputDecoration(
                  labelText: 'Bank Name',
                  hintText: 'e.g. State Bank of India',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _accountNoCtrl,
                style: TextStyle(color: textCol),
                decoration: const InputDecoration(
                  labelText: 'Last 4 digits (optional)',
                  hintText: 'e.g. 4521',
                ),
                keyboardType: TextInputType.number,
                maxLength: 4,
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _balanceCtrl,
              style: TextStyle(color: textCol),
              decoration: const InputDecoration(
                labelText: 'Opening Balance (₹)',
                prefixText: '₹ ',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),

            // Color picker
            Text(
              'Color',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: textCol),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: AppTheme.accountColors.map((c) {
                final selected = _color == c;
                return GestureDetector(
                  onTap: () => setState(() => _color = c),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppTheme.hexToColor(c),
                      shape: BoxShape.circle,
                      border: selected
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: AppTheme.hexToColor(c).withValues(alpha: 0.5),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : [],
                    ),
                    child: selected
                        ? const Icon(Icons.check,
                            color: Colors.white, size: 18)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),

            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text(
                'Add Account',
                style:
                    TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter account name'),
          backgroundColor: AppColors.expense,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    context.read<FinanceProvider>().addAccount(
          name: _nameCtrl.text.trim(),
          type: _type,
          initialBalance: double.tryParse(_balanceCtrl.text) ?? 0,
          bankName: _bankNameCtrl.text.trim().isEmpty
              ? null
              : _bankNameCtrl.text.trim(),
          accountNumber: _accountNoCtrl.text.trim().isEmpty
              ? null
              : _accountNoCtrl.text.trim(),
          color: _color,
        );
    Navigator.pop(context);
  }
}

// ── EDIT ACCOUNT SHEET ─────────────────────────────────────────────────────────

class _EditAccountSheet extends StatefulWidget {
  final Account account;
  const _EditAccountSheet({required this.account});

  @override
  State<_EditAccountSheet> createState() => _EditAccountSheetState();
}

class _EditAccountSheetState extends State<_EditAccountSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _bankNameCtrl;
  late final TextEditingController _accountNoCtrl;
  late AccountType _type;
  late String _color;

  @override
  void initState() {
    super.initState();
    final a = widget.account;
    _nameCtrl = TextEditingController(text: a.name);
    _bankNameCtrl = TextEditingController(text: a.bankName ?? '');
    _accountNoCtrl = TextEditingController(text: a.accountNumber ?? '');
    _type = a.type;
    _color = a.color;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bankNameCtrl.dispose();
    _accountNoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface : Colors.white;
    final textCol = AppColors.textPrimary(isDark);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      builder: (_, ctrl) => Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: ListView(
          controller: ctrl,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Edit Account',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textCol),
            ),
            const SizedBox(height: 20),

            // Type selector
            Text(
              'Account Type',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: textCol),
            ),
            const SizedBox(height: 10),
            Row(
              children: AccountType.values.map((t) {
                final selected = _type == t;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _type = t),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary
                            : AppColors.primary
                                .withOpacity(isDark ? 0.15 : 0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : Colors.transparent,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            t == AccountType.cash
                                ? '💵'
                                : t == AccountType.bank
                                    ? '🏦'
                                    : '👛',
                            style: const TextStyle(fontSize: 22),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            t.name[0].toUpperCase() + t.name.substring(1),
                            style: TextStyle(
                              fontSize: 11,
                              color: selected
                                  ? Colors.white
                                  : AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _nameCtrl,
              style: TextStyle(color: textCol),
              decoration: InputDecoration(
                hintText: _type == AccountType.cash
                    ? 'e.g. My Wallet'
                    : _type == AccountType.bank
                        ? 'e.g. SBI Savings'
                        : 'e.g. PhonePe',
                labelText: 'Account Name',
              ),
            ),
            if (_type == AccountType.bank) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _bankNameCtrl,
                style: TextStyle(color: textCol),
                decoration: const InputDecoration(
                  labelText: 'Bank Name',
                  hintText: 'e.g. State Bank of India',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _accountNoCtrl,
                style: TextStyle(color: textCol),
                decoration: const InputDecoration(
                  labelText: 'Last 4 digits (optional)',
                  hintText: 'e.g. 4521',
                ),
                keyboardType: TextInputType.number,
                maxLength: 4,
              ),
            ],
            const SizedBox(height: 16),

            // Color picker
            Text(
              'Color',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: textCol),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: AppTheme.accountColors.map((c) {
                final selected = _color == c;
                return GestureDetector(
                  onTap: () => setState(() => _color = c),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppTheme.hexToColor(c),
                      shape: BoxShape.circle,
                      border: selected
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: AppTheme.hexToColor(c)
                                    .withValues(alpha: 0.5),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : [],
                    ),
                    child: selected
                        ? const Icon(Icons.check,
                            color: Colors.white, size: 18)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),

            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text(
                'Save Changes',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter account name'),
          backgroundColor: AppColors.expense,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    context.read<FinanceProvider>().updateAccount(
          accountId: widget.account.id,
          name: _nameCtrl.text.trim(),
          type: _type,
          bankName: _bankNameCtrl.text.trim().isEmpty
              ? null
              : _bankNameCtrl.text.trim(),
          accountNumber: _accountNoCtrl.text.trim().isEmpty
              ? null
              : _accountNoCtrl.text.trim(),
          color: _color,
        );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Account updated'),
        backgroundColor: AppColors.income,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    Navigator.pop(context);
  }
}
