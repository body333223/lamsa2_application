// ignore_for_file: deprecated_member_use, unused_element, use_build_context_synchronously

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glow_orb.dart';
import '../../../../core/widgets/smart_image.dart';
import '../../../../models/booking_model.dart';
import '../widgets/booking_detail_card.dart';
import '../widgets/booking_status_badge.dart';
import '../widgets/booking_action_buttons.dart';

class BookingDetailsScreen extends StatelessWidget {
  final BookingModel booking;
  const BookingDetailsScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(context);
    final statusInfo = _statusInfo(booking.status, s);
    final canCancel = booking.status == 'pending' ||
        booking.status == 'confirmed' ||
        booking.status == 'pending_payment';

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          s.bookingDetails,
          style: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 20),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 100,
            right: -50,
            child:
                GlowOrb(size: 200, color: AppColors.primary.withOpacity(0.15)),
          ),
          Positioned(
            bottom: 100,
            left: -50,
            child: GlowOrb(size: 150, color: AppColors.accent.withOpacity(0.1)),
          ),
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
                24, MediaQuery.of(context).padding.top + 70, 24, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service Image Header Card
                AppTheme.buildGlassContainer(
                  context: context,
                  padding: EdgeInsets.zero,
                  opacity: 0.1,
                  borderRadius: BorderRadius.circular(32),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(32)),
                        child: SmartImage(
                          imageData: booking.serviceImageUrl,
                          width: double.infinity,
                          height: 220,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    booking.serviceName,
                                    style: GoogleFonts.cairo(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                                BookingStatusBadge(
                                  label: statusInfo['label']!,
                                  color: Color(int.parse(statusInfo['color']!)),
                                  bg: Color(int.parse(statusInfo['bg']!)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${s.bookingNumber} #${booking.id.length >= 8 ? booking.id.substring(0, 8).toUpperCase() : booking.id}',
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.5),
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Details Glass Card
                AppTheme.buildGlassContainer(
                  context: context,
                  opacity: isDark ? 0.2 : 0.6,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      BookingDetailRow(
                        icon: Icons.calendar_today_rounded,
                        label: s.date,
                        value:
                            '${booking.dateTime.day}/${booking.dateTime.month}/${booking.dateTime.year}',
                      ),
                      _divider(context),
                      BookingDetailRow(
                        icon: Icons.access_time_rounded,
                        label: s.time,
                        value:
                            '${booking.dateTime.hour.toString().padLeft(2, '0')}:${booking.dateTime.minute.toString().padLeft(2, '0')}',
                      ),
                      _divider(context),
                      BookingDetailRow(
                        icon: booking.location == 'المنزل'
                            ? Icons.home_rounded
                            : Icons.storefront_rounded,
                        label: s.location,
                        value: booking.location,
                      ),
                      _divider(context),
                      BookingDetailRow(
                        icon: Icons.payments_rounded,
                        label: s.price,
                        value: '${booking.price.toInt()} ${s.egp}',
                        isPrice: true,
                      ),
                      if (booking.notes != null &&
                          booking.notes!.isNotEmpty) ...[
                        _divider(context),
                        BookingDetailRow(
                          icon: Icons.notes_rounded,
                          label: s.notes,
                          value: booking.notes!,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                BookingActionButtons(
                  booking: booking,
                  canCancel: canCancel,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Divider(
            height: 1,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05)),
      );

  Map<String, String> _statusInfo(String status, AppStrings s) {
    switch (status) {
      case 'confirmed':
        return {
          'label': s.statusConfirmed,
          'color': '0xFF10B981',
          'bg': '0xFFD1FAE5',
        };
      case 'completed':
        return {
          'label': s.statusCompleted,
          'color': '0xFF6366F1',
          'bg': '0xFFE0E7FF',
        };
      case 'cancelled':
        return {
          'label': s.statusCancelled,
          'color': '0xFFEF4444',
          'bg': '0xFFFEE2E2',
        };
      default:
        return {
          'label': s.statusPending,
          'color': '0xFFF59E0B',
          'bg': '0xFFFEF3C7',
        };
    }
  }
}
