// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_theme.dart';

class ProfileStatsRow extends StatelessWidget {
  final int bookings;
  final int favorites;

  const ProfileStatsRow({
    super.key,
    required this.bookings,
    required this.favorites,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: AppTheme.buildGlassContainer(
        context: context,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        opacity: isDark ? 0.15 : 0.5,
        borderRadius: BorderRadius.circular(24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _StatItem(count: bookings, label: s.bookingsCount),
            Container(
              width: 1,
              height: 40,
              color: theme.colorScheme.onSurface.withOpacity(0.1),
            ),
            _StatItem(count: favorites, label: s.favorites),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final int count;
  final String label;

  const _StatItem({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          '$count',
          style: GoogleFonts.cairo(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}
