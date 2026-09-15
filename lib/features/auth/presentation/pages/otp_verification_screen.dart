// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/locale_service.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/glow_orb.dart';
import '../../../home/presentation/pages/home_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String? name;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    this.name,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  Timer? _timer;
  int _countdown = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    setState(() {
      _countdown = 60;
      _canResend = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown <= 1) {
        timer.cancel();
        setState(() {
          _canResend = true;
          _countdown = 0;
        });
      } else {
        setState(() => _countdown--);
      }
    });
  }

  String get _otpCode => _otpControllers.map((c) => c.text).join();

  void _autoFillOtp() {
    const code = '123456';
    for (int i = 0; i < 6; i++) {
      _otpControllers[i].text = code[i];
    }
    _verifyOtp();
  }

  Future<void> _verifyOtp() async {
    final otp = _otpCode;
    if (otp.length != 6) {
      final isArabic = context.read<LocaleService>().isArabic;
      AppSnackbar.show(
        context,
        message: isArabic ? 'يرجى إدخال رمز التحقق المكون من 6 أرقام' : 'Please enter the 6-digit code',
        type: SnackType.warning,
      );
      return;
    }

    final auth = context.read<AuthService>();
    try {
      await auth.verifyOtpAndSignIn(
        phone: widget.phoneNumber,
        otp: otp,
        name: widget.name,
      );
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.show(context, message: e.toString(), type: SnackType.error);
    }
  }

  Future<void> _resendOtp() async {
    if (!_canResend) return;

    final auth = context.read<AuthService>();
    await auth.sendOtp(
      phoneNumber: widget.phoneNumber,
      onCodeSent: () {
        _startCountdown();
        if (!mounted) return;
        final isArabic = context.read<LocaleService>().isArabic;
        AppSnackbar.show(context,
            message: isArabic ? 'تم إعادة إرسال الرمز' : 'Code resent',
            type: SnackType.success);
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
            top: -80,
            right: -80,
            child:
                GlowOrb(size: 280, color: AppColors.primary.withOpacity(0.15)),
          ),
          Positioned(
            bottom: -60,
            left: -60,
            child:
                GlowOrb(size: 220, color: AppColors.accent.withOpacity(0.12)),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Back Button
                  Align(
                    alignment:
                        isArabic ? Alignment.centerRight : Alignment.centerLeft,
                    child: AppTheme.buildGlassContainer(
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
                  ),
                  const SizedBox(height: 30),

                  // OTP Icon
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.2),
                          AppColors.accent.withOpacity(0.1),
                        ],
                      ),
                    ),
                    child: Icon(
                      Icons.sms_outlined,
                      size: 42,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    s.otpVerification,
                    style: GoogleFonts.cairo(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Subtitle with phone number
                  Text(
                    '${s.otpSentTo}\n${widget.phoneNumber}',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Helper Badge for Mock OTP
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.25),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.info_outline, size: 18, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          isArabic ? 'رمز التحقق الافتراضي: 123456' : 'Default OTP: 123456',
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // OTP Input Fields
                  AppTheme.buildGlassContainer(
                    context: context,
                    opacity: isDark ? 0.15 : 0.6,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 28),
                    child: Column(
                      children: [
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(6, (index) {
                              return Flexible(
                                child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 3),
                                  height: 54,
                                  child: TextFormField(
                                    controller: _otpControllers[index],
                                    focusNode: _focusNodes[index],
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    maxLength: 1,
                                    style: GoogleFonts.cairo(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                    decoration: InputDecoration(
                                      counterText: '',
                                      filled: true,
                                      fillColor:
                                          (isDark ? Colors.white : Colors.black)
                                              .withOpacity(0.05),
                                      contentPadding: EdgeInsets.zero,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: BorderSide(
                                          color: AppColors.primary,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    onChanged: (value) {
                                      if (value.isNotEmpty && index < 5) {
                                        _focusNodes[index + 1].requestFocus();
                                      } else if (value.isEmpty && index > 0) {
                                        _focusNodes[index - 1].requestFocus();
                                      }
                                      // Auto-verify when all 6 digits entered
                                      if (_otpCode.length == 6) {
                                        _verifyOtp();
                                      }
                                    },
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Auto-Fill Button
                        TextButton.icon(
                          onPressed: _autoFillOtp,
                          icon: const Icon(Icons.flash_on_rounded, size: 18),
                          label: Text(
                            isArabic ? 'ملء تلقائي للرمز (123456)' : 'Auto-fill Code (123456)',
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Verify Button
                        Consumer<AuthService>(
                          builder: (_, auth, __) => AppTheme.buildGlassButton(
                            onPressed: auth.isLoading ? () {} : _verifyOtp,
                            label: s.verifyOtp,
                            isLoading: auth.isLoading,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Countdown & Resend
                        if (!_canResend)
                          Text(
                            '$_countdown ${s.secondsRemaining}',
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.5),
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        else
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                s.didNotReceiveCode,
                                style: GoogleFonts.cairo(
                                  fontSize: 13,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.5),
                                ),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: _resendOtp,
                                child: Text(
                                  s.resendOtp,
                                  style: GoogleFonts.cairo(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
