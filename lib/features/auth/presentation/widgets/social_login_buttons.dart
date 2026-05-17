// ignore_for_file: deprecated_member_use

import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../services/auth_service.dart';
import '../../../home/presentation/pages/home_screen.dart';

class SocialLoginButtons extends StatelessWidget {
  const SocialLoginButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        // Divider with "أو"
        Row(
          children: [
            Expanded(
              child: Divider(
                color: theme.colorScheme.onSurface.withOpacity(0.15),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'أو',
                style: GoogleFonts.cairo(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: theme.colorScheme.onSurface.withOpacity(0.15),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Google Sign-In Button
        _SocialButton(
          onPressed: () => _handleGoogleSignIn(context),
          icon: _GoogleIcon(),
          label: 'المتابعة مع Google',
          backgroundColor: isDark ? Colors.white12 : Colors.white,
          textColor: isDark ? Colors.white : AppColors.textDark,
          borderColor: isDark ? Colors.white24 : AppColors.border,
        ),

        // Apple Sign-In Button (iOS only)
        if (Platform.isIOS) ...[
          const SizedBox(height: 12),
          _SocialButton(
            onPressed: () => _handleAppleSignIn(context),
            icon: Icon(
              Icons.apple_rounded,
              size: 24,
              color: isDark ? Colors.white : Colors.black,
            ),
            label: 'المتابعة مع Apple',
            backgroundColor: isDark ? Colors.white12 : Colors.black,
            textColor: isDark ? Colors.white : Colors.white,
            borderColor: isDark ? Colors.white24 : Colors.black,
          ),
        ],
      ],
    );
  }

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    final auth = context.read<AuthService>();
    try {
      await auth.signInWithGoogle();
      if (!context.mounted) return;
      if (auth.isLoggedIn) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      AppSnackbar.show(context, message: e.toString(), type: SnackType.error);
    }
  }

  Future<void> _handleAppleSignIn(BuildContext context) async {
    final auth = context.read<AuthService>();
    try {
      await auth.signInWithApple();
      if (!context.mounted) return;
      if (auth.isLoggedIn) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      AppSnackbar.show(context, message: e.toString(), type: SnackType.error);
    }
  }
}

class _SocialButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget icon;
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;

  const _SocialButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          side: BorderSide(color: borderColor, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Google "G" logo icon
class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Blue
    final bluePaint = Paint()..color = const Color(0xFF4285F4);
    final bluePath = Path()
      ..moveTo(w * 0.96, h * 0.48)
      ..lineTo(w * 0.96, h * 0.44)
      ..lineTo(w * 0.50, h * 0.44)
      ..lineTo(w * 0.50, h * 0.56)
      ..lineTo(w * 0.76, h * 0.56)
      ..cubicTo(w * 0.73, h * 0.68, w * 0.63, h * 0.76, w * 0.50, h * 0.76)
      ..cubicTo(w * 0.35, h * 0.76, w * 0.22, h * 0.64, w * 0.22, h * 0.50)
      ..cubicTo(w * 0.22, h * 0.36, w * 0.35, h * 0.24, w * 0.50, h * 0.24)
      ..cubicTo(w * 0.57, h * 0.24, w * 0.63, h * 0.27, w * 0.68, h * 0.31)
      ..lineTo(w * 0.77, h * 0.22)
      ..cubicTo(w * 0.70, h * 0.16, w * 0.61, h * 0.12, w * 0.50, h * 0.12)
      ..cubicTo(w * 0.28, h * 0.12, w * 0.10, h * 0.29, w * 0.10, h * 0.50)
      ..cubicTo(w * 0.10, h * 0.71, w * 0.28, h * 0.88, w * 0.50, h * 0.88)
      ..cubicTo(w * 0.72, h * 0.88, w * 0.96, h * 0.72, w * 0.96, h * 0.48)
      ..close();
    canvas.drawPath(bluePath, bluePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
