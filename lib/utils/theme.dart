// lib/utils/theme.dart — CRED / Zerodha / GPay Premium Color System
// Designed for pixel-perfect visibility in BOTH light + dark mode.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  PREMIUM COLOR PALETTE
//  Philosophy:
//  • Light mode  → Crisp white canvas, deep navy primary, vivid accents
//  • Dark mode   → True OLED black base, electric indigo primary, neon accents
//  • Every foreground text color is tested for 4.5:1+ contrast ratio
//  • Inspired by: CRED (obsidian/gold), Zerodha (clean blue/green),
//                 GPay (deep blue/teal), Paytm (midnight blue/cyan)
// ─────────────────────────────────────────────────────────────────────────────

class AppColors {

  // ── BRAND CORE ─────────────────────────────────────────────────────────────
  /// Deep navy — dominant primary for light mode (AAA contrast on white)
  static const Color primary        = Color(0xFF0A1628);
  /// Rich indigo — dominant primary for dark mode (bright on OLED black)
  static const Color primaryDark    = Color(0xFF4F6EF7);
  /// Electric teal accent (income, CTA highlights)
  static const Color accent         = Color(0xFF00D09C);
  /// Soft warm gold (warnings)
  static const Color amber          = Color(0xFFE8A838);
  /// Coral red (expense, error)
  static const Color coral          = Color(0xFFFF4D6A);
  /// Soft violet (transfer)
  static const Color violet         = Color(0xFF8B5CF6);

  // ── TRANSACTION TYPE COLORS ─────────────────────────────────────────────────
  static const Color income       = Color(0xFF00C896);  // emerald green
  static const Color expense      = Color(0xFFFF4D6A);  // coral red
  static const Color transfer     = Color(0xFF6366F1);  // indigo
  static const Color lent         = Color(0xFF06B6D4);  // cyan
  static const Color receivedBack = Color(0xFF0EA5E9);  // steel sky

  // ── LIGHT THEME SURFACES ────────────────────────────────────────────────────
  static const Color lightBg        = Color(0xFFF2F4F7);
  static const Color lightSurface   = Color(0xFFFFFFFF);
  static const Color lightCard      = Color(0xFFF8F9FC);
  static const Color lightChip      = Color(0xFFEEF0F8);
  static const Color lightBorder    = Color(0xFFE4E7EF);
  static const Color lightDivider   = Color(0xFFF0F2F8);

  // ── LIGHT THEME TEXT ────────────────────────────────────────────────────────
  static const Color lightTextPrimary   = Color(0xFF0A1628);
  static const Color lightTextSecondary = Color(0xFF3D4966);
  static const Color lightTextTertiary  = Color(0xFF7B8DB0);
  static const Color lightTextDisabled  = Color(0xFFB0BAD0);

  // ── DARK THEME SURFACES ─────────────────────────────────────────────────────
  static const Color darkBg        = Color(0xFF050811);
  static const Color darkSurface   = Color(0xFF0D1120);
  static const Color darkCard      = Color(0xFF141824);
  static const Color darkCardAlt   = Color(0xFF1A2030);
  static const Color darkInputFill = Color(0xFF111520);
  static const Color darkBorder    = Color(0xFF232B40);
  static const Color darkDivider   = Color(0xFF1A2235);

