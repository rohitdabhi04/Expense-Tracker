import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _expenseAlerts = true;
  bool _weeklyReports = true;
  bool _monthlySummary = true;
  bool _promotional = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.bg(isDark),
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionTitle('Transaction Alerts'),
          _buildSwitchTile(
            title: 'Expense Alerts',
            subtitle: 'Get notified for every new expense added.',
            value: _expenseAlerts,
            onChanged: (val) => setState(() => _expenseAlerts = val),
          ),
          const SizedBox(height: 20),
          _buildSectionTitle('Reports & Summaries'),
          _buildSwitchTile(
            title: 'Weekly Reports',
            subtitle: 'Receive a summary of your weekly spending.',
            value: _weeklyReports,
            onChanged: (val) => setState(() => _weeklyReports = val),
          ),
          _buildSwitchTile(
            title: 'Monthly Summary',
            subtitle: 'Get a detailed breakdown at the end of each month.',
            value: _monthlySummary,
            onChanged: (val) => setState(() => _monthlySummary = val),
          ),
          const SizedBox(height: 20),
          _buildSectionTitle('Other'),
          _buildSwitchTile(
            title: 'Tips & Promotions',
            subtitle: 'News, financial tips, and special offers.',
            value: _promotional,
            onChanged: (val) => setState(() => _promotional = val),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: AppColors.primaryDark,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border(isDark),
        ),
      ),
      child: SwitchListTile.adaptive(
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: AppColors.textPrimary(isDark),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 13, color: AppColors.textTertiary(isDark)),
        ),
        value: value,
        onChanged: onChanged,
        activeTrackColor: AppColors.accent,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
