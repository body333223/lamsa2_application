// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/smart_image.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/image_upload_service.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final int bookings;
  final String? photoUrl;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.email,
    required this.bookings,
    this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        MediaQuery.of(context).padding.top + 24,
        24,
        32,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  AppColors.primary.withOpacity(0.12),
                  theme.scaffoldBackgroundColor,
                ]
              : [
                  AppColors.primary.withOpacity(0.08),
                  theme.scaffoldBackgroundColor,
                ],
        ),
      ),
      child: Column(
        children: [
          // Avatar with edit button
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: photoUrl == null || photoUrl!.isEmpty
                      ? const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: photoUrl != null && photoUrl!.isNotEmpty
                    ? ClipOval(
                        child: SmartImage(
                          imageData: photoUrl!,
                          width: 100,
                          height: 100,
                        ),
                      )
                    : Center(
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : '?',
                          style: GoogleFonts.cairo(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
              ),
              // Edit photo button
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _pickPhoto(context),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.scaffoldBackgroundColor,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Name
          Text(
            name,
            style: GoogleFonts.cairo(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
            ),
          ),
          if (email.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              email,
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickPhoto(BuildContext context) async {
    try {
      final uploadService = context.read<ImageUploadService>();
      final authService = context.read<AuthService>();
      final uid = authService.currentUser?.uid;
      if (uid == null) return;

      final url = await uploadService.pickAndUploadImage(
        folder: 'profile_photos',
        fileName: '$uid.jpg',
        maxWidth: 500,
        quality: 80,
      );

      if (url != null && context.mounted) {
        await authService.updateUserPhoto(url);
      }
    } catch (e) {
      debugPrint('Error picking photo: $e');
    }
  }
}
