// lib/screens/home/home_screen.dart — Premium with dark mode + staggered animations
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/finance_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/settings_provider.dart';
import '../../utils/theme.dart';
import '../../models/transaction.dart';
import '../../models/account.dart';
import '../transactions/add_transaction_screen.dart';
import '../accounts/accounts_screen.dart';
import '../transactions/transactions_screen.dart';
import '../stats/stats_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _fabCtrl;
  late Animation<double> _fabAnim;

  // ── PageController for swipe navigation ──────────────────────────────────
  late final PageController _pageController;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    _screens = const [
      _DashboardTab(),
      AccountsScreen(),
      TransactionsScreen(),
      StatsScreen(),
      ProfileScreen(),
    ];

    _fabCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fabAnim = CurvedAnimation(parent: _fabCtrl, curve: Curves.easeOutBack);
    _fabCtrl.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fabCtrl.dispose();
    super.dispose();
  }

  // Called by both bottom nav tap AND PageView swipe
  void _onTabChange(int i) {
    if (_currentIndex == i) return;
    setState(() => _currentIndex = i);
    // Animate PageView to match tab tap
    _pageController.animateToPage(
      i,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    if (i != 4) {
      _fabCtrl.forward(from: 0);
    }
  }

  // Called only by PageView onPageChanged (swipe)
  void _onPageChanged(int i) {
    setState(() => _currentIndex = i);
    if (i != 4) {
      _fabCtrl.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: isWide
          ? Row(children: [
        _buildSideNav(isDark),
        Expanded(child: _screens[_currentIndex]),
      ])
      // ── PageView enables swipe between tabs ───────────────────────────
          : PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        // PageScrollPhysics gives snappy tab feel with smooth deceleration
        physics: const PageScrollPhysics(parent: BouncingScrollPhysics()),
        children: _screens,
      ),
      bottomNavigationBar: isWide ? null : _buildBottomNav(isDark),
      floatingActionButton: isWide || _currentIndex == 4
          ? null
          : ScaleTransition(
        scale: _fabAnim,
        child: _PremiumFAB(
          onTap: () => _openAddTransaction(context),
        ),
      ),
    );
  }

  Widget _buildBottomNav(bool isDark) {
    final bg = isDark ? AppColors.darkSurface : Colors.white;
    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: Border(
          top: BorderSide(
            color: AppColors.border(isDark),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabChange,
        backgroundColor: Colors.transparent,
        indicatorColor: AppColors.primaryDark.withValues(alpha: 0.12),
        elevation: 0,
        animationDuration: const Duration(milliseconds: 300),
        destinations: [
          _navDest(Icons.home_outlined, Icons.home_rounded, 'Home'),
          _navDest(Icons.account_balance_wallet_outlined,
              Icons.account_balance_wallet_rounded, 'Accounts'),
          _navDest(Icons.receipt_long_outlined, Icons.receipt_long_rounded,
              'History'),
          _navDest(Icons.bar_chart_outlined, Icons.bar_chart_rounded, 'Stats'),
          _navDest(Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
        ],
      ),
    );
  }

  NavigationDestination _navDest(
      IconData icon, IconData selectedIcon, String label) {
    return NavigationDestination(
      icon: Icon(icon),
      selectedIcon: Icon(selectedIcon, color: AppColors.primaryDark),
      label: label,
    );
  }

  Widget _buildSideNav(bool isDark) {
    final navItems = [
      ['Home', Icons.home_outlined, Icons.home_rounded],
      ['Accounts', Icons.account_balance_wallet_outlined, Icons.account_balance_wallet_rounded],
      ['History', Icons.receipt_long_outlined, Icons.receipt_long_rounded],
      ['Statistics', Icons.bar_chart_outlined, Icons.bar_chart_rounded],
      ['Profile', Icons.person_outline_rounded, Icons.person_rounded],
    ];

    return Container(
      width: 220,
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        boxShadow: [
          BoxShadow(color: Color(0x33000000), blurRadius: 20, offset: Offset(4, 0)),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 52),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_balance_wallet_rounded,
                  color: Colors.white, size: 22),
              const SizedBox(width: 8),
              Text(
                AppConstants.appName,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          ...navItems.asMap().entries.map((e) {
            final i      = e.key;
            final item   = e.value;
            final sel    = _currentIndex == i;
            return GestureDetector(
              onTap: () => _onTabChange(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutQuart,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: sel ? Colors.white.withValues(alpha: 0.18) : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  border: sel
                      ? Border.all(color: Colors.white.withValues(alpha: 0.2))
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      sel ? item[2] as IconData : item[1] as IconData,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      item[0] as String,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight:
                        sel ? FontWeight.w700 : FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: GestureDetector(
              onTap: () => _openAddTransaction(context),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, color: Colors.white, size: 18),
                    SizedBox(width: 6),
                    Text('Add Transaction',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _openAddTransaction(BuildContext context) {
    Navigator.push(context, AppSlideUpRoute(page: const AddTransactionScreen()));
  }
}

// ── PREMIUM FAB ────────────────────────────────────────────────────────────────

class _PremiumFAB extends StatefulWidget {
  final VoidCallback onTap;
  const _PremiumFAB({required this.onTap});

  @override
  State<_PremiumFAB> createState() => _PremiumFABState();
}

class _PremiumFABState extends State<_PremiumFAB>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.45),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 26),
        ),
      ),
    );
  }
}