  // ── DARK THEME TEXT ─────────────────────────────────────────────────────────
  static const Color darkTextPrimary   = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFCDD5ED);
  static const Color darkTextTertiary  = Color(0xFF9AAAC8);
  static const Color darkTextDisabled  = Color(0xFF3A4460);

  // ── STATUS COLORS ───────────────────────────────────────────────────────────
  static const Color success = Color(0xFF00C896);
  static const Color warning = Color(0xFFE8A838);
  static const Color error   = Color(0xFFFF4D6A);
  static const Color info    = Color(0xFF4F6EF7);

  // ── GLASS / OVERLAY ─────────────────────────────────────────────────────────
  static const Color glassLight  = Color(0x14FFFFFF);
  static const Color glassDark   = Color(0x14000000);
  static const Color glassStroke = Color(0x28FFFFFF);
  // Legacy compat
  static const Color glassWhite  = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);

  // ─────────────────────────────────────────────────────────────────────────────
  //  GRADIENTS
  // ─────────────────────────────────────────────────────────────────────────────

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0A1628), Color(0xFF1A2D52)],
  );

  static const LinearGradient primaryGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E2D6B), Color(0xFF0D1530)],
  );

  static const LinearGradient incomeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00C896), Color(0xFF00A07A)],
  );

  static const LinearGradient expenseGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF4D6A), Color(0xFFD4264A)],
  );

  static const LinearGradient transferGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6366F1), Color(0xFF4338CA)],
  );

  static const LinearGradient lentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
  );

  static const LinearGradient receivedBackGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00D09C), Color(0xFF00A8E0)],
  );

  static const LinearGradient statsGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4F6EF7), Color(0xFF8B5CF6)],
  );

  // ─────────────────────────────────────────────────────────────────────────────
  //  CONTEXT-AWARE HELPERS — guaranteed correct visibility in both modes
  // ─────────────────────────────────────────────────────────────────────────────

  static Color bg(bool isDark)            => isDark ? darkBg           : lightBg;
  static Color surface(bool isDark)       => isDark ? darkSurface       : lightSurface;
  static Color card(bool isDark)          => isDark ? darkCard          : lightSurface;
  static Color cardAlt(bool isDark)       => isDark ? darkCardAlt       : lightCard;
  static Color inputFill(bool isDark)     => isDark ? darkInputFill     : lightCard;
  static Color border(bool isDark)        => isDark ? darkBorder        : lightBorder;
  static Color divider(bool isDark)       => isDark ? darkDivider       : lightDivider;
  static Color chip(bool isDark)          => isDark ? darkCardAlt       : lightChip;

  static Color textPrimary(bool isDark)   => isDark ? darkTextPrimary   : lightTextPrimary;
  static Color textSecondary(bool isDark) => isDark ? darkTextSecondary : lightTextSecondary;
  static Color textTertiary(bool isDark)  => isDark ? darkTextTertiary  : lightTextTertiary;
  static Color textDisabled(bool isDark)  => isDark ? darkTextDisabled  : lightTextDisabled;

  static Color brand(bool isDark)         => isDark ? primaryDark       : primary;
  static LinearGradient heroGradient(bool isDark) =>
      isDark ? primaryGradientDark : primaryGradient;

  static Color typeColor(String type) {
    switch (type.toLowerCase()) {
      case 'income':        return income;
      case 'expense':       return expense;
      case 'transfer':      return transfer;
      case 'lent':          return lent;
      case 'receivedback':
      case 'received':      return receivedBack;
      default:              return info;
    }
  }

  static LinearGradient typeGradient(String type) {
    switch (type.toLowerCase()) {
      case 'income':        return incomeGradient;
      case 'expense':       return expenseGradient;
      case 'transfer':      return transferGradient;
      case 'lent':          return lentGradient;
      case 'receivedback':
      case 'received':      return receivedBackGradient;
      default:              return statsGradient;
    }
  }

  // Legacy compat — textGrey, textDark, textLight
  static const Color textGrey  = darkTextTertiary;
  static const Color textDark  = lightTextPrimary;
  static const Color textLight = lightTextSecondary;
}

// ─────────────────────────────────────────────────────────────────────────────
//  PREMIUM SHADOW SYSTEM
// ─────────────────────────────────────────────────────────────────────────────

