// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Social login buttons section (phone OTP only — Google/Apple removed since Firebase Auth is gone).
/// Kept as a widget for future OAuth integration if needed.
class SocialLoginButtons extends StatelessWidget {
  const SocialLoginButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Info text
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
        const SizedBox(height: 16),
        Text(
          'سجلي دخولك برقم هاتفك المحمول',
          style: GoogleFonts.cairo(
            fontSize: 13,
            color: theme.colorScheme.onSurface.withOpacity(0.4),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
