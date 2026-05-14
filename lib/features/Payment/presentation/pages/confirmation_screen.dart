// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lamsa/features/Payment/presentation/widgets/confirmation_detail_row.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../home/presentation/pages/home_screen.dart';


class ConfirmationScreen extends StatelessWidget {
  final String bookingId;
  final String serviceName;
  final String date;
  final String time;
  final double price;

  const ConfirmationScreen({
    super.key,
    required this.bookingId,
    required this.serviceName,
    required this.date,
    required this.time,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final shortId = bookingId.length >= 8
        ? bookingId.substring(0, 8).toUpperCase()
        : bookingId.toUpperCase();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Success icon
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 800),
                curve: Curves.elasticOut,
                builder: (_, v, child) =>
                    Transform.scale(scale: v, child: child),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.success,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.success.withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.check_rounded,
                      color: Colors.white, size: 60),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                s.bookingSuccess,
                style: GoogleFonts.cairo(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                s.waitingAtLamsa,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Booking ID badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Text(
                  '${s.bookingNumber} #$shortId',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 36),
              // Details card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.06) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : AppColors.border,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.15 : 0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ConfirmationDetailRow(
                      icon: Icons.spa_rounded,
                      label: s.service,
                      value: serviceName,
                    ),
                    _divider(isDark),
                    ConfirmationDetailRow(
                      icon: Icons.calendar_month_rounded,
                      label: s.date,
                      value: date,
                    ),
                    _divider(isDark),
                    ConfirmationDetailRow(
                      icon: Icons.access_time_rounded,
                      label: s.time,
                      value: time,
                    ),
                    _divider(isDark),
                    ConfirmationDetailRow(
                      icon: Icons.payments_rounded,
                      label: s.total,
                      value: '${price.toInt()} ${s.egp}',
                      isPrice: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                s.bookingNotificationHint,
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Back to home button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (_) => false,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    s.backToHome,
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {},
                child: Text(
                  s.shareBooking,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider(bool isDark) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Divider(
          height: 1,
          color: isDark ? Colors.white.withOpacity(0.08) : AppColors.border,
        ),
      );
}
