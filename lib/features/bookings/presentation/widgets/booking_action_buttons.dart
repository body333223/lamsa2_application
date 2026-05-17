// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_snackbar.dart';
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
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        if (widget.canCancel) ...[
          // Postpone button
          _ActionButton(
            label: 'تقديم طلب تأجيل',
            icon: Icons.schedule_rounded,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            onPressed: _isLoading
                ? null
                : () => _handleSupportRequest(s, 'postpone', theme),
          ),
          const SizedBox(height: 12),

          // Cancel button
          _ActionButton(
            label: s.cancelBooking,
            icon: Icons.cancel_outlined,
            backgroundColor: isDark
                ? AppColors.error.withOpacity(0.15)
                : AppColors.error.withOpacity(0.08),
            foregroundColor: AppColors.error,
            borderColor: AppColors.error.withOpacity(0.3),
            onPressed: _isLoading
                ? null
                : () => _handleSupportRequest(s, 'cancel', theme),
          ),
          const SizedBox(height: 12),
        ],

        // Contact support button
        _ActionButton(
          label: s.contactSupport,
          icon: Icons.chat_bubble_outline_rounded,
          backgroundColor: isDark
              ? Colors.white.withOpacity(0.06)
              : Colors.black.withOpacity(0.04),
          foregroundColor: theme.colorScheme.onSurface.withOpacity(0.8),
          borderColor: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.08),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const SupportChatScreen(userId: ''),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleSupportRequest(
      AppStrings s, String type, ThemeData theme) async {
    final isArabic = s.isArabic;
    final actionColor = type == 'cancel' ? AppColors.error : AppColors.primary;

    final authService = context.read<AuthService>();
    final firestoreService = context.read<FirestoreService>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final isDark = theme.brightness == Brightness.dark;
        return Dialog(
          backgroundColor: isDark ? const Color(0xFF1E1C20) : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
      setState(() => _isLoading = true);
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
          AppSnackbar.show(context,
              message: 'تم إرسال الطلب لخدمة العملاء', type: SnackType.success);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SupportChatScreen(userId: userId),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          AppSnackbar.show(context,
              message: s.errorOccurred, type: SnackType.error);
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }
}

/// Clean, modern action button widget.
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    this.borderColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: borderColor != null
                  ? Border.all(color: borderColor!, width: 1.5)
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: foregroundColor, size: 20),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: foregroundColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
