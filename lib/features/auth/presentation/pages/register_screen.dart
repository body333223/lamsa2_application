// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/locale_service.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glow_orb.dart';
import '../../../home/presentation/pages/home_screen.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/social_login_buttons.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthService>();
    try {
      await auth.registerWithEmailPassword(
        _emailCtrl.text.trim(),
        _passwordCtrl.text.trim(),
        name: _nameCtrl.text.trim(),
      );
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString(), style: GoogleFonts.cairo()),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(context);
    final localeService = context.watch<LocaleService>();
    final isArabic = localeService.isArabic;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background Glow Orbs
          Positioned(
            top: -50,
            left: -50,
            child:
                GlowOrb(size: 250, color: AppColors.primary.withOpacity(0.15)),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child:
                GlowOrb(size: 300, color: AppColors.accent.withOpacity(0.12)),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Back Button & Language Toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppTheme.buildGlassContainer(
                        context: context,
                        padding: EdgeInsets.zero,
                        opacity: 0.1,
                        borderRadius: BorderRadius.circular(16),
                        child: IconButton(
                          icon: Icon(
                            isArabic
                                ? Icons.arrow_forward_ios_rounded
                                : Icons.arrow_back_ios_rounded,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      AppTheme.buildGlassContainer(
                        context: context,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        opacity: 0.1,
                        borderRadius: BorderRadius.circular(16),
                        child: TextButton.icon(
                          onPressed: () =>
                              context.read<LocaleService>().toggleLanguage(),
                          icon: const Icon(Icons.translate_rounded,
                              size: 18, color: AppColors.primary),
                          label: Text(
                            isArabic ? 'English' : 'العربية',
                            style: GoogleFonts.cairo(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // App Branding
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [AppColors.primary, AppColors.accent],
                    ).createShader(bounds),
                    child: Text(
                      s.appName,
                      style: GoogleFonts.amiri(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Register Card
                  Form(
                    key: _formKey,
                    child: AppTheme.buildGlassContainer(
                      context: context,
                      opacity: isDark ? 0.15 : 0.6,
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: isArabic
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.register,
                            style: GoogleFonts.cairo(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            s.registerSubtitle,
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.5),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Name Field
                          AuthTextField(
                            controller: _nameCtrl,
                            label: s.name,
                            icon: Icons.person_outline_rounded,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return s.enterName;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Email Field
                          AuthTextField(
                            controller: _emailCtrl,
                            label: s.email,
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return s.enterEmail;
                              }
                              if (!v.contains('@')) return s.invalidEmail;
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Password Field
                          AuthTextField(
                            controller: _passwordCtrl,
                            label: s.password,
                            icon: Icons.lock_outline_rounded,
                            obscureText: _obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                size: 20,
                                color: AppColors.primary.withOpacity(0.6),
                              ),
                              onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return s.enterPassword;
                              }
                              if (v.length < 6) return s.passwordTooShort;
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Confirm Password Field
                          AuthTextField(
                            controller: _confirmPasswordCtrl,
                            label: s.confirmPassword,
                            icon: Icons.lock_reset_rounded,
                            obscureText: _obscureConfirmPassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                size: 20,
                                color: AppColors.primary.withOpacity(0.6),
                              ),
                              onPressed: () => setState(() =>
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return s.enterConfirmPassword;
                              }
                              if (v != _passwordCtrl.text) {
                                return s.passwordNotMatch;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),

                          // Register Button
                          Consumer<AuthService>(
                            builder: (_, auth, __) => AppTheme.buildGlassButton(
                              onPressed: auth.isLoading ? () {} : _register,
                              label: s.register,
                              isLoading: auth.isLoading,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Social Login
                          const SocialLoginButtons(),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        s.haveAccount,
                        style: GoogleFonts.cairo(
                            color:
                                theme.colorScheme.onSurface.withOpacity(0.6)),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text(
                          s.signIn,
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
