import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.bg(isDark),
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Icon(Icons.support_agent, size: 48, color: Colors.white),
                const SizedBox(height: 16),
                const Text(
                  'How can we help you?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Find answers to common questions or reach out to us directly.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          const Text(
            'Frequently Asked Questions',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildFaqItem(
            context,
            question: 'How do I add a new transaction?',
            answer: 'On the Home or Transactions tab, tap the "+" button in the bottom right corner. Select the type (Income, Expense, Transfer), enter the amount, and save.',
          ),
          _buildFaqItem(
            context,
            question: 'Can I sync my data across devices?',
            answer: 'Yes! Your data is securely synced to your cloud account. Simply log in with the same email and password on any device.',
          ),
          _buildFaqItem(
            context,
            question: 'How do I delete an account or transaction?',
            answer: 'Navigate to the Accounts or Transactions list and swipe left on the item you want to delete. A delete button will appear.',
          ),
          _buildFaqItem(
            context,
            question: 'Is my financial data secure?',
            answer: 'Absolutely. We use industry-standard encryption and Firebase security rules to ensure only you can access your data.',
          ),
          
          const SizedBox(height: 32),
          const Text(
            'Contact Us',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: AppColors.primaryDark,
            ),
          ),
          SizedBox(height: 16),
          
          Container(
            decoration: BoxDecoration(
              color: AppColors.card(isDark),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.border(isDark),
              ),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.email_outlined, color: AppColors.accent),
                  ),
                  title: const Text('Email Support'),
                  subtitle: const Text('supportexpensetrackerapp@gmail.com'),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Opening email client...')),
                    );
                  },
                ),
                Divider(
                  height: 1, 
                  indent: 64, 
                  color: AppColors.border(isDark)
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.language, color: AppColors.warning),
                  ),
                  title: const Text('Website'),
                  subtitle: const Text('www.expensetracker.com'),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Opening website...')),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildFaqItem(BuildContext context, {required String question, required String answer}) {
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
      child: ExpansionTile(
        title: Text(
          question,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.textPrimary(isDark),
          ),
        ),
        iconColor: AppColors.brand(isDark),
        collapsedIconColor: AppColors.textTertiary(isDark),
        childrenPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedAlignment: Alignment.centerLeft,
        children: [
          Text(
            answer,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textTertiary(isDark),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
