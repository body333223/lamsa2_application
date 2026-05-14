// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/smart_image.dart';
import '../../../../models/booking_model.dart';
import '../pages/booking_details_screen.dart';

/// A card displaying a single booking in the bookings list.
class BookingCard extends StatelessWidget {
  final BookingModel booking;
  final bool isArabic;

  const BookingCard({
    super.key,
    required this.booking,
    required this.isArabic,
  });

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'مؤكد':
        return AppColors.success;
      case 'pending':
      case 'قيد الانتظار':
        return AppColors.gold;
      case 'cancelled':
      case 'ملغي':
        return AppColors.error;
      default:
        return AppColors.textMedium;
    }
  }

  String _statusLabel(String status, bool isArabic) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return isArabic ? 'مؤكد' : 'Confirmed';
      case 'pending':
        return isArabic ? 'قيد الانتظار' : 'Pending';
      case 'cancelled':
        return isArabic ? 'ملغي' : 'Cancelled';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = booking.dateTime;
    final dateStr = '${date.day}/${date.month}/${date.year}';
    final timeStr =
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    final statusColor = _statusColor(booking.status);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BookingDetailsScreen(booking: booking),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        child: AppTheme.buildGlassContainer(
          context: context,
          padding: EdgeInsets.zero,
          opacity: isDark ? 0.2 : 0.6,
          blur: 20,
          shadow: BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  textDirection:
                      isArabic ? TextDirection.rtl : TextDirection.ltr,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: SmartImage(
                        imageData: booking.serviceImageUrl,
                        width: 80,
                        height: 80,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: isArabic
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.serviceName,
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.onSurface,
                              letterSpacing: 0.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          if (booking.therapistName.isNotEmpty)
                            Row(
                              textDirection: isArabic
                                  ? TextDirection.rtl
                                  : TextDirection.ltr,
                              children: [
                                Icon(Icons.face_3_rounded,
                                    size: 14,
                                    color: AppColors.primary.withOpacity(0.8)),
                                const SizedBox(width: 6),
                                Text(
                                  booking.therapistName,
                                  style: GoogleFonts.cairo(
                                      fontSize: 13,
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.6)),
                                ),
                              ],
                            ),
                          const SizedBox(height: 6),
                          Row(
                            textDirection: isArabic
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                            children: [
                              Icon(Icons.calendar_today_rounded,
                                  size: 14,
                                  color: AppColors.primary.withOpacity(0.8)),
                              const SizedBox(width: 6),
                              Text(
                                '$dateStr  •  $timeStr',
                                style: GoogleFonts.cairo(
                                    fontSize: 13,
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.6)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: (isDark ? Colors.black : AppColors.primaryLight)
                      .withOpacity(0.2),
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(32)),
                ),
                child: Row(
                  textDirection:
                      isArabic ? TextDirection.rtl : TextDirection.ltr,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${booking.price.toInt()}',
                          style: GoogleFonts.cairo(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            height: 1,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            isArabic ? 'ر.س' : 'SAR',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: statusColor.withOpacity(0.3), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                    color: statusColor.withOpacity(0.5),
                                    blurRadius: 4),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _statusLabel(booking.status, isArabic),
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
