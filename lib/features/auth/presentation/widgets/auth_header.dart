// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../services/locale_service.dart';
import '../../../../services/theme_service.dart';

/// Header section for auth screens containing language/theme toggles and branding.
class AuthHeader extends StatelessWidget {
  final String appName;
  final String subtitle;
  final bool showThemeToggle;

  const AuthHeader({
    super.key,
    required this.appName,
    required this.subtitle,
    this.showThemeToggle = true,
  });

  @override
  Widget build(BuildContext context) {
    final localeService = context.watch<LocaleService>();
    final isArabic = localeService.isArabic;

    return Column(
      children: [
        // Language & Theme Toggles
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (showThemeToggle)
              AppTheme.buildGlassContainer(
                context: context,
                padding: EdgeInsets.zero,
                opacity: 0.1,
                borderRadius: BorderRadius.circular(16),
                child: IconButton(
                  icon: Icon(
                    context.watch<ThemeService>().isDarkMode
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                    color: AppColors.primary,
                  ),
                  onPressed: () => context.read<ThemeService>().toggleTheme(),
                ),
              )
            else
              const SizedBox.shrink(),
            AppTheme.buildGlassContainer(
              context: context,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              opacity: 0.1,
              borderRadius: BorderRadius.circular(16),
              child: TextButton.icon(
                onPressed: () => context.read<LocaleService>().toggleLanguage(),
                icon: const Icon(Icons.translate_rounded,
                    size: 18, color: AppColors.primary),
                label: Text(
                  isArabic ? 'English' : 'العربية',
                  style: GoogleFonts.cairo(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 60),

        // Logo/App Name
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppColors.primary, AppColors.accent],
          ).createShader(bounds),
          child: Text(
            appName,
            style: GoogleFonts.amiri(
              fontSize: 64,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: GoogleFonts.cairo(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            letterSpacing: 2,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
