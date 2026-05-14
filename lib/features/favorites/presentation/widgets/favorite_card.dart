// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/smart_image.dart';
import '../../../../models/service_model.dart';
import '../../../../services/locale_service.dart';
import '../../../services/presentation/pages/service_details_screen.dart';

/// A card displaying a single favorite service.
class FavoriteCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback onRemove;

  const FavoriteCard({
    super.key,
    required this.service,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isArabic = context.watch<LocaleService>().isArabic;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ServiceDetailsScreen(service: service)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: AppTheme.buildGlassContainer(
          context: context,
          padding: const EdgeInsets.all(14),
          opacity: isDark ? 0.25 : 0.7,
          borderRadius: BorderRadius.circular(24),
          child: Row(
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: SmartImage(
                  imageData: service.imageUrl,
                  width: 90,
                  height: 90,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: isArabic
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      textDirection:
                          isArabic ? TextDirection.rtl : TextDirection.ltr,
                      children: [
                        Icon(Icons.access_time_rounded,
                            size: 13, color: AppColors.textLight),
                        const SizedBox(width: 3),
                        Text(
                          '${service.durationMinutes} ${s.minutes}',
                          style: GoogleFonts.cairo(
                              fontSize: 11,
                              color: AppColors.textLight,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.star_rounded,
                            size: 13, color: AppColors.gold),
                        const SizedBox(width: 3),
                        Text(
                          service.rating.toStringAsFixed(1),
                          style: GoogleFonts.cairo(
                              fontSize: 11,
                              color: AppColors.gold,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${service.price.toInt()} ${s.egp}',
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.favorite_rounded,
                    color: Color(0xFFC04E4A), size: 24),
                onPressed: onRemove,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
