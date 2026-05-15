// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../models/service_model.dart';

/// Name, rating, duration, description section for service details.
class ServiceInfoSection extends StatelessWidget {
  final ServiceModel service;
  final bool isArabic;

  const ServiceInfoSection({
    super.key,
    required this.service,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category badge
        _CategoryBadge(label: service.category),
        const SizedBox(height: 14),
        // Name
        Text(
          service.name,
          style: GoogleFonts.cairo(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.onSurface,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 16),
        // Info chips row
        Wrap(
          spacing: 10,
          runSpacing: 10,
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          children: [
            _InfoChip(
              icon: Icons.star_rounded,
              iconColor: AppColors.gold,
              label: service.rating.toStringAsFixed(1),
              sublabel: isArabic
                  ? '(${service.reviewCount} تقييم)'
                  : '(${service.reviewCount})',
            ),
            _InfoChip(
              icon: Icons.access_time_rounded,
              iconColor: AppColors.primary,
              label: '${service.durationMinutes}',
              sublabel: isArabic ? 'دقيقة' : 'min',
            ),
            _InfoChip(
              icon: Icons.verified_rounded,
              iconColor: AppColors.success,
              label: isArabic ? 'معتمدة' : 'Verified',
            ),
          ],
        ),
        const SizedBox(height: 28),
        // Description
        _SectionTitle(title: isArabic ? 'عن الخدمة' : 'About'),
        const SizedBox(height: 10),
        Text(
          service.description.isEmpty
              ? (isArabic
                  ? 'خدمة مميزة مقدمة بأعلى معايير الجودة والاحترافية لتمنحكِ تجربة استرخاء لا تُنسى.'
                  : 'A premium service delivered with the highest standards of quality and professionalism for an unforgettable experience.')
              : service.description,
          style: GoogleFonts.cairo(
            fontSize: 14,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
            height: 1.8,
          ),
        ),
      ],
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final String label;
  const _CategoryBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withOpacity(0.25)),
      ),
      child: Text(
        label,
        style: GoogleFonts.cairo(
          fontSize: 12,
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
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
          title,
          style: GoogleFonts.cairo(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String? sublabel;

  const _InfoChip({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.sublabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: iconColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          if (sublabel != null) ...[
            const SizedBox(width: 3),
            Text(
              sublabel!,
              style: GoogleFonts.cairo(
                fontSize: 11,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
