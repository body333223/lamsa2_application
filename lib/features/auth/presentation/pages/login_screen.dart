// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/locale_service.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/glow_orb.dart';
import '../widgets/auth_header.dart';
import '../widgets/country_code_picker.dart';
import 'otp_verification_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  CountryCode _selectedCountry = countryCodes.first; // Saudi Arabia

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthService>();
    final isArabic = context.read<LocaleService>().isArabic;
    String phone = _phoneCtrl.text.trim();

    // Remove leading zero if present
    if (phone.startsWith('0')) {
      phone = phone.substring(1);
    }

    // Combine country code + phone number
    final fullPhone = '${_selectedCountry.dialCode}$phone';

    await auth.sendOtp(
      phoneNumber: fullPhone,
      onCodeSent: (code) {
        if (!mounted) return;
        if (code != null && code.isNotEmpty) {
          AppSnackbar.show(
            context,
            message: isArabic
                ? 'رمز التحقق الخاص بك هو: [ $code ]'
                : 'Your verification code is: [ $code ]',
            type: SnackType.success,
          );
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpVerificationScreen(
              phoneNumber: fullPhone,
            ),
          ),
        );
      },
      onError: (error) {
        if (!mounted) return;
        AppSnackbar.show(context, message: error, type: SnackType.error);
      },
    );
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
                              s.phoneRegisterSubtitle,
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.5),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Phone Number Field with Country Code Picker
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Country Code Picker
                                  CountryCodePicker(
                                    selectedCountry: _selectedCountry,
                                    isArabic: isArabic,
                                    onChanged: (country) {
                                      setState(() {
                                        _selectedCountry = country;
                                      });
                                    },
                                  ),
                                  const SizedBox(width: 10),

                                  // Phone Number Input
                                  Expanded(
                                    child: TextFormField(
                                      controller: _phoneCtrl,
                                      keyboardType: TextInputType.phone,
                                      textDirection: TextDirection.ltr,
                                      style: GoogleFonts.cairo(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      decoration: InputDecoration(
                                        labelText: s.phoneNumber,
                                        labelStyle: GoogleFonts.cairo(
                                          fontSize: 14,
                                          color: isDark
                                              ? Colors.white38
                                              : AppColors.textLight,
                                        ),
                                        hintText: '5XXXXXXXX',
                                        hintStyle: GoogleFonts.cairo(
                                          color: theme.colorScheme.onSurface
                                              .withOpacity(0.3),
                                        ),
                                        filled: true,
                                        fillColor: (isDark
                                                ? Colors.white
                                                : Colors.black)
                                            .withOpacity(0.05),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          borderSide: BorderSide.none,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          borderSide: BorderSide.none,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          borderSide: BorderSide(
                                            color: AppColors.primary
                                                .withOpacity(0.5),
                                            width: 1.5,
                                          ),
                                        ),
                                        errorStyle:
                                            GoogleFonts.cairo(fontSize: 11),
                                      ),
                                      validator: (v) {
                                        if (v == null || v.trim().isEmpty) {
                                          return s.enterPhoneNumber;
                                        }
                                        final cleaned = v.replaceAll(
                                            RegExp(r'[\s\-\(\)]'), '');
                                        if (cleaned.length < 7) {
                                          return s.invalidPhoneNumber;
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Send OTP Button
                            Consumer<AuthService>(
                              builder: (_, auth, __) =>
                                  AppTheme.buildGlassButton(
                                onPressed: auth.isLoading ? () {} : _sendOtp,
                                label: s.sendOtp,
                                isLoading: auth.isLoading,
                              ),
                            ),
                          ],
                        ),
                      ),
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
