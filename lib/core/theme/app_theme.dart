// ignore_for_file: deprecated_member_use

import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary palette — Rich blush pink & luxury tones
  static const Color primary = Color(0xFFC48994);
  static const Color primaryLight = Color(0xFFF0DDE0);
  static const Color primaryDark = Color(0xFF8E5A64);

  // Accent — Champagne gold
  static const Color accent = Color(0xFFDDB681);

  // Backgrounds - Warm cream & soft white
  static const Color secondary = Color(0xFFF5EDE8);
  static const Color background = Color(0xFFFAF8F6);
  static const Color surface = Color(0xFFFFFFFF);

  // Text - Warm dark tones
  static const Color textDark = Color(0xFF1E1B19);
  static const Color textMedium = Color(0xFF5C5652);
  static const Color textLight = Color(0xFF9E9590);

  // UI
  static const Color border = Color(0xFFE5DDD5);
  static const Color success = Color(0xFF4A8B63);
  static const Color gold = Color(0xFFDDB681);
  static const Color platinum = Color(0xFF8E9BB5);
  static const Color diamond = Color(0xFF8CABC5);
  static const Color error = Color(0xFFC04E4A);

  // Dark Mode Palette — slightly lighter/warmer
  static const Color darkBackground = Color(0xFF141216);
  static const Color darkSurface = Color(0xFF1F1C21);
}

/// Glassmorphism configuration
class GlassConfig {
  static const double blurStrength = 24;
  static const double containerOpacity = 0.4;
  static const double borderOpacity = 0.2;
  static const double borderWidth = 1.0;
  static const double borderRadius = 32;
}

class AppTheme {
  // Custom page transition for all platforms
  static final _pageTransitions = PageTransitionsTheme(
    // ignore: prefer_const_literals_to_create_immutables
    builders: {
      TargetPlatform.android: _ModernPageTransitionBuilder(),
      TargetPlatform.iOS: _ModernPageTransitionBuilder(),
      TargetPlatform.windows: _ModernPageTransitionBuilder(),
      TargetPlatform.macOS: _ModernPageTransitionBuilder(),
      TargetPlatform.linux: _ModernPageTransitionBuilder(),
    },
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      pageTransitionsTheme: _pageTransitions,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.secondary,
        onSecondary: AppColors.textDark,
        error: AppColors.error,
        onError: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.textDark,
      ),
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Cairo',
      textTheme: GoogleFonts.cairoTextTheme().apply(
        bodyColor: AppColors.textDark,
        displayColor: AppColors.textDark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
          letterSpacing: 0.5,
        ),
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle:
              GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w600),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          foregroundColor: AppColors.primary,
          minimumSize: const Size(double.infinity, 56),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle:
              GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.border.withOpacity(0.6))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
        hintStyle: GoogleFonts.cairo(color: AppColors.textLight),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      pageTransitionsTheme: _pageTransitions,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.primary,
        onPrimary: AppColors.darkBackground,
        secondary: AppColors.darkSurface,
        onSecondary: Colors.white,
        error: Color(0xFFE25858),
        onError: Colors.white,
        surface: AppColors.darkSurface,
        onSurface: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      fontFamily: 'Cairo',
      textTheme: GoogleFonts.cairoTextTheme().apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.darkBackground,
          minimumSize: const Size(double.infinity, 56),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle:
              GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w600),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          foregroundColor: AppColors.primary,
          minimumSize: const Size(double.infinity, 56),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle:
              GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.white10)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
        hintStyle: GoogleFonts.cairo(color: Colors.white38),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
    );
  }

  // Modern Glassmorphism Container
  static Widget buildGlassContainer({
    required Widget child,
    required BuildContext context,
    double blur = GlassConfig.blurStrength,
    double opacity = GlassConfig.containerOpacity,
    double borderOpacity = GlassConfig.borderOpacity,
    BorderRadius? borderRadius,
    EdgeInsets padding = const EdgeInsets.all(20),
    BoxShadow? shadow,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final glassColor = isDark ? Colors.black : Colors.white;

    return ClipRRect(
      borderRadius:
          borderRadius ?? BorderRadius.circular(GlassConfig.borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: glassColor.withOpacity(opacity),
            borderRadius:
                borderRadius ?? BorderRadius.circular(GlassConfig.borderRadius),
            border: Border.all(
              color: glassColor.withOpacity(borderOpacity),
              width: GlassConfig.borderWidth,
            ),
            boxShadow: shadow != null ? [shadow] : null,
          ),
          child: child,
        ),
      ),
    );
  }

  // Ultra-Premium Glass Bottom Navigation Base
  static Widget buildFloatingNav({
    required Widget child,
    required BuildContext context,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: (isDark ? Colors.black : Colors.white)
                  .withOpacity(isDark ? 0.4 : 0.65),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: (isDark ? Colors.white : AppColors.primary)
                    .withOpacity(isDark ? 0.08 : 0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  /// Build a glass button with gradient
  static Widget buildGlassButton({
    required VoidCallback onPressed,
    required String label,
    bool isLoading = false,
    Color? gradientStart,
    Color? gradientEnd,
    double? width,
    double height = 56,
  }) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  gradientStart ?? AppColors.primary,
                  gradientEnd ?? AppColors.primaryLight,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isLoading ? null : onPressed,
                child: Center(
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          label,
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget buildGlassCard({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(20),
    double blur = GlassConfig.blurStrength,
    double opacity = GlassConfig.containerOpacity,
    double borderOpacity = GlassConfig.borderOpacity,
    BorderRadius? borderRadius,
    bool withShadow = true,
  }) {
    return ClipRRect(
      borderRadius:
          borderRadius ?? BorderRadius.circular(GlassConfig.borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(opacity),
            borderRadius:
                borderRadius ?? BorderRadius.circular(GlassConfig.borderRadius),
            border: Border.all(
              color: Colors.white.withOpacity(borderOpacity),
              width: GlassConfig.borderWidth,
            ),
            boxShadow: withShadow
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: child,
        ),
      ),
    );
  }
}

extension BlurExtension on Widget {
  Widget blur({double sigmaX = 40, double sigmaY = 40}) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
      child: this,
    );
  }
}

/// Modern page transition: slide up + fade + subtle scale
class _ModernPageTransitionBuilder extends PageTransitionsBuilder {
  const _ModernPageTransitionBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Entering screen
    final offsetTween = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).chain(CurveTween(curve: Curves.easeOutQuart));

    final fadeTween = Tween<double>(begin: 0, end: 1)
        .chain(CurveTween(curve: Curves.easeOut));

    final scaleTween = Tween<double>(begin: 0.96, end: 1.0)
        .chain(CurveTween(curve: Curves.easeOutQuart));

    // Exiting screen (pushed behind) — subtle fade out
    final secondaryFadeTween = Tween<double>(begin: 1, end: 0.92)
        .chain(CurveTween(curve: Curves.easeIn));

    final secondaryScaleTween = Tween<double>(begin: 1.0, end: 0.95)
        .chain(CurveTween(curve: Curves.easeIn));

    return FadeTransition(
      opacity: animation.drive(fadeTween),
      child: ScaleTransition(
        scale: animation.drive(scaleTween),
        child: SlideTransition(
          position: animation.drive(offsetTween),
          child: ScaleTransition(
            scale: secondaryAnimation.drive(secondaryScaleTween),
            child: FadeTransition(
              opacity: secondaryAnimation.drive(secondaryFadeTween),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
