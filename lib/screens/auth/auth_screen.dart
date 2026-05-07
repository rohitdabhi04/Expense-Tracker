// lib/screens/auth/auth_screen.dart — Premium animated auth screen
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Animation controllers (service app pattern)
  late AnimationController _fadeCtrl;
  late AnimationController _slideCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  final _loginFormKey  = GlobalKey<FormState>();
  final _signupFormKey = GlobalKey<FormState>();

  final _loginEmail     = TextEditingController();
  final _loginPassword  = TextEditingController();
  final _signupName     = TextEditingController();
  final _signupEmail    = TextEditingController();
  final _signupPassword = TextEditingController();

  bool _obscureLogin  = true;
  bool _obscureSignup = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _slideCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 550));

    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOutQuart);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutQuart));

    _fadeCtrl.forward();
    _slideCtrl.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    _loginEmail.dispose();
    _loginPassword.dispose();
    _signupName.dispose();
    _signupEmail.dispose();
    _signupPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth   = context.watch<AuthProvider>();
    final isWide = MediaQuery.of(context).size.width > 700;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.primary,
      body: isWide ? _buildWide(auth, isDark) : _buildMobile(auth, isDark),
    );
  }

  // ── WIDE LAYOUT ────────────────────────────────────────────
  Widget _buildWide(AuthProvider auth, bool isDark) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: _buildHeroPanel(),
        ),
        Expanded(
          flex: 6,
          child: _buildFormPanel(auth, isDark),
        ),
      ],
    );
  }

  Widget _buildHeroPanel() {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      padding: const EdgeInsets.all(48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            AppConstants.appName,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 38,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your complete\npersonal finance\nmanager.',
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 24,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 48),
          _featureRow('💰', 'Track cash & multiple bank accounts'),
          const SizedBox(height: 16),
          _featureRow('📊', 'Visual charts & spending insights'),
          const SizedBox(height: 16),
          _featureRow('🔄', 'Transfer between accounts'),
          const SizedBox(height: 16),
          _featureRow('☁️', 'Syncs across all your devices'),
        ],
      ),
    );
  }

  Widget _featureRow(String emoji, String text) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Text(
          text,
          style: GoogleFonts.inter(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildFormPanel(AuthProvider auth, bool isDark) {
    final bg = isDark ? AppColors.darkBg : Colors.white;
    return Container(
      color: bg,
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
      child: _buildForm(auth, isDark),
    );
  }

  // ── MOBILE LAYOUT ──────────────────────────────────────────
  Widget _buildMobile(AuthProvider auth, bool isDark) {
    return Stack(
      children: [
        // Background gradient
        Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        ),

        // Background glow
        Positioned(
          top: -80,
          right: -60,
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accent.withValues(alpha: 0.2),
            ),
          ),
        ),

        // Form sheet
        FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: DraggableScrollableSheet(
              initialChildSize: 0.75,
              minChildSize: 0.70,
              maxChildSize: 0.95,
              builder: (_, controller) {
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface(isDark),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(32)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 30,
                        offset: const Offset(0, -8),
                      ),
                    ],
                  ),
                  child: ListView(
                    controller: controller,
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                    children: [
                      // Drag handle
                      Center(
                        child: Container(
                          width: 44,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      _buildForm(auth, isDark),
                    ],
                  ),
                );
              },
            ),
          ),
        ),

        // Hero text on top
        Positioned(
          top: 72,
          left: 28,
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      AppConstants.appName,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Track. Save. Grow.',
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── SHARED FORM ────────────────────────────────────────────
  Widget _buildForm(AuthProvider auth, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome',
          style: GoogleFonts.inter(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary(isDark),
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Sign in or create your account',
          style: TextStyle(color: AppColors.textTertiary(isDark), fontSize: 14),
        ),
        SizedBox(height: 24),

        // Tab bar
        Container(
          decoration: BoxDecoration(
            color: AppColors.card(isDark),
            borderRadius: BorderRadius.circular(14),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            labelColor: Colors.white,
            unselectedLabelColor: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
            dividerColor: Colors.transparent,
            labelStyle: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            tabs: const [Tab(text: 'Login'), Tab(text: 'Sign Up')],
          ),
        ),
        const SizedBox(height: 28),

        SizedBox(
          height: 520,
          child: TabBarView(
            controller: _tabController,
            children: [
              _LoginForm(
                formKey: _loginFormKey,
                email: _loginEmail,
                password: _loginPassword,
                obscure: _obscureLogin,
                onToggleObscure: () =>
                    setState(() => _obscureLogin = !_obscureLogin),
                auth: auth,
                isDark: isDark,
              ),
              _SignupForm(
                formKey: _signupFormKey,
                name: _signupName,
                email: _signupEmail,
                password: _signupPassword,
                obscure: _obscureSignup,
                onToggleObscure: () =>
                    setState(() => _obscureSignup = !_obscureSignup),
                auth: auth,
                isDark: isDark,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── LOGIN FORM ─────────────────────────────────────────────────────────────────

class _LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController email, password;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final AuthProvider auth;
  final bool isDark;

  const _LoginForm({
    required this.formKey,
    required this.email,
    required this.password,
    required this.obscure,
    required this.onToggleObscure,
    required this.auth,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          _PremiumTextField(
            controller: email,
            label: 'Email',
            hint: 'your@email.com',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            isDark: isDark,
            validator: (v) =>
                v!.contains('@') ? null : 'Enter valid email',
          ),
          const SizedBox(height: 14),
          _PremiumTextField(
            controller: password,
            label: 'Password',
            hint: '••••••••',
            icon: Icons.lock_outline_rounded,
            obscureText: obscure,
            isDark: isDark,
            suffix: IconButton(
              onPressed: onToggleObscure,
              icon: Icon(
                obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                size: 18,
                color: AppColors.textTertiary(isDark),
              ),
            ),
            validator: (v) =>
                v!.length >= 6 ? null : 'Min 6 characters',
          ),
          const SizedBox(height: 28),

          if (auth.error != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.error, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      auth.error!,
                      style: const TextStyle(color: AppColors.error, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          _GradientButton(
            loading: auth.isLoading,
            label: 'Login',
            onTap: () {
              if (formKey.currentState!.validate()) {
                auth.signIn(email.text.trim(), password.text.trim());
              }
            },
          ),
          const SizedBox(height: 24),
          _buildAuthDivider(isDark: isDark),
          const SizedBox(height: 24),
          _GoogleSignInButton(auth: auth, isDark: isDark),
        ],
      ),
    );
  }
}

// ── SIGNUP FORM ────────────────────────────────────────────────────────────────

class _SignupForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController name, email, password;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final AuthProvider auth;
  final bool isDark;

  const _SignupForm({
    required this.formKey,
    required this.name,
    required this.email,
    required this.password,
    required this.obscure,
    required this.onToggleObscure,
    required this.auth,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          _PremiumTextField(
            controller: name,
            label: 'Full Name',
            hint: 'John Doe',
            icon: Icons.person_outline_rounded,
            isDark: isDark,
            validator: (v) => v!.trim().isEmpty ? 'Name required' : null,
          ),
          const SizedBox(height: 14),
          _PremiumTextField(
            controller: email,
            label: 'Email',
            hint: 'your@email.com',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            isDark: isDark,
            validator: (v) =>
                v!.contains('@') ? null : 'Enter valid email',
          ),
          const SizedBox(height: 14),
          _PremiumTextField(
            controller: password,
            label: 'Password',
            hint: '••••••••',
            icon: Icons.lock_outline_rounded,
            obscureText: obscure,
            isDark: isDark,
            suffix: IconButton(
              onPressed: onToggleObscure,
              icon: Icon(
                obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                size: 18,
                color: AppColors.textTertiary(isDark),
              ),
            ),
            validator: (v) =>
                v!.length >= 6 ? null : 'Min 6 characters',
          ),
          const SizedBox(height: 28),

          if (auth.error != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.error, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      auth.error!,
                      style: const TextStyle(color: AppColors.error, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          _GradientButton(
            loading: auth.isLoading,
            label: 'Create Account',
            onTap: () {
              if (formKey.currentState!.validate()) {
                auth.signUp(
                  email.text.trim(),
                  password.text.trim(),
                  name.text.trim(),
                );
              }
            },
          ),
          const SizedBox(height: 24),
          _buildAuthDivider(isDark: isDark),
          const SizedBox(height: 24),
          _GoogleSignInButton(auth: auth, isDark: isDark),
        ],
      ),
    );
  }
}

// ── REUSABLE PREMIUM WIDGETS ───────────────────────────────────────────────────

class _PremiumTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label, hint;
  final IconData icon;
  final bool obscureText;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool isDark;

  const _PremiumTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.isDark,
    this.obscureText = false,
    this.suffix,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary(isDark),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 18, color: AppColors.textTertiary(isDark)),
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}

class _GradientButton extends StatelessWidget {
  final bool loading;
  final String label;
  final VoidCallback onTap;

  const _GradientButton({
    required this.loading,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutQuart,
        height: 52,
        decoration: BoxDecoration(
          gradient: loading ? null : AppColors.primaryGradient,
          color: loading ? AppColors.textTertiary(isDark) : null,
          borderRadius: BorderRadius.circular(14),
          boxShadow: loading
              ? []
              : [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        alignment: Alignment.center,
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
      ),
    );
  }
}

// ── OAUTH & DIVIDER ────────────────────────────────────────────────────────────

Widget _buildAuthDivider({required bool isDark}) {
  final color = isDark ? AppColors.darkBorder : AppColors.lightBorder;
  return Row(
    children: [
      Expanded(child: Divider(color: color, thickness: 1)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          'Or continue with',
          style: TextStyle(
            color: AppColors.textTertiary(isDark),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      Expanded(child: Divider(color: color, thickness: 1)),
    ],
  );
}

class _GoogleSignInButton extends StatelessWidget {
  final AuthProvider auth;
  final bool isDark;

  const _GoogleSignInButton({required this.auth, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: auth.isLoading ? null : () => auth.signInWithGoogle(),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.surface(isDark),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Simple Google icon simulation or use Image if asset exists
            // We use a local image if possible, but a colored text G works too
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Image.network(
                'https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg',
                width: 18,
                height: 18,
                errorBuilder: (ctx, err, stack) => const Text(
                  'G',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Google',
              style: TextStyle(
                color: AppColors.textPrimary(isDark),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
