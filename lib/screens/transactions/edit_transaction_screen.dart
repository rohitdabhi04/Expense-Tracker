// lib/screens/transactions/edit_transaction_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/finance_provider.dart';
import '../../models/transaction.dart';
import '../../utils/theme.dart';

class EditTransactionScreen extends StatefulWidget {
  final AppTransaction transaction;

  const EditTransactionScreen({super.key, required this.transaction});

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen>
    with SingleTickerProviderStateMixin {
  late TransactionType _type;
  late final TextEditingController _amountCtrl;
  late final TextEditingController _noteCtrl;
  late final TextEditingController _personNameCtrl;
  String? _selectedAccount;
  String? _selectedToAccount;
  String? _selectedCategory;
  late DateTime _date;
  bool _saving = false;

  late AnimationController _animCtrl;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    final t = widget.transaction;
    _type = t.type;
    _amountCtrl = TextEditingController(text: t.amount.toStringAsFixed(2));
    _noteCtrl = TextEditingController(text: t.note);
    _personNameCtrl = TextEditingController(text: t.personName ?? '');
    _selectedAccount = t.accountId;
    _selectedToAccount = t.toAccountId;
    _selectedCategory = t.category;
    _date = t.date;

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
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

  List<Map<String, dynamic>> get _categories {
    switch (_type) {
      case TransactionType.income:
        return incomeCategories;
      case TransactionType.receivedBack:
        return receivedCategories;
      case TransactionType.lent:
        return lentCategories;
      default:
        return expenseCategories;
    }
  }

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.bg(isDark),
      appBar: AppBar(
        title: Text('Edit Transaction'),
        backgroundColor: AppColors.bg(isDark),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SlideTransition(
        position: _slideAnim,
        child: FadeTransition(
          opacity: _animCtrl,
          child: Column(
            children: [
              // Type selector chips
              _buildTypeSelector(isDark),

              // Scrollable form
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAmountInput(isDark),
                      const SizedBox(height: 20),
                      if (_type == TransactionType.transfer) ...[
                        _buildDropdown(
                          label: 'From Account',
                          hint: 'Select source',
                          value: _selectedAccount,
                          icon: Icons.arrow_upward_rounded,
                          isDark: isDark,
                          items: finance.accounts
                              .map((a) => DropdownMenuItem(
                                    value: a.id,
                                    child: Text(a.name),
                                  ))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedAccount = v),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color:
                                  AppColors.transfer.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.swap_vert_rounded,
                                color: AppColors.transfer),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildDropdown(
                          label: 'To Account',
                          hint: 'Select destination',
                          value: _selectedToAccount,
                          icon: Icons.arrow_downward_rounded,
                          isDark: isDark,
                          items: finance.accounts
                              .where((a) => a.id != _selectedAccount)
                              .map((a) => DropdownMenuItem(
                                    value: a.id,
                                    child: Text(a.name),
                                  ))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedToAccount = v),
                        ),
                      ] else ...[
                        if (_type == TransactionType.lent ||
                            _type == TransactionType.receivedBack) ...[
                          _buildFieldLabel(
                            _type == TransactionType.lent
                                ? 'Lent To'
                                : 'From Person',
                            isDark,
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _personNameCtrl,
                            decoration: const InputDecoration(
                              hintText: 'Person name',
                              prefixIcon:
                                  Icon(Icons.person_rounded, size: 18),
                            ),
                            textCapitalization: TextCapitalization.words,
                          ),
                          const SizedBox(height: 14),
                        ],
                        _buildDropdown(
                          label: _type == TransactionType.receivedBack
                              ? 'To Account'
                              : 'Account',
                          hint: 'Select account',
                          value: _selectedAccount,
                          icon: Icons.account_balance_wallet_rounded,
                          isDark: isDark,
                          items: finance.accounts
                              .map((a) => DropdownMenuItem(
                                    value: a.id,
                                    child: Text(a.name),
                                  ))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedAccount = v),
                        ),
                        if (_type != TransactionType.receivedBack) ...[
                          const SizedBox(height: 14),
                          _buildFieldLabel(
                            _type == TransactionType.lent
                                ? 'Category'
                                : 'Category',
                            isDark,
                          ),
                          const SizedBox(height: 10),
                          _buildCategoryGrid(isDark),
                        ] else ...[
                          const SizedBox(height: 14),
                          _buildFieldLabel('Relation', isDark),
                          const SizedBox(height: 10),
                          _buildCategoryGrid(isDark),
                        ],
                      ],
                      const SizedBox(height: 14),
                      _buildDateField(isDark),
                      const SizedBox(height: 14),
                      _buildFieldLabel('Note (optional)', isDark),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _noteCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Add a note...',
                          prefixIcon: Icon(Icons.notes_rounded, size: 18),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),

              // Save button
              _buildSaveButton(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector(bool isDark) {
    final types = [
      (TransactionType.expense, 'Expense', AppColors.expense),
      (TransactionType.income, 'Income', AppColors.income),
      (TransactionType.transfer, 'Transfer', AppColors.transfer),
      (TransactionType.lent, 'Lent', AppColors.lent),
      (TransactionType.receivedBack, 'Received', AppColors.receivedBack),
    ];

    return Container(
      color: AppColors.bg(isDark),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: types.map((entry) {
            final (type, label, color) = entry;
            final selected = _type == type;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _type = type;
                    _selectedCategory = null;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected
                        ? color
                        : color.withValues(alpha: isDark ? 0.15 : 0.08),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: color.withValues(alpha: 0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ]
                        : [],
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? Colors.white
                          : color,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAmountInput(bool isDark) {
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
            children: [
              Text(
                AppConstants.currencySymbol,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: _typeColor,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: TextField(
                  controller: _amountCtrl,
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

  Widget _buildFieldLabel(String label, bool isDark) {
    return Text(
      label,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 13,
        color: AppColors.textPrimary(isDark),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String hint,
    required String? value,
    required IconData icon,
    required bool isDark,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label, isDark),
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

  Widget _buildCategoryGrid(bool isDark) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _categories.map((c) {
        final isSelected = _selectedCategory == c['name'];
        return GestureDetector(
          onTap: () => setState(() => _selectedCategory = c['name']),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? _typeColor
                  : isDark
                      ? AppColors.darkCard
                      : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? _typeColor
                    : isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: _typeColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
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

  Widget _buildDateField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Date', isDark),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final d = await showDatePicker(
              context: context,
              initialDate: _date,
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
            if (d != null) setState(() => _date = d);
          },
          child: Container(
            padding:
                EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.card(isDark),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color:
                    isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 16, color: AppColors.textTertiary(isDark)),
                SizedBox(width: 10),
                Text(
                  DateFormat('dd MMMM, yyyy').format(_date),
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

  Widget _buildSaveButton(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: GestureDetector(
        onTap: _saving ? null : _save,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 54,
          decoration: BoxDecoration(
            color: _saving ? AppColors.textTertiary(isDark) : _typeColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: _saving
                ? []
                : [
                    BoxShadow(
                      color: _typeColor.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          alignment: Alignment.center,
          child: _saving
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Update Transaction',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final finance = context.read<FinanceProvider>();
    final amount = double.tryParse(_amountCtrl.text.trim());

    if (amount == null || amount <= 0) {
      _showError('Enter a valid amount');
      return;
    }
    if (_selectedAccount == null) {
      _showError('Select an account');
      return;
    }
    if (_type != TransactionType.transfer &&
        _selectedCategory == null) {
      _showError('Select a category');
      return;
    }
    if (_type == TransactionType.transfer && _selectedToAccount == null) {
      _showError('Select destination account');
      return;
    }
    if ((_type == TransactionType.lent ||
            _type == TransactionType.receivedBack) &&
        _personNameCtrl.text.trim().isEmpty) {
      _showError('Enter person name');
      return;
    }

    setState(() => _saving = true);
    HapticFeedback.lightImpact();

    try {
      await finance.updateTransaction(
        oldTxn: widget.transaction,
        newType: _type,
        newAmount: amount,
        newCategory: _selectedCategory ?? 'Transfer',
        newAccountId: _selectedAccount!,
        newToAccountId: _selectedToAccount,
        newPersonName:
            (_type == TransactionType.lent ||
                    _type == TransactionType.receivedBack)
                ? _personNameCtrl.text.trim()
                : null,
        newNote: _noteCtrl.text.trim(),
        newDate: _date,
      );
      if (mounted) {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Transaction updated'),
            backgroundColor: AppColors.income,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      _showError('Failed to update. Try again.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.expense,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
