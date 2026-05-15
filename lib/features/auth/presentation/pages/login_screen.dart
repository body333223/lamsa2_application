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
import '../widgets/auth_header.dart';
import '../widgets/social_login_buttons.dart';
import 'phone_register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthService>();
    try {
      await auth.loginWithEmailPassword(
        _emailCtrl.text.trim(),
        _passwordCtrl.text.trim(),
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
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
            top: -100,
            right: -100,
            child:
                GlowOrb(size: 300, color: AppColors.primary.withOpacity(0.2)),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child:
                GlowOrb(size: 250, color: AppColors.accent.withOpacity(0.15)),
          ),
          Positioned(
            top: 200,
            left: -100,
            child:
                GlowOrb(size: 200, color: AppColors.primary.withOpacity(0.1)),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Header with toggles and branding
                    AuthHeader(
                      appName: s.appName,
                      subtitle: s.welcome,
                      showThemeToggle: true,
                    ),
                    const SizedBox(height: 50),

                    // Login Card
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
                              s.login,
                              style: GoogleFonts.cairo(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              s.loginSubtitle,
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.5),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 32),

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
                            const SizedBox(height: 20),

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
                            const SizedBox(height: 32),

                            // Login Button
                            Consumer<AuthService>(
                              builder: (_, auth, __) =>
                                  AppTheme.buildGlassButton(
                                onPressed: auth.isLoading ? () {} : _login,
                                label: s.login,
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

                    // Register Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          s.noAccount,
                          style: GoogleFonts.cairo(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.6)),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const PhoneRegisterScreen()),
                          ),
                          child: Text(
                            s.createAccount,
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // Privacy Text
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        s.privacyText,
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          color: theme.colorScheme.onSurface.withOpacity(0.4),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
