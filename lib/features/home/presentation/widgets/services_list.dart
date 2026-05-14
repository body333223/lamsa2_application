// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../models/service_model.dart';
import '../../logic/home_controller.dart';
import 'service_card.dart';

class ServicesList extends StatelessWidget {
  const ServicesList({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final controller = context.read<HomeController>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.services,
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          StreamBuilder<List<ServiceModel>>(
            stream: controller.servicesStream,
            builder: (_, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return _ShimmerGrid(isDark: isDark);
              }
              if (snap.hasError) {
                return _ErrorWidget(isArabic: s.isArabic);
              }
              final services = snap.data ?? [];
              if (services.isEmpty) {
                return _EmptyState(isArabic: s.isArabic);
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: services.length,
                separatorBuilder: (_, __) => const SizedBox(height: 20),
                itemBuilder: (_, index) =>
                    ServiceCard(service: services[index]),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ShimmerGrid extends StatelessWidget {
  final bool isDark;
  const _ShimmerGrid({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (_) => Container(
          margin: const EdgeInsets.only(bottom: 20),
          height: 260,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.04)
                : Colors.grey.withOpacity(0.08),
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final bool isArabic;
  const _ErrorWidget({required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Text(
          isArabic ? 'حدث خطأ في تحميل الخدمات' : 'Error loading services',
          style: GoogleFonts.cairo(color: AppColors.textLight, fontSize: 14),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isArabic;
  const _EmptyState({required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.spa_outlined,
                size: 40, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            isArabic ? 'لا توجد خدمات حالياً' : 'No services available',
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textMedium,
            ),
          ),
        ],
      ),
    );
  }
}
