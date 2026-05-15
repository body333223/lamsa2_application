// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../models/booking_model.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/firestore_service.dart';
import '../../../support/presentation/pages/support_chat_screen.dart';

/// Action buttons for booking details (postpone, cancel, contact support).
class BookingActionButtons extends StatefulWidget {
  final BookingModel booking;
  final bool canCancel;

  const BookingActionButtons({
    super.key,
    required this.booking,
    required this.canCancel,
  });

  @override
  State<BookingActionButtons> createState() => _BookingActionButtonsState();
}

class _BookingActionButtonsState extends State<BookingActionButtons> {
  @override
  Widget build(BuildContext context) {
    final s = AppStrings(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        if (widget.canCancel) ...[
          AppTheme.buildGlassButton(
            onPressed: () => _handleSupportRequest(s, 'postpone', theme),
            label: 'تقديم طلب تأجيل',
            gradientStart: AppColors.primary,
            gradientEnd: AppColors.primaryLight,
          ),
          const SizedBox(height: 16),
          AppTheme.buildGlassButton(
            onPressed: () => _handleSupportRequest(s, 'cancel', theme),
            label: s.cancelBooking,
            gradientStart: const Color(0xFFC04E4A),
            gradientEnd: const Color(0xFFE57373),
          ),
          const SizedBox(height: 16),
        ],
        AppTheme.buildGlassButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const SupportChatScreen(userId: ''),
            ),
          ),
          label: s.contactSupport,
          gradientStart: isDark ? Colors.white24 : Colors.black87,
          gradientEnd: isDark ? Colors.white10 : Colors.black54,
        ),
      ],
    );
  }

  Future<void> _handleSupportRequest(
      AppStrings s, String type, ThemeData theme) async {
    final isArabic = s.isArabic;
    final actionColor = type == 'cancel' ? AppColors.error : AppColors.primary;

    // Capture services before dialog
    final authService = context.read<AuthService>();
    final firestoreService = context.read<FirestoreService>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final isDark = theme.brightness == Brightness.dark;
        return Dialog(
          backgroundColor: isDark ? const Color(0xFF1E1C20) : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: actionColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    type == 'cancel'
                        ? Icons.cancel_outlined
                        : Icons.schedule_rounded,
                    color: actionColor,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  type == 'cancel'
                      ? s.confirmCancelTitle
                      : (isArabic ? 'تأكيد التأجيل' : 'Confirm Postpone'),
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  type == 'cancel'
                      ? (isArabic
                          ? 'متأكدة تبين تلغين الحجز؟'
                          : 'Are you sure you want to cancel?')
                      : (isArabic
                          ? 'متأكدة تبين تأجلين الحجز؟'
                          : 'Are you sure you want to postpone?'),
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: actionColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(s.yes,
                        style: GoogleFonts.cairo(
                            fontSize: 16, fontWeight: FontWeight.w800)),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: Text(s.no,
                        style: GoogleFonts.cairo(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        )),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed == true && mounted) {
      try {
        final userId = authService.currentUser?.uid ?? '';
        if (userId.isEmpty) return;

        final message = type == 'cancel'
            ? 'مرحبا، أبي ألغي الحجز رقم ${widget.booking.id.substring(0, 8).toUpperCase()} لخدمة ${widget.booking.serviceName}.'
            : 'مرحبا، أبي أأجل الحجز رقم ${widget.booking.id.substring(0, 8).toUpperCase()} لخدمة ${widget.booking.serviceName}.';

        if (type == 'cancel') {
          await firestoreService.requestCancelBooking(widget.booking.id);
        }

        await firestoreService.createSupportRequest(
          userId: userId,
          bookingId: widget.booking.id,
          message: message,
        );

        final userData = await authService.getUserData();
        final userName = userData?['name'];

        await firestoreService.sendMessage(
          userId: userId,
          text: message,
          isAdmin: false,
          userName: userName,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم إرسال الطلب لخدمة العملاء',
                  style: GoogleFonts.cairo()),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SupportChatScreen(userId: userId),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(s.errorOccurred, style: GoogleFonts.cairo()),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        }
      }
    }
  }
}