// ─── DASHBOARD TAB ─────────────────────────────────────────────────────────────

class _DashboardTab extends StatefulWidget {
  const _DashboardTab();

  @override
  State<_DashboardTab> createState() => _DashboardTabState();
}

enum _SortOption { dateDesc, dateAsc, amountDesc, amountAsc }

class _DashboardTabState extends State<_DashboardTab> {
  // null = "All"
  TransactionType? _selectedFilter;
  _SortOption _sortOption = _SortOption.dateDesc;

  // Filter label → TransactionType mapping
  static const Map<String, TransactionType?> _filters = {
    'All': null,
    'Income': TransactionType.income,
    'Expense': TransactionType.expense,
    'Transfer': TransactionType.transfer,
    'Lent': TransactionType.lent,
  };

  static const Map<_SortOption, String> _sortLabels = {
    _SortOption.dateDesc: 'Newest First',
    _SortOption.dateAsc: 'Oldest First',
    _SortOption.amountDesc: 'Amount: High → Low',
    _SortOption.amountAsc: 'Amount: Low → High',
  };

  static const Map<_SortOption, IconData> _sortIcons = {
    _SortOption.dateDesc: Icons.arrow_downward_rounded,
    _SortOption.dateAsc: Icons.arrow_upward_rounded,
    _SortOption.amountDesc: Icons.arrow_downward_rounded,
    _SortOption.amountAsc: Icons.arrow_upward_rounded,
  };

  List<AppTransaction> _applyFilterAndSort(List<AppTransaction> txns) {
    // 1. filter by type
    List<AppTransaction> result = _selectedFilter == null
        ? List.of(txns)
        : txns.where((t) => t.type == _selectedFilter).toList();

    // 2. sort
    switch (_sortOption) {
      case _SortOption.dateDesc:
        result.sort((a, b) => b.date.compareTo(a.date));
        break;
      case _SortOption.dateAsc:
        result.sort((a, b) => a.date.compareTo(b.date));
        break;
      case _SortOption.amountDesc:
        result.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case _SortOption.amountAsc:
        result.sort((a, b) => a.amount.compareTo(b.amount));
        break;
    }
    return result;
  }

