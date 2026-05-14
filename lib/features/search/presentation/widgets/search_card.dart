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

/// A card displaying a single search result.
class SearchCard extends StatelessWidget {
  final ServiceModel service;

  const SearchCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(context);
    final isArabic = context.watch<LocaleService>().isArabic;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => ServiceDetailsScreen(service: service))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: AppTheme.buildGlassContainer(
          context: context,
          padding: const EdgeInsets.all(16),
          opacity: isDark ? 0.2 : 0.6,
          borderRadius: BorderRadius.circular(28),
          child: Row(
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SmartImage(
                  imageData: service.imageUrl,
                  width: 90,
                  height: 90,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: isArabic
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(service.category,
                          style: GoogleFonts.cairo(
                              fontSize: 10,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800)),
                    ),
                    const SizedBox(height: 8),
                    Text(service.name,
                        style: GoogleFonts.cairo(
                            fontSize: 16, fontWeight: FontWeight.w800),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 12),
                    Row(
                      textDirection:
                          isArabic ? TextDirection.rtl : TextDirection.ltr,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text('${service.price.toInt()}',
                                style: GoogleFonts.cairo(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primary)),
                            const SizedBox(width: 4),
                            Text(strings.egp,
                                style: GoogleFonts.cairo(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary.withOpacity(0.7))),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12)),
                          child: Text(isArabic ? 'حجز' : 'Book',
                              style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800)),
                        ),
                      ],
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
