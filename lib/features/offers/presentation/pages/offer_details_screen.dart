// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/smart_image.dart';
import '../../../../models/service_model.dart';
import '../../../bookings/presentation/pages/booking_screen.dart';

/// Details screen shown when a slider/promo banner is tapped.
/// Displays offer info and allows booking the linked service.
class OfferDetailsScreen extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String subtitle;
  final String serviceId;
  final String type;
  final Map<String, dynamic> data;

  const OfferDetailsScreen({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.subtitle,
    required this.serviceId,
    required this.type,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final description = (data['description'] ?? '').toString().trim();
    final discount = (data['discount'] ?? '').toString().trim();
    final validUntil = (data['validUntil'] ?? '').toString().trim();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Scrollable content
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Hero Image
              SliverToBoxAdapter(
                child: _buildHeroImage(context, theme, discount),
              ),

              // Content
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 140),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Type badge
                    if (type.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(children: [_buildTypeBadge(type)]),
                      ),

                    // Title
                    Text(
                      title,
                      style: GoogleFonts.cairo(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.onSurface,
                        height: 1.3,
                      ),
                    ),

                    // Subtitle
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        style: GoogleFonts.cairo(
                          fontSize: 15,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),

                    // Discount card
                    if (discount.isNotEmpty) ...[
                      _buildDiscountCard(discount, isDark, theme),
                      const SizedBox(height: 20),
                    ],

                    // Description
                    if (description.isNotEmpty) ...[
                      _buildDescriptionCard(description, isDark, theme),
                      const SizedBox(height: 20),
                    ],

                    // Valid until
                    if (validUntil.isNotEmpty) ...[
                      _buildValidityBadge(validUntil, isDark),
                    ],
                  ]),
                ),
              ),
            ],
          ),

          // Fixed bottom CTA button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomCTA(context, theme, isDark),
          ),

          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            child: _buildCircleButton(
              icon: Icons.arrow_back_ios_rounded,
              onTap: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Hero Image ──────────────────────────────────────────────────────────

  Widget _buildHeroImage(
      BuildContext context, ThemeData theme, String discount) {
    return Stack(
      children: [
        SizedBox(
          height: 320,
          width: double.infinity,
          child: SmartImage(imageData: imageUrl, fit: BoxFit.cover),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.transparent,
                  theme.scaffoldBackgroundColor.withOpacity(0.5),
                  theme.scaffoldBackgroundColor,
                ],
                stops: const [0.0, 0.35, 0.75, 1.0],
              ),
            ),
          ),
        ),
        if (discount.isNotEmpty)
          Positioned(
            bottom: 24,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.error.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                discount,
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ─── Bottom CTA ─────────────────────────────────────────────────────────

  Widget _buildBottomCTA(BuildContext context, ThemeData theme, bool isDark) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withOpacity(0.95),
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.black.withOpacity(0.04),
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () => _navigateToBooking(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            shadowColor: AppColors.primary.withOpacity(0.3),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.spa_rounded, size: 20),
              const SizedBox(width: 10),
              Text(
                'استخدمي العرض',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Navigation ─────────────────────────────────────────────────────────

  Future<void> _navigateToBooking(BuildContext context) async {
    if (serviceId.isNotEmpty) {
      // Fetch the service from Firestore and navigate to booking
      try {
        final doc = await FirebaseFirestore.instance
            .collection('services')
            .doc(serviceId)
            .get();

        if (doc.exists && context.mounted) {
          final service = ServiceModel.fromFirestore(doc);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BookingScreen(
                service: service,
                therapist: '',
                serviceName: service.name,
              ),
            ),
          );
        } else if (context.mounted) {
          // Service not found — go back to home
          Navigator.pop(context);
        }
      } catch (_) {
        if (context.mounted) Navigator.pop(context);
      }
    } else {
      // No service linked — just go back
      Navigator.pop(context);
    }
  }

  // ─── Helper Widgets ─────────────────────────────────────────────────────

  Widget _buildCircleButton(
      {required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _buildTypeBadge(String type) {
    final config = _getTypeConfig(type);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: config.color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: 14, color: config.color),
          const SizedBox(width: 6),
          Text(
            config.label,
            style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: config.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountCard(String discount, bool isDark, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(isDark ? 0.15 : 0.08),
            AppColors.accent.withOpacity(isDark ? 0.1 : 0.05),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(isDark ? 0.2 : 0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.local_offer_rounded,
                color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'خصم خاص',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  discount,
                  style: GoogleFonts.cairo(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(
      String description, bool isDark, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.06) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : AppColors.border.withOpacity(0.3),
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.info_outline_rounded,
                    color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                'تفاصيل العرض',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            description,
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              height: 1.8,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValidityBadge(String validUntil, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.gold.withOpacity(isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.timer_outlined,
                color: AppColors.gold, size: 18),
          ),
          const SizedBox(width: 12),
          Text(
            'صالح حتى: $validUntil',
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.gold,
            ),
          ),
        ],
      ),
    );
  }

  _TypeConfig _getTypeConfig(String type) {
    switch (type) {
      case 'service':
        return _TypeConfig(
          label: 'خدمة',
          icon: Icons.spa_rounded,
          color: const Color(0xFF4ECDC4),
        );
      case 'link':
        return _TypeConfig(
          label: 'رابط',
          icon: Icons.link_rounded,
          color: const Color(0xFF6366F1),
        );
      default:
        return _TypeConfig(
          label: 'عرض',
          icon: Icons.local_offer_rounded,
          color: AppColors.primary,
        );
    }
  }
}

class _TypeConfig {
  final String label;
  final IconData icon;
  final Color color;

  const _TypeConfig({
    required this.label,
    required this.icon,
    required this.color,
  });
}
