// lib/screens/transactions/add_transaction_screen.dart — Premium upgrade
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/finance_provider.dart';
import '../../models/transaction.dart';
import '../../utils/theme.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  TransactionType _type = TransactionType.expense;

  final _amountCtrl      = TextEditingController();
  final _noteCtrl        = TextEditingController();
  final _personNameCtrl  = TextEditingController();
  String? _selectedAccount;
  String? _selectedToAccount;
  // Separate category per tab so switching tabs doesn't leak state
  String? _expenseCategory;
  String? _incomeCategory;
  String? _lentCategory;
  DateTime _date  = DateTime.now();
  bool _saving    = false;

  String? get _selectedCategory {
    if (_type == TransactionType.income) return _incomeCategory;
    if (_type == TransactionType.lent || _type == TransactionType.receivedBack) return _lentCategory;
    return _expenseCategory;
  }

  void _setCategory(String? v) {
    setState(() {
      if (_type == TransactionType.income) {
        _incomeCategory = v;
      } else if (_type == TransactionType.lent || _type == TransactionType.receivedBack) {
        _lentCategory = v;
      } else {
        _expenseCategory = v;
      }
    });
  }

  // Animation
  late AnimationController _sheetCtrl;
  late Animation<Offset> _sheetAnim;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _type = TransactionType.values[_tabController.index];
          _amountCtrl.clear();
        });
      }
    });

    _sheetCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _sheetAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _sheetCtrl, curve: Curves.easeOutCubic));
    _sheetCtrl.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _sheetCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    _personNameCtrl.dispose();
    super.dispose();
  }

  Color get _typeColor {
    switch (_type) {
      case TransactionType.income:
        return AppColors.income;
      case TransactionType.expense:
        return AppColors.expense;
      case TransactionType.transfer:
        return AppColors.transfer;
      case TransactionType.lent:
        return AppColors.lent;
      case TransactionType.receivedBack:
        return AppColors.receivedBack;
    }
  }

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();
    final isDark  = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.bg(isDark),
      appBar: AppBar(
        title: Text('New Transaction'),
        backgroundColor: AppColors.bg(isDark),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SlideTransition(
        position: _sheetAnim,
        child: FadeTransition(
          opacity: _sheetCtrl,
          child: Column(
            children: [
              // Type selector
              _TypeSelector(
                controller: _tabController,
                isDark: isDark,
                selectedColor: _typeColor,
              ),

              // Form
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _TransactionForm(
                      type: TransactionType.expense,
                      amountCtrl: _amountCtrl,
                      noteCtrl: _noteCtrl,
                      selectedAccount: _selectedAccount,
                      selectedCategory: _expenseCategory,
                      date: _date,
                      finance: finance,
                      isDark: isDark,
                      accentColor: AppColors.expense,
                      onAccountChanged: (v) =>
                          setState(() => _selectedAccount = v),
                      onCategoryChanged: (v) =>
                          setState(() => _expenseCategory = v),
                      onDateChanged: (d) => setState(() => _date = d),
                    ),
                    _TransactionForm(
                      type: TransactionType.income,
                      amountCtrl: _amountCtrl,
                      noteCtrl: _noteCtrl,
                      selectedAccount: _selectedAccount,
                      selectedCategory: _incomeCategory,
                      date: _date,
                      finance: finance,
                      isDark: isDark,
                      accentColor: AppColors.income,
                      onAccountChanged: (v) =>
                          setState(() => _selectedAccount = v),
                      onCategoryChanged: (v) =>
                          setState(() => _incomeCategory = v),
                      onDateChanged: (d) => setState(() => _date = d),
                    ),
                    _TransferForm(
                      amountCtrl: _amountCtrl,
                      noteCtrl: _noteCtrl,
                      selectedFrom: _selectedAccount,
                      selectedTo: _selectedToAccount,
                      date: _date,
                      finance: finance,
                      isDark: isDark,
                      onFromChanged: (v) =>
                          setState(() => _selectedAccount = v),
                      onToChanged: (v) =>
                          setState(() => _selectedToAccount = v),
                      onDateChanged: (d) => setState(() => _date = d),
                    ),
                    _LentForm(
                      amountCtrl: _amountCtrl,
                      noteCtrl: _noteCtrl,
                      personNameCtrl: _personNameCtrl,
                      selectedAccount: _selectedAccount,
                      selectedCategory: _lentCategory,
                      date: _date,
                      finance: finance,
                      isDark: isDark,
                      onAccountChanged: (v) =>
                          setState(() => _selectedAccount = v),
                      onCategoryChanged: (v) =>
                          setState(() => _lentCategory = v),
                      onDateChanged: (d) => setState(() => _date = d),
                    ),
                    _ReceivedBackForm(
                      amountCtrl: _amountCtrl,
                      noteCtrl: _noteCtrl,
                      personNameCtrl: _personNameCtrl,
                      selectedAccount: _selectedAccount,
                      selectedCategory: _lentCategory,
                      date: _date,
                      finance: finance,
                      isDark: isDark,
                      onAccountChanged: (v) =>
                          setState(() => _selectedAccount = v),
                      onCategoryChanged: (v) =>
                          setState(() => _lentCategory = v),
                      onDateChanged: (d) => setState(() => _date = d),
                    ),
                  ],
                ),
              ),

              // Save button
              _SaveButton(
                saving: _saving,
                color: _typeColor,
                onTap: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final finance = context.read<FinanceProvider>();
    final amount  = double.tryParse(_amountCtrl.text.trim());

    if (amount == null || amount <= 0) {
      _showError('Enter a valid amount');
      return;
    }
    if (_selectedAccount == null) {
      _showError('Select an account');
      return;
    }
    // Category required for expense, income, lent, receivedBack (not transfer)
    if (_type != TransactionType.transfer &&
        _selectedCategory == null) {
      _showError('Select a category');
      return;
    }
    if (_type == TransactionType.transfer && _selectedToAccount == null) {
      _showError('Select destination account');
      return;
    }
    // Person name required for lent & receivedBack
    if ((_type == TransactionType.lent || _type == TransactionType.receivedBack) &&
        _personNameCtrl.text.trim().isEmpty) {
      _showError('Enter person name');
      return;
    }

    setState(() => _saving = true);
    HapticFeedback.lightImpact();

    try {
      await finance.addTransaction(
        type: _type,
        amount: amount,
        category: _selectedCategory ?? 'Transfer',
        accountId: _selectedAccount!,
        toAccountId: _selectedToAccount,
        personName: (_type == TransactionType.lent || _type == TransactionType.receivedBack)
            ? _personNameCtrl.text.trim()
            : null,
        note: _noteCtrl.text.trim(),
        date: _date,
      );
      if (mounted) {
        HapticFeedback.mediumImpact();
        Navigator.pop(context);
      }
    } catch (e) {
      _showError('Failed to save. Try again.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

// ── TYPE SELECTOR ──────────────────────────────────────────────────────────────

class _TypeSelector extends StatelessWidget {
  final TabController controller;
  final bool isDark;
  final Color selectedColor;

  const _TypeSelector({
    required this.controller,
    required this.isDark,
    required this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bg(isDark),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card(isDark),
          borderRadius: BorderRadius.circular(14),
        ),
        child: TabBar(
          controller: controller,
          indicator: BoxDecoration(
            color: selectedColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: selectedColor.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.darkTextTertiary,
          dividerColor: Colors.transparent,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          tabs: const [
            Tab(text: 'Expense'),
            Tab(text: 'Income'),
            Tab(text: 'Transfer'),
            Tab(text: 'Lent'),
            Tab(text: 'Received'),
          ],
        ),
      ),
    );
  }
}

// ── TRANSACTION FORM ───────────────────────────────────────────────────────────

class _TransactionForm extends StatelessWidget {
  final TransactionType type;
  final TextEditingController amountCtrl, noteCtrl;
  final String? selectedAccount, selectedCategory;
  final DateTime date;
  final FinanceProvider finance;
  final bool isDark;
  final Color accentColor;
  final ValueChanged<String?> onAccountChanged, onCategoryChanged;
  final ValueChanged<DateTime> onDateChanged;

  const _TransactionForm({
    required this.type,
    required this.amountCtrl,
    required this.noteCtrl,
    required this.selectedAccount,
    required this.selectedCategory,
    required this.date,
    required this.finance,
    required this.isDark,
    required this.accentColor,
    required this.onAccountChanged,
    required this.onCategoryChanged,
    required this.onDateChanged,
  });

  List<Map<String, dynamic>> get _categories =>
      type == TransactionType.income ? incomeCategories : expenseCategories;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Amount input — big and centered
          _AmountInput(
            controller: amountCtrl,
            accentColor: accentColor,
            isDark: isDark,
          ),
          const SizedBox(height: 20),

          // Account dropdown
          _DropdownField(
            label: 'Account',
            hint: 'Select account',
            value: selectedAccount,
            icon: Icons.account_balance_wallet_rounded,
            isDark: isDark,
            items: finance.accounts
                .map((a) => DropdownMenuItem(
              value: a.id,
              child: Text(a.name),
            ))
                .toList(),
            onChanged: onAccountChanged,
          ),
          const SizedBox(height: 14),

          // Category grid
          _FieldLabel(label: 'Category', isDark: isDark),
          const SizedBox(height: 10),
          _CategoryGrid(
            categories: _categories,
            selected: selectedCategory,
            accentColor: accentColor,
            isDark: isDark,
            onSelect: onCategoryChanged,
          ),
          const SizedBox(height: 14),

          // Date picker
          _DateField(
            date: date,
            isDark: isDark,
            onChanged: onDateChanged,
          ),
          const SizedBox(height: 14),

          // Note
          _FieldLabel(label: 'Note (optional)', isDark: isDark),
          const SizedBox(height: 8),
          TextField(
            controller: noteCtrl,
            decoration: const InputDecoration(
              hintText: 'Add a note...',
              prefixIcon: Icon(Icons.notes_rounded, size: 18),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// ── TRANSFER FORM ──────────────────────────────────────────────────────────────

class _TransferForm extends StatelessWidget {
  final TextEditingController amountCtrl, noteCtrl;
  final String? selectedFrom, selectedTo;
  final DateTime date;
  final FinanceProvider finance;
  final bool isDark;
  final ValueChanged<String?> onFromChanged, onToChanged;
  final ValueChanged<DateTime> onDateChanged;

  const _TransferForm({
    required this.amountCtrl,
    required this.noteCtrl,
    required this.selectedFrom,
    required this.selectedTo,
    required this.date,
    required this.finance,
    required this.isDark,
    required this.onFromChanged,
    required this.onToChanged,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AmountInput(
            controller: amountCtrl,
            accentColor: AppColors.transfer,
            isDark: isDark,
          ),
          const SizedBox(height: 20),
          _DropdownField(
            label: 'From Account',
            hint: 'Select source',
            value: selectedFrom,
            icon: Icons.arrow_upward_rounded,
            isDark: isDark,
            items: finance.accounts
                .map((a) => DropdownMenuItem(
              value: a.id,
              child: Text(a.name),
            ))
                .toList(),
            onChanged: onFromChanged,
          ),
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.transfer.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.transfer.withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.swap_vert_rounded,
                  color: AppColors.transfer),
            ),
          ),
          const SizedBox(height: 12),
          _DropdownField(
            label: 'To Account',
            hint: 'Select destination',
            value: selectedTo,
            icon: Icons.arrow_downward_rounded,
            isDark: isDark,
            items: finance.accounts
                .where((a) => a.id != selectedFrom)
                .map((a) => DropdownMenuItem(
              value: a.id,
              child: Text(a.name),
            ))
                .toList(),
            onChanged: onToChanged,
          ),
          const SizedBox(height: 14),
          _DateField(date: date, isDark: isDark, onChanged: onDateChanged),
          const SizedBox(height: 14),
          _FieldLabel(label: 'Note (optional)', isDark: isDark),
          const SizedBox(height: 8),
          TextField(
            controller: noteCtrl,
            decoration:
            const InputDecoration(hintText: 'Transfer note...'),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// ── REUSABLE COMPONENTS ────────────────────────────────────────────────────────

class _AmountInput extends StatelessWidget {
  final TextEditingController controller;
  final Color accentColor;
  final bool isDark;

  const _AmountInput({
    required this.controller,
    required this.accentColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border(isDark),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Amount',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textTertiary(isDark),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                AppConstants.currencySymbol,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: accentColor,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary(isDark),
                  ),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    hintStyle: TextStyle(
                      color: AppColors.textTertiary(isDark).withValues(alpha: 0.5),
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                    ),
                    border: InputBorder.none,
                    filled: false,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  final bool isDark;
  const _FieldLabel({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 13,
        color: AppColors.textPrimary(isDark),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label, hint;
  final String? value;
  final IconData icon;
  final bool isDark;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.label,
    required this.hint,
    required this.value,
    required this.icon,
    required this.isDark,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label: label, isDark: isDark),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          items: items,
          onChanged: onChanged,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18),
            hintText: hint,
          ),
          dropdownColor: AppColors.card(isDark),
        ),
      ],
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final String? selected;
  final Color accentColor;
  final bool isDark;
  final ValueChanged<String?> onSelect;

  const _CategoryGrid({
    required this.categories,
    required this.selected,
    required this.accentColor,
    required this.isDark,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((c) {
        final isSelected = selected == c['name'];
        return GestureDetector(
          onTap: () => onSelect(c['name']),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? accentColor
                  : isDark
                  ? AppColors.darkCard
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? accentColor
                    : isDark
                    ? AppColors.darkBorder
                    : AppColors.lightBorder,
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: isSelected
                  ? [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
                  : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(c['icon']!, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  c['name']!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : AppColors.textPrimary(isDark),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _DateField extends StatelessWidget {
  final DateTime date;
  final bool isDark;
  final ValueChanged<DateTime> onChanged;

  const _DateField({
    required this.date,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label: 'Date', isDark: isDark),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final d = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
              builder: (ctx, child) => Theme(
                data: Theme.of(ctx).copyWith(
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: AppColors.primary,
                    primary: AppColors.primary,
                  ),
                ),
                child: child!,
              ),
            );
            if (d != null) onChanged(d);
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.card(isDark),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.border(isDark),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 16, color: AppColors.textTertiary(isDark)),
                SizedBox(width: 10),
                Text(
                  DateFormat('dd MMMM, yyyy').format(date),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary(isDark),
                  ),
                ),
                const Spacer(),
                Icon(Icons.chevron_right,
                    size: 18, color: AppColors.textTertiary(isDark)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SaveButton extends StatelessWidget {
  final bool saving;
  final Color color;
  final VoidCallback onTap;

  const _SaveButton({
    required this.saving,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: GestureDetector(
        onTap: saving ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 54,
          decoration: BoxDecoration(
            color: saving ? AppColors.textTertiary(isDark) : color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: saving
                ? []
                : [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: saving
              ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Colors.white,
            ),
          )
              : const Text(
            'Save Transaction',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}

// ── LENT FORM ──────────────────────────────────────────────────────────────────

class _LentForm extends StatelessWidget {
  final TextEditingController amountCtrl, noteCtrl, personNameCtrl;
  final String? selectedAccount, selectedCategory;
  final DateTime date;
  final FinanceProvider finance;
  final bool isDark;
  final ValueChanged<String?> onAccountChanged, onCategoryChanged;
  final ValueChanged<DateTime> onDateChanged;

  const _LentForm({
    required this.amountCtrl,
    required this.noteCtrl,
    required this.personNameCtrl,
    required this.selectedAccount,
    required this.selectedCategory,
    required this.date,
    required this.finance,
    required this.isDark,
    required this.onAccountChanged,
    required this.onCategoryChanged,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AmountInput(
            controller: amountCtrl,
            accentColor: AppColors.lent,
            isDark: isDark,
          ),
          const SizedBox(height: 20),
          // Person name
          _FieldLabel(label: 'Lent To', isDark: isDark),
          SizedBox(height: 8),
          TextField(
            controller: personNameCtrl,
            decoration: InputDecoration(
              hintText: 'Who are you lending to?',
              prefixIcon: Icon(Icons.person_rounded, size: 18),
              filled: true,
              fillColor: AppColors.card(isDark),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 14),
          // From Account
          _DropdownField(
            label: 'From Account',
            hint: 'Money goes from...',
            value: selectedAccount,
            icon: Icons.account_balance_wallet_rounded,
            isDark: isDark,
            items: finance.accounts
                .map((a) => DropdownMenuItem(value: a.id, child: Text(a.name)))
                .toList(),
            onChanged: onAccountChanged,
          ),
          const SizedBox(height: 14),
          // Category
          _FieldLabel(label: 'Category', isDark: isDark),
          const SizedBox(height: 10),
          _CategoryGrid(
            categories: lentCategories,
            selected: selectedCategory,
            accentColor: AppColors.lent,
            isDark: isDark,
            onSelect: onCategoryChanged,
          ),
          const SizedBox(height: 14),
          _DateField(date: date, isDark: isDark, onChanged: onDateChanged),
          const SizedBox(height: 14),
          _FieldLabel(label: 'Note (optional)', isDark: isDark),
          const SizedBox(height: 8),
          TextField(
            controller: noteCtrl,
            decoration: const InputDecoration(
              hintText: 'Add a note...',
              prefixIcon: Icon(Icons.notes_rounded, size: 18),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// ── RECEIVED BACK FORM ─────────────────────────────────────────────────────────

class _ReceivedBackForm extends StatelessWidget {
  final TextEditingController amountCtrl, noteCtrl, personNameCtrl;
  final String? selectedAccount;
  final String? selectedCategory;
  final DateTime date;
  final FinanceProvider finance;
  final bool isDark;
  final ValueChanged<String?> onAccountChanged;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<DateTime> onDateChanged;

  const _ReceivedBackForm({
    required this.amountCtrl,
    required this.noteCtrl,
    required this.personNameCtrl,
    required this.selectedAccount,
    required this.selectedCategory,
    required this.date,
    required this.finance,
    required this.isDark,
    required this.onAccountChanged,
    required this.onCategoryChanged,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AmountInput(
            controller: amountCtrl,
            accentColor: AppColors.receivedBack,
            isDark: isDark,
          ),
          const SizedBox(height: 20),
          // Person name
          _FieldLabel(label: 'From Person', isDark: isDark),
          SizedBox(height: 8),
          TextField(
            controller: personNameCtrl,
            decoration: InputDecoration(
              hintText: 'Who gave you money?',
              prefixIcon: Icon(Icons.person_rounded, size: 18),
              filled: true,
              fillColor: AppColors.card(isDark),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 14),
          // To Account (where money comes in)
          _DropdownField(
            label: 'To Account',
            hint: 'Money received into...',
            value: selectedAccount,
            icon: Icons.account_balance_rounded,
            isDark: isDark,
            items: finance.accounts
                .map((a) => DropdownMenuItem(value: a.id, child: Text(a.name)))
                .toList(),
            onChanged: onAccountChanged,
          ),
          const SizedBox(height: 14),
          // Category grid
          _FieldLabel(label: 'Relation', isDark: isDark),
          const SizedBox(height: 10),
          _CategoryGrid(
            categories: receivedCategories,
            selected: selectedCategory,
            accentColor: AppColors.receivedBack,
            isDark: isDark,
            onSelect: onCategoryChanged,
          ),
          const SizedBox(height: 14),
          _DateField(date: date, isDark: isDark, onChanged: onDateChanged),
          const SizedBox(height: 14),
          _FieldLabel(label: 'Note (optional)', isDark: isDark),
          const SizedBox(height: 8),
          TextField(
            controller: noteCtrl,
            decoration: const InputDecoration(
              hintText: 'Add a note...',
              prefixIcon: Icon(Icons.notes_rounded, size: 18),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}