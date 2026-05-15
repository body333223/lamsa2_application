// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/locale_service.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glow_orb.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/country_code_picker.dart';
import 'otp_verification_screen.dart';

class PhoneRegisterScreen extends StatefulWidget {
  const PhoneRegisterScreen({super.key});

  @override
  State<PhoneRegisterScreen> createState() => _PhoneRegisterScreenState();
}

class _PhoneRegisterScreenState extends State<PhoneRegisterScreen> {
  final _phoneCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  CountryCode _selectedCountry = countryCodes.first; // Saudi Arabia

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthService>();
    String phone = _phoneCtrl.text.trim();

    // Remove leading zero if present
    if (phone.startsWith('0')) {
      phone = phone.substring(1);
    }

    // Combine country code + phone number
    final fullPhone = '${_selectedCountry.dialCode}$phone';

    await auth.verifyPhoneNumber(
      phoneNumber: fullPhone,
      onCodeSent: (verificationId) {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpVerificationScreen(
              phoneNumber: fullPhone,
              name: _nameCtrl.text.trim(),
            ),
          ),
        );
      },
      onError: (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error, style: GoogleFonts.cairo()),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
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
                            s.phoneRegisterSubtitle,
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
                                      fillColor:
                                          (isDark ? Colors.white : Colors.black)
                                              .withOpacity(0.05),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
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
                            builder: (_, auth, __) => AppTheme.buildGlassButton(
                              onPressed: auth.isLoading ? () {} : _sendOtp,
                              label: s.sendOtp,
                              isLoading: auth.isLoading,
                            ),
                          ),
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
