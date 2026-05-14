// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A smart image widget that handles both network URLs and base64 encoded images.
/// Falls back to a placeholder on error.
class SmartImage extends StatelessWidget {
  final String imageData;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const SmartImage({
    super.key,
    required this.imageData,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget image;

    if (imageData.isEmpty) {
      image = _buildPlaceholder(isDark);
    } else if (imageData.startsWith('http')) {
      // Network URL
      image = CachedNetworkImage(
        imageUrl: imageData,
        width: width,
        height: height,
        fit: fit,
        placeholder: (_, __) => placeholder ?? _buildLoading(isDark),
        errorWidget: (_, __, ___) => errorWidget ?? _buildPlaceholder(isDark),
      );
    } else {
      // Try base64
      try {
        final Uint8List bytes = base64Decode(imageData);
        image = Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (_, __, ___) => _buildPlaceholder(isDark),
        );
      } catch (_) {
        image = _buildPlaceholder(isDark);
      }
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }

    return image;
  }

  Widget _buildLoading(bool isDark) {
    return Container(
      width: width,
      height: height,
      color: isDark
          ? Colors.white.withOpacity(0.04)
          : AppColors.primaryLight.withOpacity(0.2),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(bool isDark) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryLight.withOpacity(0.4),
            AppColors.primary.withOpacity(0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.spa_rounded, color: AppColors.primary, size: 40),
      ),
    );
  }
}
