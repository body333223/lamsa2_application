// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

/// A card that shows the selected address or prompts to add one.
class BookingAddressCard extends StatelessWidget {
  final String? address;
  final VoidCallback onTap;
  final bool isArabic;
  final bool isDark;

  const BookingAddressCard({
    super.key,
    required this.address,
    required this.onTap,
    required this.isArabic,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final hasAddress = address != null && address!.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: hasAddress
              ? AppColors.primary.withOpacity(0.08)
              : (isDark ? Colors.white.withOpacity(0.05) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hasAddress
                ? AppColors.primary.withOpacity(0.3)
                : (isDark ? Colors.white.withOpacity(0.1) : AppColors.border),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.15 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(hasAddress ? 0.15 : 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                hasAddress
                    ? Icons.check_circle_rounded
                    : Icons.add_location_alt_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasAddress
                        ? (isArabic ? 'العنوان المحدد' : 'Selected Address')
                        : (isArabic
                            ? 'أضيفي عنوان المنزل'
                            : 'Add Home Address'),
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: hasAddress
                          ? AppColors.primary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  if (hasAddress) ...[
                    const SizedBox(height: 4),
                    Text(
                      address!,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ] else
                    Text(
                      isArabic
                          ? 'اضغطي لتحديد موقعك'
                          : 'Tap to set your location',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.4),
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }
}