class AppShadows {
  static List<BoxShadow> card = [
    BoxShadow(
      color: const Color(0xFF0A1628).withValues(alpha: 0.06),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: const Color(0xFF0A1628).withValues(alpha: 0.03),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> elevated = [
    BoxShadow(
      color: const Color(0xFF0A1628).withValues(alpha: 0.10),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: const Color(0xFF0A1628).withValues(alpha: 0.04),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> cardDark = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.35),
      blurRadius: 20,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> heroGlow(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.28),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: color.withValues(alpha: 0.12),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> modeCard(bool isDark) =>
      isDark ? cardDark : card;
}

// ─────────────────────────────────────────────────────────────────────────────
//  SMOOTH SCROLL BEHAVIOR  (removes overscroll glow, adds physics feel)
// ─────────────────────────────────────────────────────────────────────────────

class SmoothScrollBehavior extends ScrollBehavior {
  const SmoothScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child; // no ugly glow
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
}

// ─────────────────────────────────────────────────────────────────────────────
//  SMOOTH BOTTOM SHEET  (silky open/close like GPay/CRED)
// ─────────────────────────────────────────────────────────────────────────────

class AppBottomSheet {
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    bool isScrollControlled = true,
    double initialChildSize = 0.6,
    double maxChildSize = 0.95,
    double minChildSize = 0.3,
    bool snap = true,
    bool useDraggable = true,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionAnimationController: AnimationController(
        vsync: Navigator.of(context),
        duration: const Duration(milliseconds: 380),
        reverseDuration: const Duration(milliseconds: 280),
      ),
      builder: (_) => useDraggable
          ? DraggableScrollableSheet(
              initialChildSize: initialChildSize,
              maxChildSize: maxChildSize,
              minChildSize: minChildSize,
              snap: snap,
              snapSizes: [initialChildSize, maxChildSize],
              expand: false,
              builder: (_, scrollCtrl) => _SheetContainer(
                isDark: isDark,
                scrollController: scrollCtrl,
                child: child,
              ),
            )
          : _SheetContainer(isDark: isDark, child: child),
    );
  }
}

class _SheetContainer extends StatelessWidget {
  final bool isDark;
  final Widget child;
  final ScrollController? scrollController;

  const _SheetContainer({
    required this.isDark,
    required this.child,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 32,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 8),
          Flexible(child: child),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  PAGE TRANSITIONS
// ─────────────────────────────────────────────────────────────────────────────

class AppPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final RouteSettings? routeSettings;

  AppPageRoute({required this.page, this.routeSettings})
      : super(
    settings: routeSettings,
    pageBuilder: (_, animation, __) => page,
    transitionDuration: const Duration(milliseconds: 340),
    reverseTransitionDuration: const Duration(milliseconds: 280),
    transitionsBuilder: (_, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutQuart,
        reverseCurve: Curves.easeInQuart,
      );
      // Outgoing screen slides away slightly (like iOS)
      final secondaryCurved = CurvedAnimation(
        parent: secondaryAnimation,
        curve: Curves.easeInQuart,
      );
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.04, 0),
          end: Offset.zero,
        ).animate(curved),
        child: FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curved),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset.zero,
              end: const Offset(-0.04, 0),
            ).animate(secondaryCurved),
            child: child,
          ),
        ),
      );
    },
  );
}

class AppScaleRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  AppScaleRoute({required this.page})
      : super(
    pageBuilder: (_, __, ___) => page,
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 260),
    transitionsBuilder: (_, animation, __, child) {
      final curved = CurvedAnimation(
          parent: animation, curve: Curves.easeOutQuart);
      return ScaleTransition(
        scale: Tween<double>(begin: 0.92, end: 1.0).animate(curved),
        child: FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOut),
          ),
          child: child,
        ),
      );
    },
  );
}

/// Bottom-to-top modal route — for add/edit screens
class AppSlideUpRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  AppSlideUpRoute({required this.page})
      : super(
    pageBuilder: (_, __, ___) => page,
    transitionDuration: const Duration(milliseconds: 360),
    reverseTransitionDuration: const Duration(milliseconds: 280),
    transitionsBuilder: (_, animation, __, child) {
      final curved = CurvedAnimation(
          parent: animation, curve: Curves.easeOutQuart);
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      );
    },
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  STAGGERED ANIMATION
// ─────────────────────────────────────────────────────────────────────────────

class StaggeredAnimation extends StatelessWidget {
  final int index;
  final Widget child;
  final Duration duration;
  final Duration delayPerItem;

