// lib/screens/stats/stats_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/finance_provider.dart';
import '../../utils/theme.dart';
import '../../models/transaction.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedMonthOffset = 0; // 0 = this month, -1 = last month, etc.

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final bg      = isDark ? AppColors.darkBg : AppColors.lightBg;
    final cardBg  = isDark ? AppColors.darkCard : Colors.white;
    final border  = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    // Filter transactions by selected month
    final now = DateTime.now();
    final targetMonth = DateTime(now.year, now.month + _selectedMonthOffset);
    final monthTxns = finance.transactions.where((t) =>
    t.date.year == targetMonth.year && t.date.month == targetMonth.month
    ).toList();

    final monthIncome  = monthTxns.where((t) => t.type == TransactionType.income)
        .fold(0.0, (s, t) => s + t.amount);
    final monthExpense = monthTxns.where((t) => t.type == TransactionType.expense)
        .fold(0.0, (s, t) => s + t.amount);

    // Category breakdown for expense
    final expenseCatMap = <String, double>{};
    for (final t in monthTxns.where((t) => t.type == TransactionType.expense)) {
      expenseCatMap[t.category] = (expenseCatMap[t.category] ?? 0) + t.amount;
    }
    final sortedExpCats = expenseCatMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Category breakdown for income
    final incomeCatMap = <String, double>{};
    for (final t in monthTxns.where((t) => t.type == TransactionType.income)) {
      incomeCatMap[t.category] = (incomeCatMap[t.category] ?? 0) + t.amount;
    }
    final sortedIncCats = incomeCatMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg(isDark),
        title: Text(
          'Statistics',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary(isDark),
          ),
        ),
        elevation: 0,
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Month selector
                _MonthSelector(
                  offset: _selectedMonthOffset,
                  isDark: isDark,
                  onChanged: (v) => setState(() => _selectedMonthOffset = v),
                ),
                // Summary row
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: _SummaryTile(
                          label: 'Income',
                          amount: monthIncome,
                          color: AppColors.income,
                          icon: Icons.arrow_downward_rounded,
                          cardBg: cardBg,
                          border: border,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _SummaryTile(
                          label: 'Expense',
                          amount: monthExpense,
                          color: AppColors.expense,
                          icon: Icons.arrow_upward_rounded,
                          cardBg: cardBg,
                          border: border,
                          isDark: isDark,
                        ),
                      ),

                    ],
                  ),
                ),
                // Budget Card
                if (_selectedMonthOffset == 0)
                  _BudgetCard(
                    finance: finance,
                    isDark: isDark,
                    cardBg: cardBg,
                    border: border,
                  ),
                SizedBox(height: 8),
                // TabBar duplicate for NestedScrollView
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  decoration: BoxDecoration(
                    color: AppColors.card(isDark),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: AppColors.primaryDark,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: AppColors.darkTextTertiary,
                    dividerColor: Colors.transparent,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    tabs: const [
                      Tab(text: 'Expenses'),
                      Tab(text: 'Income'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            // Expenses tab
            _CategoryTab(
              sortedCats: sortedExpCats,
              total: monthExpense,
              emptyLabel: 'No expenses this month',
              emptyEmoji: '🎉',
              accentColor: AppColors.expense,
              isDark: isDark,
              cardBg: cardBg,
              border: border,
              finance: finance,
              isExpense: true,
              showBalancesBar: finance.accounts.isNotEmpty
                  ? _ShowBalancesBar(
                finance: finance,
                isDark: isDark,
                cardBg: cardBg,
                border: border,
              )
                  : null,
            ),
            // Income tab
            _CategoryTab(
              sortedCats: sortedIncCats,
              total: monthIncome,
              emptyLabel: 'No income this month',
              emptyEmoji: '💼',
              accentColor: AppColors.income,
              isDark: isDark,
              cardBg: cardBg,
              border: border,
              finance: finance,
              isExpense: false,
              showBalancesBar: finance.accounts.isNotEmpty
                  ? _ShowBalancesBar(
                finance: finance,
                isDark: isDark,
                cardBg: cardBg,
                border: border,
              )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ── MONTH SELECTOR ─────────────────────────────────────────────────────────────

class _MonthSelector extends StatelessWidget {
  final int offset;
  final bool isDark;
  final ValueChanged<int> onChanged;

  const _MonthSelector({
    required this.offset,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final target = DateTime(now.year, now.month + offset);
    final label = offset == 0
        ? 'This Month'
        : offset == -1
        ? 'Last Month'
        : DateFormat('MMMM yyyy').format(target);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _NavBtn(
            icon: Icons.chevron_left,
            isDark: isDark,
            onTap: () => onChanged(offset - 1),
          ),
          SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: AppColors.textPrimary(isDark),
            ),
          ),
          const SizedBox(width: 12),
          _NavBtn(
            icon: Icons.chevron_right,
            isDark: isDark,
            onTap: offset < 0 ? () => onChanged(offset + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final VoidCallback? onTap;

  const _NavBtn({required this.icon, required this.isDark, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: AppColors.card(isDark),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.border(isDark),
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: onTap == null ? AppColors.textTertiary(isDark).withValues(alpha: 0.3) : AppColors.textTertiary(isDark),
        ),
      ),
    );
  }
}

// ── SUMMARY TILE ───────────────────────────────────────────────────────────────

class _SummaryTile extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;
  final Color cardBg;
  final Color border;
  final bool isDark;

  const _SummaryTile({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
    required this.cardBg,
    required this.border,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(icon, color: color, size: 12),
              ),
              SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textTertiary(isDark),
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              AppConstants.formatFull(amount.abs()),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── CATEGORY TAB ───────────────────────────────────────────────────────────────

class _CategoryTab extends StatelessWidget {
  final List<MapEntry<String, double>> sortedCats;
  final double total;
  final String emptyLabel, emptyEmoji;
  final Color accentColor;
  final bool isDark, isExpense;
  final Color cardBg, border;
  final FinanceProvider finance;
  final Widget? showBalancesBar;

  const _CategoryTab({
    required this.sortedCats,
    required this.total,
    required this.emptyLabel,
    required this.emptyEmoji,
    required this.accentColor,
    required this.isDark,
    required this.cardBg,
    required this.border,
    required this.finance,
    required this.isExpense,
    this.showBalancesBar,
  });

  static const List<Color> _pieColors = [
    Color(0xFF6C63FF),
    Color(0xFF00C6A7),
    Color(0xFFFF6B6B),
    Color(0xFFFF9F43),
    Color(0xFF0652DD),
    Color(0xFF833471),
    Color(0xFF1289A7),
    Color(0xFFFDA7DF),
    Color(0xFF9B59B6),
    Color(0xFF2ECC71),
  ];

  @override
  Widget build(BuildContext context) {
    if (sortedCats.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emptyEmoji, style: TextStyle(fontSize: 52)),
            SizedBox(height: 14),
            Text(
              emptyLabel,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: AppColors.textPrimary(isDark),
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Your breakdown will appear here',
              style: TextStyle(color: AppColors.textTertiary(isDark), fontSize: 13),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          if (showBalancesBar != null) ...[
            showBalancesBar!,
            const SizedBox(height: 4),
          ],
          // Pie chart card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: border),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: sortedCats.asMap().entries.map((e) {
                        final pct = total > 0 ? e.value.value / total : 0.0;
                        return PieChartSectionData(
                          value: e.value.value,
                          color: _pieColors[e.key % _pieColors.length],
                          title: '${(pct * 100).toStringAsFixed(0)}%',
                          radius: 65,
                          titleStyle: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                      centerSpaceRadius: 48,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Legend
                ...sortedCats.asMap().entries.map((e) {
                  final pct = total > 0 ? (e.value.value / total * 100) : 0.0;
                  return _LegendRow(
                    color: _pieColors[e.key % _pieColors.length],
                    label: e.value.key,
                    amount: e.value.value,
                    percent: pct.toStringAsFixed(1),
                    isDark: isDark,
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Category bars
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Category Breakdown',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.textPrimary(isDark),
                  ),
                ),
                const SizedBox(height: 14),
                ...sortedCats.map((e) {
                  final ratio = total > 0 ? e.value / total : 0.0;
                  final emoji = _getEmoji(e.key);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(emoji, style: const TextStyle(fontSize: 16)),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                e.key,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                  color: AppColors.textPrimary(isDark),
                                ),
                              ),
                            ),
                            Text(
                              AppConstants.formatFull(e.value),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: accentColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: ratio,
                            backgroundColor: isDark
                                ? AppColors.darkCardAlt
                                : AppColors.lightChip,
                            valueColor: AlwaysStoppedAnimation(accentColor),
                            minHeight: 7,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getEmoji(String category) {
    final all = [...incomeCategories, ...expenseCategories];
    try {
      return all.firstWhere((c) => c['name'] == category)['icon'] as String;
    } catch (_) {
      return '💳';
    }
  }
}

// ── LEGEND ROW ─────────────────────────────────────────────────────────────────

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label, percent;
  final double amount;
  final bool isDark;

  const _LegendRow({
    required this.color,
    required this.label,
    required this.amount,
    required this.percent,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: AppColors.textPrimary(isDark),
              ),
            ),
          ),
          Text(
            '$percent%',
            style: TextStyle(fontSize: 12, color: AppColors.textTertiary(isDark)),
          ),
          const SizedBox(width: 12),
          Text(
            AppConstants.formatFull(amount),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: AppColors.textPrimary(isDark),
            ),
          ),
        ],
      ),
    );
  }
}

// ── SHOW BALANCES BAR ─────────────────────────────────────────────────────────

class _ShowBalancesBar extends StatefulWidget {
  final FinanceProvider finance;
  final bool isDark;
  final Color cardBg, border;

  const _ShowBalancesBar({
    required this.finance,
    required this.isDark,
    required this.cardBg,
    required this.border,
  });

  @override
  State<_ShowBalancesBar> createState() => _ShowBalancesBarState();
}

class _ShowBalancesBarState extends State<_ShowBalancesBar>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final maxBal = widget.finance.accounts
        .map((a) => a.balance.abs())
        .fold(0.0, (prev, b) => b > prev ? b : prev);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: widget.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: widget.border),
      ),
      child: Column(
        children: [
          // Toggle button
          InkWell(
            onTap: _toggle,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.brand(widget.isDark).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Account Balances',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.textPrimary(widget.isDark),
                      ),
                    ),
                  ),
                  RotationTransition(
                    turns: Tween(begin: 0.0, end: 0.5).animate(_anim),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textTertiary(widget.isDark),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expandable content
          SizeTransition(
            sizeFactor: _anim,
            child: Column(
              children: [
                Divider(height: 1, color: widget.border),
                const SizedBox(height: 12),
                ...widget.finance.accounts.map((acc) {
                  final ratio = maxBal > 0 ? acc.balance.abs() / maxBal : 0.0;
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                acc.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                  color: AppColors.textPrimary(widget.isDark),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              AppConstants.formatFull(acc.balance),
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: acc.balance >= 0
                                    ? AppColors.income
                                    : AppColors.expense,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: ratio,
                            backgroundColor: widget.isDark
                                ? AppColors.darkCardAlt
                                : AppColors.lightChip,
                            valueColor: AlwaysStoppedAnimation(
                                AppTheme.hexToColor(acc.color)),
                            minHeight: 7,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


// ── BUDGET CARD ────────────────────────────────────────────────────────────────

class _BudgetCard extends StatelessWidget {
  final FinanceProvider finance;
  final bool isDark;
  final Color cardBg;
  final Color border;

  const _BudgetCard({
    required this.finance,
    required this.isDark,
    required this.cardBg,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    if (finance.monthlyBudget <= 0) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: OutlinedButton.icon(
          onPressed: () => _showBudgetDialog(context, finance),
          icon: const Icon(Icons.add_chart),
          label: const Text('Set Monthly Budget'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryDark,
            side: BorderSide(color: AppColors.primaryDark.withValues(alpha: 0.5)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );
    }

    final expense = finance.monthlyExpense;
    final ratio = (expense / finance.monthlyBudget).clamp(0.0, 1.0);
    final isWarning = ratio > 0.85;
    final isDanger = ratio >= 1.0;

    final color = isDanger ? AppColors.error : isWarning ? AppColors.warning : AppColors.primary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Monthly Budget',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.textPrimary(isDark),
                ),
              ),
              GestureDetector(
                onTap: () => _showBudgetDialog(context, finance),
                child: Icon(Icons.edit, size: 16, color: AppColors.textTertiary(isDark)),
              )
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: isDark ? AppColors.darkCardAlt : AppColors.lightCard,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  '${AppConstants.formatFull(expense)} spent',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Text(
                'of ${AppConstants.formatFull(finance.monthlyBudget)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: AppColors.textTertiary(isDark)),
              ),
            ],
          )
        ],
      ),
    );
  }

  void _showBudgetDialog(BuildContext context, FinanceProvider finance) {
    final ctrl = TextEditingController(
      text: finance.monthlyBudget > 0 ? finance.monthlyBudget.toStringAsFixed(0) : '',
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Monthly Budget'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Budget Amount',
            prefixText: AppConstants.currencySymbol,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(ctrl.text) ?? 0.0;
              finance.setMonthlyBudget(val);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}