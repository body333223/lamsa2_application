// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/smart_image.dart';

/// Hero image with back/fav buttons for the service details screen.
class ServiceHeroImage extends StatelessWidget {
  final String imageUrl;
  final bool isArabic;
  final bool isDark;
  final bool isFav;
  final bool favLoading;
  final VoidCallback onBack;
  final VoidCallback onToggleFavorite;

  const ServiceHeroImage({
    super.key,
    required this.imageUrl,
    required this.isArabic,
    required this.isDark,
    required this.isFav,
    required this.favLoading,
    required this.onBack,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      stretch: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      leading: _IconButtonCircle(
        icon: isArabic
            ? Icons.arrow_forward_ios_rounded
            : Icons.arrow_back_ios_new_rounded,
        onTap: onBack,
        isDark: isDark,
      ),
      actions: [
        _IconButtonCircle(
          icon: favLoading
              ? Icons.favorite_border_rounded
              : (isFav
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded),
          iconColor: isFav ? Colors.redAccent : null,
          onTap: favLoading ? () {} : onToggleFavorite,
          isDark: isDark,
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            SmartImage(
              imageData: imageUrl,
              fit: BoxFit.cover,
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 180,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      theme.scaffoldBackgroundColor.withOpacity(0.6),
                      theme.scaffoldBackgroundColor,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconButtonCircle extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;
  final Color? iconColor;

  const _IconButtonCircle({
    required this.icon,
    required this.onTap,
    required this.isDark,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(isDark ? 0.15 : 0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 18,
            color: iconColor ?? (isDark ? Colors.white : AppColors.textDark),
          ),
        ),
      ),
    );
  }
}
