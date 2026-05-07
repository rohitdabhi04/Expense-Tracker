// lib/screens/profile/profile_screen.dart — Premium with dark mode toggle
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/finance_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/theme.dart';
import 'edit_profile_screen.dart';
import 'notifications_screen.dart';
import 'privacy_security_screen.dart';
import 'help_support_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth    = context.watch<AuthProvider>();
    final finance = context.watch<FinanceProvider>();
    final tp      = context.watch<ThemeProvider>();
    final isDark  = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.bg(isDark),
      body: CustomScrollView(
        slivers: [
          // Hero header
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20,
                left: 24,
                right: 24,
                bottom: 36,
              ),
              child: Column(
                children: [
                  // Avatar
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.accentGradient,
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3), width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            (auth.user?.displayName?.isNotEmpty == true)
                                ? auth.user!.displayName![0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    auth.user?.displayName ?? 'User',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    auth.user?.email ?? '',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatPill(
                        value: '${finance.accounts.length}',
                        label: 'Accounts',
                      ),
                      Container(
                          width: 1,
                          height: 32,
                          color: Colors.white.withValues(alpha: 0.2)),
                      _StatPill(
                        value: '${finance.recentTransactions.length}+',
                        label: 'Transactions',
                      ),
                      Container(
                          width: 1,
                          height: 32,
                          color: Colors.white.withValues(alpha: 0.2)),
                      _StatPill(
                        value: AppConstants.formatAmount(
                            finance.totalBalance),
                        label: 'Balance',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Preferences section
                _SectionTitle(title: 'Preferences', isDark: isDark),
                const SizedBox(height: 12),
                _SettingsCard(isDark: isDark, children: [
                  _ToggleTile(
                    icon: Icons.dark_mode_outlined,
                    iconColor: AppColors.accent,
                    title: 'Dark Mode',
                    subtitle: 'Switch app appearance',
                    value: tp.isDark,
                    onChanged: (_) => tp.toggleTheme(),
                    isDark: isDark,
                  ),
                  _Divider(isDark: isDark),
                  _NavTile(
                    icon: Icons.notifications_outlined,
                    iconColor: AppColors.warning,
                    title: 'Notifications',
                    subtitle: 'Manage alerts',
                    isDark: isDark,
                    onTap: () {
                      Navigator.push(
                        context,
                        AppPageRoute(page: const NotificationsScreen()),
                      );
                    },
                  ),
                  _Divider(isDark: isDark),
                  _NavTile(
                    icon: Icons.lock_outline_rounded,
                    iconColor: AppColors.primaryDark,
                    title: 'Privacy & Security',
                    subtitle: 'Password, biometrics',
                    isDark: isDark,
                    onTap: () {
                      Navigator.push(
                        context,
                        AppPageRoute(page: const PrivacySecurityScreen()),
                      );
                    },
                  ),
                ]),
                const SizedBox(height: 20),

                // Account section
                _SectionTitle(title: 'Account', isDark: isDark),
                const SizedBox(height: 12),
                _SettingsCard(isDark: isDark, children: [
                  _NavTile(
                    icon: Icons.person_outline_rounded,
                    iconColor: AppColors.accent,
                    title: 'Edit Profile',
                    subtitle: 'Name, photo',
                    isDark: isDark,
                    onTap: () {
                      Navigator.push(
                        context,
                        AppPageRoute(page: const EditProfileScreen()),
                      );
                    },
                  ),
                  _Divider(isDark: isDark),
                  _NavTile(
                    icon: Icons.help_outline_rounded,
                    iconColor: AppColors.accent,
                    title: 'Help & Support',
                    subtitle: 'FAQ, contact us',
                    isDark: isDark,
                    onTap: () {
                      Navigator.push(
                        context,
                        AppPageRoute(page: HelpSupportScreen()),
                      );
                    },
                  ),
                  _Divider(isDark: isDark),
                  _NavTile(
                    icon: Icons.logout_rounded,
                    iconColor: AppColors.error,
                    title: 'Sign Out',
                    subtitle: 'Log out of your account',
                    isDark: isDark,
                    isDestructive: true,
                    onTap: () => _confirmSignOut(context, auth),
                  ),
                ]),
                SizedBox(height: 40),

                Center(
                  child: Text(
                    '${AppConstants.appName} v1.0.0',
                    style: TextStyle(
                      color: AppColors.textTertiary(isDark),
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out?'),
        content:
            const Text('You will be logged out of your account.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              auth.signOut();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

// ── HELPERS ────────────────────────────────────────────────────────────────────

class _StatPill extends StatelessWidget {
  final String value, label;
  const _StatPill({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.65),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final bool isDark;
  _SectionTitle({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 13,
        color: AppColors.textTertiary(isDark),
        letterSpacing: 0.8,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  final bool isDark;
  const _SettingsCard({required this.children, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border(isDark),
        ),
      ),
      child: Column(children: children),
    );
  }
}

class _Divider extends StatelessWidget {
  final bool isDark;
  const _Divider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 60,
      color: AppColors.border(isDark),
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title, subtitle;
  final bool isDark;
  final bool isDestructive;
  final VoidCallback onTap;

  const _NavTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.isDark,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isDestructive
                          ? AppColors.error
                          : AppColors.textPrimary(isDark),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textTertiary(isDark)),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: AppColors.textTertiary(isDark),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title, subtitle;
  final bool value, isDark;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textPrimary(isDark),
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                      fontSize: 12, color: AppColors.textTertiary(isDark)),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.accent,
          ),
        ],
      ),
    );
  }
}

// Add this missing constant
const Color info = Color(0xFF3B82F6);

extension on AppColors {
  static const Color info = Color(0xFF3B82F6);
}
