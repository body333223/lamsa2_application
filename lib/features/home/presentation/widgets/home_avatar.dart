// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/smart_image.dart';
import '../../../profile/presentation/pages/edit_profile_screen.dart';

/// Home screen avatar widget.
/// Tapping navigates to the Edit Profile screen.
class HomeAvatar extends StatelessWidget {
  final String initial;
  final String? photoUrl;

  const HomeAvatar({super.key, required this.initial, this.photoUrl});

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoUrl != null && photoUrl!.isNotEmpty;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const EditProfileScreen()),
      ),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: hasPhoto
              ? null
              : const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: hasPhoto
            ? ClipOval(
                child: SmartImage(
                  imageData: photoUrl!,
                  width: 52,
                  height: 52,
                ),
              )
            : Center(
                child: Text(
                  initial.toUpperCase(),
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
      ),
    );
  }
}