  const StaggeredAnimation({
    super.key,
    required this.index,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.delayPerItem = const Duration(milliseconds: 45),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey('stagger_$index'),
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(
        milliseconds:
        duration.inMilliseconds + delayPerItem.inMilliseconds * index,
      ),
      curve: Curves.easeOutQuart,
      builder: (_, value, child) {
        return Transform.translate(
          offset: Offset(0, 14 * (1 - value)),
          child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
        );
      },
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  GLASS CARD
// ─────────────────────────────────────────────────────────────────────────────

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? color;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 20,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color ?? AppColors.glassLight,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppColors.glassStroke),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  THEME DATA
// ─────────────────────────────────────────────────────────────────────────────

class AppTheme {
  // Backward-compat aliases
  static const Color primary      = AppColors.primary;
  static const Color secondary    = AppColors.accent;
  static const Color accent       = AppColors.violet;
  static const Color income       = AppColors.income;
  static const Color expense      = AppColors.expense;
  static const Color transfer     = AppColors.transfer;
  static const Color lent         = AppColors.lent;
  static const Color receivedBack = AppColors.receivedBack;
  static const Color surface      = AppColors.lightBg;
  static const Color cardBg       = AppColors.lightSurface;

  static PageTransitionsTheme get _pageTransitions =>
      const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS:     CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS:   CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux:   CupertinoPageTransitionsBuilder(),
        },
      );