  void _showSortSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final bottomPad = MediaQuery.of(ctx).viewInsets.bottom +
                MediaQuery.of(ctx).padding.bottom;
            return Container(
              decoration: BoxDecoration(
                color: AppColors.card(isDark),
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomPad),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // drag handle
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
                    SizedBox(height: 16),
                    Text(
                      'Sort By',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(isDark),
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Choose how to order your transactions',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary(isDark),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Date group
                    _SheetGroupLabel(label: '📅  Date', isDark: isDark),
                    const SizedBox(height: 6),
                    _SortTile(
                      label: 'Newest First',
                      icon: Icons.arrow_downward_rounded,
                      selected: _sortOption == _SortOption.dateDesc,
                      isDark: isDark,
                      onTap: () {
                        setState(() => _sortOption = _SortOption.dateDesc);
                        Navigator.pop(context);
                      },
                    ),
                    _SortTile(
                      label: 'Oldest First',
                      icon: Icons.arrow_upward_rounded,
                      selected: _sortOption == _SortOption.dateAsc,
                      isDark: isDark,
                      onTap: () {
                        setState(() => _sortOption = _SortOption.dateAsc);
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(height: 12),
                    // Amount group
                    _SheetGroupLabel(label: '💰  Amount', isDark: isDark),
                    const SizedBox(height: 6),
                    _SortTile(
                      label: 'High → Low',
                      icon: Icons.arrow_downward_rounded,
                      selected: _sortOption == _SortOption.amountDesc,
                      isDark: isDark,
                      onTap: () {
                        setState(() => _sortOption = _SortOption.amountDesc);
                        Navigator.pop(context);
                      },
                    ),
                    _SortTile(
                      label: 'Low → High',
                      icon: Icons.arrow_upward_rounded,
                      selected: _sortOption == _SortOption.amountAsc,
                      isDark: isDark,
                      onTap: () {
                        setState(() => _sortOption = _SortOption.amountAsc);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ), // SingleChildScrollView
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();
    final auth    = context.read<AuthProvider>();
    final isDark  = Theme.of(context).brightness == Brightness.dark;

    final filteredTxns = _applyFilterAndSort(finance.recentTransactions);

    return Scaffold(
      backgroundColor:
      isDark ? AppColors.darkBg : AppColors.lightBg,
      body: RefreshIndicator(
        onRefresh: () async {},
        color: AppColors.primaryDark,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // AppBar
            SliverAppBar(
              expandedHeight: 0,
              floating: true,
              snap: true,
              backgroundColor:
              isDark ? AppColors.darkBg : AppColors.lightBg,
              elevation: 0,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, ${auth.user?.displayName?.split(' ').first ?? 'there'} 👋',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary(isDark),
                    ),
                  ),
                  Text(
                    'Your finances',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary(isDark),
                    ),
                  ),
                ],
              ),
              actions: [
                // Dark mode toggle
                Consumer<ThemeProvider>(
                  builder: (_, tp, __) => GestureDetector(
                    onTap: tp.toggleTheme,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.only(right: 16),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkCard
                            : AppColors.lightCard,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            tp.isDark
                                ? Icons.light_mode_outlined
                                : Icons.dark_mode_outlined,
                            size: 16,
                            color: AppColors.textSecondary(isDark),
                          ),
                          SizedBox(width: 4),
                          Text(
                            tp.isDark ? 'Light' : 'Dark',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary(isDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Balance card
                  StaggeredAnimation(
                    index: 0,
                    child: _BalanceCard(finance: finance),
                  ),
                  const SizedBox(height: 16),

                  // Income / Expense summary
                  StaggeredAnimation(
                    index: 1,
                    child: Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            label: 'Income',
                            amount: finance.monthlyIncome,
                            color: AppColors.income,
                            gradient: AppColors.incomeGradient,
                            icon: Icons.arrow_downward_rounded,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SummaryCard(
                            label: 'Expenses',
                            amount: finance.monthlyExpense,
                            color: AppColors.expense,
                            gradient: AppColors.expenseGradient,
                            icon: Icons.arrow_upward_rounded,
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Accounts row
                  if (finance.accounts.isNotEmpty) ...[
                    StaggeredAnimation(
                      index: 2,
                      child: _SectionHeader(
                          title: 'My Accounts', isDark: isDark),
                    ),
                    const SizedBox(height: 12),
                    StaggeredAnimation(
                      index: 3,
                      child: SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: finance.accounts.length,
                          itemBuilder: (_, i) => _AccountChip(
                            account: finance.accounts[i],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Lending summary
                  if (finance.lentByPerson.isNotEmpty) ...[
                    StaggeredAnimation(
                      index: 4,
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          AppPageRoute(page: const _PeopleLedgerScreen()),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: AppColors.lentGradient,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.lent.withValues(alpha: 0.35),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(13),
                                ),
                                child: const Icon(Icons.people_rounded,
                                    color: Colors.white, size: 22),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Outstanding Lending',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      AppConstants.formatFull(finance.outstandingLent),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${finance.lentByPerson.length} ${finance.lentByPerson.length == 1 ? 'person' : 'people'}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Icon(Icons.chevron_right_rounded,
                                      color: Colors.white,
                                      size: 20),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ── Recent Transactions header ──────────────────────────
                  StaggeredAnimation(
                    index: 4,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _SectionHeader(
                            title: 'Recent Transactions', isDark: isDark),
                        GestureDetector(
                          onTap: () => _showSortSheet(context, isDark),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: _sortOption != _SortOption.dateDesc
                                  ? AppColors.primary
                                  : (isDark
                                  ? AppColors.darkCard
                                  : Colors.white),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _sortOption != _SortOption.dateDesc
                                    ? AppColors.primary
                                    : (isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder),
                              ),
                              boxShadow: _sortOption != _SortOption.dateDesc
                                  ? [
                                BoxShadow(
                                  color: AppColors.primary
                                      .withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                )
                              ]
                                  : [],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.sort_rounded,
                                  size: 14,
                                  color: _sortOption != _SortOption.dateDesc
                                      ? Colors.white
                                      : (AppColors.textSecondary(isDark)),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _sortOption == _SortOption.dateDesc
                                      ? 'Sort'
                                      : _sortOption == _SortOption.dateAsc
                                      ? 'Oldest'
                                      : _sortOption ==
                                      _SortOption.amountDesc
                                      ? 'High→Low'
                                      : 'Low→High',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: _sortOption != _SortOption.dateDesc
                                        ? Colors.white
                                        : (isDark
                                        ? Colors.white70
                                        : AppColors.textSecondary(isDark)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ── Filter Chips ────────────────────────────────────────
                  StaggeredAnimation(
                    index: 5,
                    child: SizedBox(
                      height: 36,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: _filters.entries.map((entry) {
                          final isSelected = _selectedFilter == entry.value;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedFilter = entry.value),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : (isDark
                                    ? AppColors.darkCard
                                    : Colors.white),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : (isDark
                                      ? AppColors.darkBorder
                                      : AppColors.lightBorder),
                                ),
                                boxShadow: isSelected
                                    ? [
                                  BoxShadow(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  )
                                ]
                                    : [],
                              ),
                              child: Text(
                                entry.key,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : (AppColors.textSecondary(isDark)),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Filtered transaction list ───────────────────────────
                  if (filteredTxns.isEmpty)
                    StaggeredAnimation(
                      index: 6,
                      child: _EmptyTransactions(isDark: isDark),
                    )
                  else
                    ...filteredTxns.asMap().entries.map((e) =>
                        StaggeredAnimation(
                          index: 6 + e.key,
                          child: _TransactionTile(
                            txn: e.value,
                            finance: finance,
                            isDark: isDark,
                          ),
                        )),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── SUB-WIDGETS ────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;
  const _SectionHeader({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 16,
        color: AppColors.textPrimary(isDark),
        letterSpacing: 0.2,
      ),
    );
  }
}

class _BalanceCard extends StatefulWidget {
  final FinanceProvider finance;
  const _BalanceCard({required this.finance});

  @override
  State<_BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<_BalanceCard>
    with SingleTickerProviderStateMixin {
  bool _showBalance = true;
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    _ctrl.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final settings = context.read<SettingsProvider>();
        if (settings.hideBalance) {
          setState(() => _showBalance = false);
        }
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _showBalance = !_showBalance),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background decoration circles
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Positioned(
              right: 30,
              bottom: -30,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.04),
                ),
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Colors.white54,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Total Balance',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      _showBalance
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.white54,
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    key: ValueKey(_showBalance),
                    _showBalance
                        ? AppConstants.formatFull(widget.finance.totalBalance)
                        : '₹ ••••••',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${widget.finance.accounts.length} account${widget.finance.accounts.length != 1 ? 's' : ''} • Tap to ${_showBalance ? 'hide' : 'show'}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final LinearGradient gradient;
  final IconData icon;
  final bool isDark;

  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.color,
    required this.gradient,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border(isDark),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.transparent
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textTertiary(isDark),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppConstants.formatFull(amount),
                  maxLines: 1,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountChip extends StatelessWidget {
  final Account account;
  const _AccountChip({required this.account});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 155,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.hexToColor(account.color),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.hexToColor(account.color).withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.account_balance_wallet_rounded,
                color: Colors.white, size: 14),
          ),
          const Spacer(),
          Text(
            account.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            AppConstants.formatFull(account.balance),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final AppTransaction txn;
  final FinanceProvider finance;
  final bool isDark;

  const _TransactionTile(
      {required this.txn, required this.finance, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isIncome   = txn.type == TransactionType.income;
    final isTransfer = txn.type == TransactionType.transfer;
    final isLent     = txn.type == TransactionType.lent;
    final isReceivedBack = txn.type == TransactionType.receivedBack;
    final color = isTransfer
        ? AppColors.transfer
        : isIncome
        ? AppColors.income
        : isLent
        ? AppColors.lent
        : isReceivedBack
        ? AppColors.receivedBack
        : AppColors.expense;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.card(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border(isDark),
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
            ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(13),
            ),
            alignment: Alignment.center,
            child: Text(
              _categoryEmoji(txn.category),
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  txn.category,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textPrimary(isDark),
                  ),
                ),
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
                  txn.note.isNotEmpty
                      ? txn.note
                      : finance.getAccountName(txn.accountId),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiary(isDark),
                  ),
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
                DateFormat('dd MMM').format(txn.date),
                style: TextStyle(fontSize: 11, color: AppColors.textTertiary(isDark)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _categoryEmoji(String category) {
    final all = [...incomeCategories, ...expenseCategories, ...lentCategories];
    try {
      return all.firstWhere((c) => c['name'] == category)['icon'] as String;
    } catch (_) {
      if (category == 'Received Back') return '💸';
      return '💳';
    }
  }
}

class _EmptyTransactions extends StatelessWidget {
  final bool isDark;
  const _EmptyTransactions({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.card(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border(isDark),
        ),
      ),
      child: Column(
        children: [
          Text('💸', style: TextStyle(fontSize: 48)),
          SizedBox(height: 14),
          Text(
            'No transactions yet',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: AppColors.textPrimary(isDark),
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Tap + to add your first transaction',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textTertiary(isDark),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── SORT SHEET HELPERS ─────────────────────────────────────────────────────────

class _SheetGroupLabel extends StatelessWidget {
  final String label;
  final bool isDark;
  const _SheetGroupLabel({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textTertiary(isDark),
        letterSpacing: 0.4,
      ),
    );
  }
}

class _SortTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _SortTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.4)
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : (isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.04)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 16,
                color: selected
                    ? AppColors.primary
                    : AppColors.textTertiary(isDark),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight:
                  selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected
                      ? AppColors.primary
                      : (AppColors.textPrimary(isDark)),
                ),
              ),
            ),
            if (selected)
              Icon(Icons.check_circle_rounded,
                  color: AppColors.primaryDark, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── PEOPLE LEDGER SCREEN ───────────────────────────────────────────────────────

class _PeopleLedgerScreen extends StatelessWidget {
  const _PeopleLedgerScreen();

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final people = finance.lentByPerson;
    final sortedNames = people.keys.toList()
      ..sort((a, b) => people[b]!.abs().compareTo(people[a]!.abs()));

    return Scaffold(
      backgroundColor: AppColors.bg(isDark),
      appBar: AppBar(
        title: const Text('People Ledger'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Summary header
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.lentGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.lent.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Lent',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                      Text(AppConstants.formatFull(finance.totalLent),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
                Container(width: 1, height: 40, color: Colors.white24),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Received Back',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                        Text(AppConstants.formatFull(finance.totalReceivedBack),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // People list
          Expanded(
            child: sortedNames.isEmpty
                ? Center(
                child: Text('No outstanding lending',
                    style: TextStyle(color: AppColors.textTertiary(isDark))))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: sortedNames.length,
              itemBuilder: (_, i) {
                final name = sortedNames[i];
                final amount = people[name]!;
                final txns = finance.getTransactionsForPerson(name);
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    AppPageRoute(
                        page: _PersonDetailScreen(
                            personName: name, transactions: txns)),
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.card(isDark),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: (amount > 0 ? AppColors.lent : AppColors.receivedBack)
                                .withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            name[0].toUpperCase(),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: amount > 0
                                  ? AppColors.lent
                                  : AppColors.receivedBack,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: AppColors.textPrimary(isDark),
                                  )),
                              Text(
                                '${txns.length} transaction${txns.length != 1 ? 's' : ''}',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary(isDark)),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${amount > 0 ? '' : '+'}${AppConstants.formatFull(amount.abs())}',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: amount > 0
                                ? AppColors.lent
                                : AppColors.receivedBack,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── PERSON DETAIL SCREEN ───────────────────────────────────────────────────────

class _PersonDetailScreen extends StatelessWidget {
  final String personName;
  final List<AppTransaction> transactions;

  const _PersonDetailScreen({
    required this.personName,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sorted = [...transactions]..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      backgroundColor: AppColors.bg(isDark),
      appBar: AppBar(
        title: Text(personName),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sorted.length,
        itemBuilder: (_, i) {
          final txn = sorted[i];
          final isLent = txn.type == TransactionType.lent;
          final color = isLent ? AppColors.lent : AppColors.receivedBack;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.card(isDark),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AppColors.border(isDark)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isLent
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                    color: color,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isLent ? 'Lent' : 'Received Back',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary(isDark),
                          )),
                      if (txn.note.isNotEmpty)
                        Text(txn.note,
                            style: TextStyle(
                                fontSize: 12, color: AppColors.textTertiary(isDark))),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isLent ? '→' : '←'} ${AppConstants.formatFull(txn.amount)}',
                      style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w700,
                          fontSize: 14),
                    ),
                    Text(
                      DateFormat('dd MMM, yy').format(txn.date),
                      style: TextStyle(
                          fontSize: 11, color: AppColors.textTertiary(isDark)),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}