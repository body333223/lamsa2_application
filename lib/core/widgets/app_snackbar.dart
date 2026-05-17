// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

enum SnackType { success, error, info, warning }

/// Premium custom SnackBar for the entire app.
/// Usage:
///   AppSnackbar.show(context, message: 'تم الحفظ', type: SnackType.success);
///   AppSnackbar.show(context, message: 'حدث خطأ', type: SnackType.error);
class AppSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    SnackType type = SnackType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final config = _getConfig(type);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(config.icon, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          backgroundColor: config.color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          elevation: 8,
          duration: duration,
          dismissDirection: DismissDirection.horizontal,
        ),
      );
  }

  static _SnackConfig _getConfig(SnackType type) {
    switch (type) {
      case SnackType.success:
        return _SnackConfig(
          color: AppColors.success,
          icon: Icons.check_circle_rounded,
        );
      case SnackType.error:
        return _SnackConfig(
          color: AppColors.error,
          icon: Icons.error_rounded,
        );
      case SnackType.warning:
        return _SnackConfig(
          color: const Color(0xFFF59E0B),
          icon: Icons.warning_rounded,
        );
      case SnackType.info:
        return _SnackConfig(
          color: AppColors.primary,
          icon: Icons.info_rounded,
        );
    }
  }
}

class _SnackConfig {
  final Color color;
  final IconData icon;

  const _SnackConfig({required this.color, required this.icon});
}