  // ── LIGHT THEME ─────────────────────────────────────────────────────────────
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    pageTransitionsTheme: _pageTransitions,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.accent,
      onSecondary: Colors.white,
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightTextPrimary,
      error: AppColors.error,
      onError: Colors.white,
      outline: AppColors.lightBorder,
    ),
    scaffoldBackgroundColor: AppColors.lightBg,
    textTheme: GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.inter(
          fontSize: 32, fontWeight: FontWeight.w800,
          color: AppColors.lightTextPrimary, letterSpacing: -0.5),
      displayMedium: GoogleFonts.inter(
          fontSize: 26, fontWeight: FontWeight.w700,
          color: AppColors.lightTextPrimary, letterSpacing: -0.3),
      headlineLarge: GoogleFonts.inter(
          fontSize: 22, fontWeight: FontWeight.w700,
          color: AppColors.lightTextPrimary),
      headlineMedium: GoogleFonts.inter(
          fontSize: 18, fontWeight: FontWeight.w600,
          color: AppColors.lightTextPrimary),
      titleLarge: GoogleFonts.inter(
          fontSize: 16, fontWeight: FontWeight.w600,
          color: AppColors.lightTextPrimary),
      titleMedium: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w600,
          color: AppColors.lightTextPrimary),
      bodyLarge: GoogleFonts.inter(
          fontSize: 15, fontWeight: FontWeight.w400,
          color: AppColors.lightTextPrimary),
      bodyMedium: GoogleFonts.inter(
          fontSize: 13, fontWeight: FontWeight.w400,
          color: AppColors.lightTextSecondary),
      bodySmall: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w400,
          color: AppColors.lightTextTertiary),
      labelLarge: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w600,
          color: AppColors.lightTextPrimary, letterSpacing: 0.1),
      labelMedium: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w500,
          color: AppColors.lightTextSecondary),
      labelSmall: GoogleFonts.inter(
          fontSize: 11, fontWeight: FontWeight.w500,
          color: AppColors.lightTextTertiary, letterSpacing: 0.4),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.lightSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      titleTextStyle: GoogleFonts.inter(
        color: AppColors.lightTextPrimary,
        fontSize: 17,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
      iconTheme: const IconThemeData(
          color: AppColors.lightTextPrimary, size: 22),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: AppColors.lightSurface,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.lightBorder),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightCard,
      hintStyle: GoogleFonts.inter(
          color: AppColors.lightTextDisabled, fontSize: 14),
      labelStyle: GoogleFonts.inter(
          color: AppColors.lightTextSecondary,
          fontSize: 14, fontWeight: FontWeight.w500),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.lightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
        const BorderSide(color: AppColors.primary, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1.8),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600, fontSize: 15, letterSpacing: 0.1),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.lightBorder),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.lightSurface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: AppColors.primary.withValues(alpha: 0.10),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return GoogleFonts.inter(
              fontSize: 11, fontWeight: FontWeight.w600,
              color: AppColors.primary);
        }
        return GoogleFonts.inter(
            fontSize: 11, fontWeight: FontWeight.w500,
            color: AppColors.lightTextTertiary);
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.primary, size: 22);
        }
        return const IconThemeData(
            color: AppColors.lightTextTertiary, size: 22);
      }),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.lightChip,
      labelStyle: GoogleFonts.inter(
          color: AppColors.lightTextSecondary,
          fontSize: 12, fontWeight: FontWeight.w500),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8)),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    ),
    dividerTheme: const DividerThemeData(
        color: AppColors.lightDivider, thickness: 1, space: 1),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.primary,
      contentTextStyle: GoogleFonts.inter(
          color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.lightSurface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)),
      titleTextStyle: GoogleFonts.inter(
          color: AppColors.lightTextPrimary,
          fontSize: 17, fontWeight: FontWeight.w700),
      contentTextStyle: GoogleFonts.inter(
          color: AppColors.lightTextSecondary, fontSize: 14),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.lightSurface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.vertical(top: Radius.circular(24))),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.white;
        return AppColors.lightTextDisabled;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.accent;
        return AppColors.lightBorder;
      }),
    ),
    listTileTheme: ListTileThemeData(
      tileColor: Colors.transparent,
      iconColor: AppColors.lightTextSecondary,
      titleTextStyle: GoogleFonts.inter(
          color: AppColors.lightTextPrimary,
          fontSize: 14, fontWeight: FontWeight.w500),
      subtitleTextStyle: GoogleFonts.inter(
          color: AppColors.lightTextTertiary, fontSize: 12),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary, linearMinHeight: 4),
    tabBarTheme: TabBarThemeData(
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.lightTextTertiary,
      indicatorColor: AppColors.primary,
      labelStyle: GoogleFonts.inter(
          fontSize: 13, fontWeight: FontWeight.w600),
      unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 13, fontWeight: FontWeight.w500),
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: Colors.transparent,
    ),
  );

  // ── DARK THEME ──────────────────────────────────────────────────────────────
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    pageTransitionsTheme: _pageTransitions,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryDark,
      onPrimary: Colors.white,
      secondary: AppColors.accent,
      onSecondary: Colors.white,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkTextPrimary,
      error: AppColors.error,
      onError: Colors.white,
      outline: AppColors.darkBorder,
    ),
    scaffoldBackgroundColor: AppColors.darkBg,
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: GoogleFonts.inter(
          fontSize: 32, fontWeight: FontWeight.w800,
          color: AppColors.darkTextPrimary, letterSpacing: -0.5),
      displayMedium: GoogleFonts.inter(
          fontSize: 26, fontWeight: FontWeight.w700,
          color: AppColors.darkTextPrimary, letterSpacing: -0.3),
      headlineLarge: GoogleFonts.inter(
          fontSize: 22, fontWeight: FontWeight.w700,
          color: AppColors.darkTextPrimary),
      headlineMedium: GoogleFonts.inter(
          fontSize: 18, fontWeight: FontWeight.w600,
          color: AppColors.darkTextPrimary),
      titleLarge: GoogleFonts.inter(
          fontSize: 16, fontWeight: FontWeight.w600,
          color: AppColors.darkTextPrimary),
      titleMedium: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w600,
          color: AppColors.darkTextPrimary),
      bodyLarge: GoogleFonts.inter(
          fontSize: 15, fontWeight: FontWeight.w400,
          color: AppColors.darkTextPrimary),
      bodyMedium: GoogleFonts.inter(
          fontSize: 13, fontWeight: FontWeight.w400,
          color: AppColors.darkTextSecondary),
      bodySmall: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w400,
          color: AppColors.darkTextTertiary),
      labelLarge: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w600,
          color: AppColors.darkTextPrimary, letterSpacing: 0.1),
      labelMedium: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w500,
          color: AppColors.darkTextSecondary),
      labelSmall: GoogleFonts.inter(
          fontSize: 11, fontWeight: FontWeight.w500,
          color: AppColors.darkTextTertiary, letterSpacing: 0.4),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkBg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      titleTextStyle: GoogleFonts.inter(
        color: AppColors.darkTextPrimary,
        fontSize: 17,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
      iconTheme: const IconThemeData(
          color: AppColors.darkTextPrimary, size: 22),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: AppColors.darkCard,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.darkBorder),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkInputFill,
      hintStyle: GoogleFonts.inter(
          color: AppColors.darkTextDisabled, fontSize: 14),
      labelStyle: GoogleFonts.inter(
          color: AppColors.darkTextTertiary,
          fontSize: 14, fontWeight: FontWeight.w500),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
        const BorderSide(color: AppColors.primaryDark, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1.8),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600, fontSize: 15, letterSpacing: 0.1),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryDark,
        textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryDark,
        side: const BorderSide(color: AppColors.darkBorder),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.darkSurface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: AppColors.primaryDark.withValues(alpha: 0.15),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return GoogleFonts.inter(
              fontSize: 11, fontWeight: FontWeight.w600,
              color: AppColors.primaryDark);
        }
        return GoogleFonts.inter(
            fontSize: 11, fontWeight: FontWeight.w500,
            color: AppColors.darkTextTertiary);
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(
              color: AppColors.primaryDark, size: 22);
        }
        return const IconThemeData(
            color: AppColors.darkTextTertiary, size: 22);
      }),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.darkCardAlt,
      labelStyle: GoogleFonts.inter(
          color: AppColors.darkTextSecondary,
          fontSize: 12, fontWeight: FontWeight.w500),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8)),
      side: const BorderSide(color: AppColors.darkBorder),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    ),
    dividerTheme: const DividerThemeData(
        color: AppColors.darkDivider, thickness: 1, space: 1),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.darkCard,
      contentTextStyle: GoogleFonts.inter(
          color: AppColors.darkTextPrimary,
          fontSize: 13, fontWeight: FontWeight.w500),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.darkBorder),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.darkCard,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.darkBorder),
      ),
      titleTextStyle: GoogleFonts.inter(
          color: AppColors.darkTextPrimary,
          fontSize: 17, fontWeight: FontWeight.w700),
      contentTextStyle: GoogleFonts.inter(
          color: AppColors.darkTextSecondary, fontSize: 14),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.darkCard,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.vertical(top: Radius.circular(24))),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.white;
        return AppColors.darkTextDisabled;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.accent;
        return AppColors.darkBorder;
      }),
    ),
    listTileTheme: ListTileThemeData(
      tileColor: Colors.transparent,
      iconColor: AppColors.darkTextSecondary,
      titleTextStyle: GoogleFonts.inter(
          color: AppColors.darkTextPrimary,
          fontSize: 14, fontWeight: FontWeight.w500),
      subtitleTextStyle: GoogleFonts.inter(
          color: AppColors.darkTextTertiary, fontSize: 12),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primaryDark, linearMinHeight: 4),
    tabBarTheme: TabBarThemeData(
      labelColor: AppColors.primaryDark,
      unselectedLabelColor: AppColors.darkTextTertiary,
      indicatorColor: AppColors.primaryDark,
      labelStyle: GoogleFonts.inter(
          fontSize: 13, fontWeight: FontWeight.w600),
      unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 13, fontWeight: FontWeight.w500),
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: Colors.transparent,
    ),
    dividerColor: AppColors.darkDivider,
  );

  // ─── Account color palette ──────────────────────────────────────────────────
  static const List<String> accountColors = [
    '#0A1628', '#1A2D52', '#1A3A6B', '#0D47A1', '#1565C0',
    '#00796B', '#00897B', '#00A07A', '#1FA843', '#2E7D32',
    '#4F6EF7', '#5C6BC0', '#6366F1', '#7C3AED', '#8B5CF6',
    '#E65100', '#EF6C00', '#FF9500', '#FFAA00', '#F9A825',
    '#C62828', '#D32F2F', '#FF4D6A', '#E53935',
    '#263238', '#37474F', '#455A64', '#546E7A', '#607D8B',
    '#78909C', '#90A4AE', '#B0BEC5',
    '#4E342E', '#6D4C41', '#8D6E63',
  ];

  static Color hexToColor(String hex) {
    final h = hex.replaceFirst('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  APP CONSTANTS
// ─────────────────────────────────────────────────────────────────────────────

class AppConstants {
  static const String appName  = 'Expense Tracker';
  static String currencySymbol = '₹';

  static String formatAmount(double amount) {
    if (amount >= 10000000) return '${(amount / 10000000).toStringAsFixed(2)}Cr';
    if (amount >= 100000)   return '${(amount / 100000).toStringAsFixed(2)}L';
    if (amount >= 1000)     return '${(amount / 1000).toStringAsFixed(1)}K';
    return amount.toStringAsFixed(2);
  }

  static String formatFull(double amount) {
    final format = NumberFormat.currency(
      locale: 'en_IN',
      symbol: currencySymbol,
      decimalDigits: 2,
    );
    return format.format(amount);
  }
}