// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

/// Empty state widget shown when there are no bookings.
class EmptyBookings extends StatelessWidget {
  final bool isArabic;

  const EmptyBookings({
    super.key,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: const Icon(Icons.calendar_month_rounded,
                size: 50, color: AppColors.primary),
          ),
          const SizedBox(height: 30),
          Text(
            isArabic ? 'لا توجد حجوزات بعد' : 'No bookings yet',
            style: GoogleFonts.cairo(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isArabic
                ? 'استكشفي خدماتنا الفاخرة واحجزي الآن'
                : 'Explore our luxury services and book now',
            style: GoogleFonts.cairo(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.6)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
