// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

/// What's included list for service details.
class ServiceIncludesList extends StatelessWidget {
  final bool isArabic;

  const ServiceIncludesList({super.key, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = _includedItems(isArabic);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Row(
          children: [
            Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              isArabic ? 'ما يشمله الحجز' : "What's Included",
              style: GoogleFonts.cairo(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ...items.map(
          (item) => _IncludedTile(
            icon: item.$1,
            label: item.$2,
            isArabic: isArabic,
          ),
        ),
      ],
    );
  }

  List<(IconData, String)> _includedItems(bool isArabic) => [
        (
          Icons.person_outline_rounded,
          isArabic ? 'متخصصة معتمدة ومدربة' : 'Certified specialist'
        ),
        (
          Icons.local_florist_outlined,
          isArabic ? 'منتجات عضوية فاخرة' : 'Premium organic products'
        ),
        (
          Icons.home_work_outlined,
          isArabic ? 'خدمة في منزلك أو بالمركز' : 'At-home or in-center service'
        ),
        (
          Icons.cleaning_services_outlined,
          isArabic ? 'تعقيم كامل للأدوات' : 'Fully sterilized tools'
        ),
      ];
}

class _IncludedTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isArabic;

  const _IncludedTile({
    required this.icon,
    required this.label,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withOpacity(0.85),
              ),
            ),
          ),
          Icon(
            Icons.check_circle_rounded,
            size: 18,
            color: AppColors.success,
          ),
        ],
      ),
    );
  }
}
