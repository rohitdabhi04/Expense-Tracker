import 'package:flutter/material.dart';
import '../../utils/theme.dart';

import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = context.watch<SettingsProvider>();
    final auth = context.read<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.bg(isDark),
      appBar: AppBar(
        title: const Text('Privacy & Security'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionTitle('App Security'),
          _buildSwitchTile(
            title: 'App Lock',
            subtitle: 'Require PIN or Biometrics to open the app.',
            icon: Icons.fingerprint,
            value: settings.appLockEnabled,
            onChanged: (val) {
              settings.setAppLockEnabled(val);
            },
          ),
          const SizedBox(height: 20),
          _buildSectionTitle('Privacy'),
          _buildSwitchTile(
            title: 'Hide Balance on Home',
            subtitle: 'Blur total balance until tapped.',
            icon: Icons.visibility_off_outlined,
            value: settings.hideBalance,
            onChanged: (val) => settings.setHideBalance(val),
          ),
          const SizedBox(height: 20),
          _buildSectionTitle('Regional Settings'),
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.card(isDark),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.border(isDark),
              ),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.brand(isDark).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.currency_exchange, color: AppColors.brand(isDark), size: 20),
              ),
              title: Text('Currency Symbol', style: TextStyle(
                color: AppColors.textPrimary(isDark),
                fontWeight: FontWeight.w600,
                fontSize: 15,
              )),
              subtitle: Text('Default currency for transactions.', style: TextStyle(
                color: AppColors.textTertiary(isDark),
                fontSize: 12,
              )),
              trailing: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: settings.currency,
                  dropdownColor: AppColors.card(isDark),
                  items: ['₹', '\$', '€', '£', '¥', 'A\$', 'C\$']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c, style: TextStyle(
                            color: AppColors.textPrimary(isDark),
                            fontWeight: FontWeight.bold,
                          ))))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) settings.setCurrency(v);
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildSectionTitle('Data & Policies'),
          _buildNavTile(
            title: 'Privacy Policy',
            icon: Icons.policy_outlined,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening Privacy Policy...')),
              );
            },
          ),
          _buildNavTile(
            title: 'Terms of Service',
            icon: Icons.description_outlined,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening Terms of Service...')),
              );
            },
          ),
          const SizedBox(height: 20),
          Center(
            child: TextButton.icon(
              onPressed: () {
                // Mock delete account
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete Account'),
                    content: const Text(
                      'Are you sure you want to permanently delete your account and all associated data? This action cannot be undone.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          final success = await auth.deleteAccount();
                          if (success) {
                            if (!context.mounted) return;
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          } else {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(auth.error ?? 'Failed to delete account')),
                            );
                          }
                        },
                        style: TextButton.styleFrom(
                            foregroundColor: AppColors.error),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.delete_forever, color: AppColors.error),
              label: const Text(
                'Delete Account',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          )
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
    required IconData icon,
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
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.brand(isDark).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.brand(isDark), size: 20),
        ),
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

  Widget _buildNavTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
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
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.brand(isDark).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.brand(isDark), size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: AppColors.textPrimary(isDark),
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: AppColors.textTertiary(isDark)),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
