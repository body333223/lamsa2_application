// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

class BookingPriceSummary extends StatelessWidget {
  final double price;
  final String currency;
  final String totalLabel;
  final bool isArabic;

  const BookingPriceSummary({
    super.key,
    required this.price,
    required this.currency,
    required this.totalLabel,
    this.isArabic = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _PriceItem(
            label: isArabic ? 'سعر الخدمة' : 'Service Price',
            value: '${price.toInt()} $currency',
          ),
          const SizedBox(height: 12),
          _PriceItem(
            label: isArabic ? 'رسوم التوصيل' : 'Delivery Fee',
            value: isArabic ? 'مجاناً' : 'Free',
            isSuccess: true,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(height: 1, color: Colors.white10),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                totalLabel,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '${price.toInt()} $currency',
                style: GoogleFonts.cairo(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PriceItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isSuccess;

  const _PriceItem({
    required this.label,
    required this.value,
    this.isSuccess = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: isSuccess ? AppColors.success : theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
