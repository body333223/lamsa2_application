// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/smart_image.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/image_upload_service.dart';
import '../../../../services/locale_service.dart';
import '../../../../services/theme_service.dart';
import '../../../auth/presentation/pages/login_screen.dart';
import '../../../favorites/presentation/pages/favorites_screen.dart';
import '../../../support/presentation/pages/support_chat_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final s = AppStrings(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: FutureBuilder<Map<String, dynamic>?>(
        future: authService.getUserData(),
        builder: (_, snap) {
          final data = snap.data;
          final name = (data?['name'] ?? s.guest) as String;
          final phone = (data?['phone'] ?? '') as String;
          final photoUrl = authService.currentUser?.avatarUrl;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // ── Header with Avatar ──
                _buildHeader(context, name, phone, photoUrl, theme, isDark),
                const SizedBox(height: 24),

                // ── Account Section ──
                _buildSection(
                  context: context,
                  title: s.isArabic ? 'الحساب' : 'ACCOUNT',
                  theme: theme,
                  isDark: isDark,
                  children: [
                    _ProfileTile(
                      icon: Icons.person_rounded,
                      iconColor: AppColors.primary,
                      title: s.editProfile,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const EditProfileScreen()),
                      ),
                    ),
                    _ProfileTile(
                      icon: Icons.favorite_rounded,
                      iconColor: const Color(0xFFE25858),
                      title: s.isArabic ? 'المفضلة' : 'Favorites',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const FavoritesScreen()),
                      ),
                    ),
                    _ProfileTile(
                      icon: Icons.delete_outline_rounded,
                      iconColor: AppColors.error,
                      title: s.isArabic ? 'حذف الحساب' : 'Delete Account',
                      titleColor: AppColors.error,
                      onTap: () => _showDeleteAccountDialog(context, s),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Preferences Section ──
                _buildSection(
                  context: context,
                  title: s.isArabic ? 'التفضيلات' : 'PREFERENCES',
                  theme: theme,
                  isDark: isDark,
                  children: [
                    _ThemeToggleTile(isDark: isDark),
                    _LanguageTile(),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Support Section ──
                _buildSection(
                  context: context,
                  title: s.isArabic ? 'الدعم' : 'SUPPORT',
                  theme: theme,
                  isDark: isDark,
                  children: [
                    _ProfileTile(
                      icon: Icons.chat_bubble_outline_rounded,
                      iconColor: const Color(0xFF45B7D1),
                      title: s.helpAndSupport,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SupportChatScreen(userId: ''),
                        ),
                      ),
                    ),
                    _ProfileTile(
                      icon: Icons.share_rounded,
                      iconColor: const Color(0xFF9B59B6),
                      title: s.isArabic ? 'شاركي التطبيق' : 'Share App',
                      onTap: () {
                        Share.share(
                          s.isArabic
                              ? 'جربي تطبيق لمسة - خدمات تجميل وسبا توصلك لبيتك 💅✨'
                              : 'Try Lamsa app - Beauty & Spa services at your doorstep 💅✨',
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // ── Logout Button ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: () => _showLogoutDialog(context, s),
                      icon: const Icon(Icons.logout_rounded, size: 20),
                      label: Text(
                        s.logout,
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            AppColors.error.withOpacity(isDark ? 0.2 : 0.1),
                        foregroundColor: AppColors.error,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Version
                Text(
                  'لمسة v1.0.0',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withOpacity(0.3),
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String name, String phone,
      String? photoUrl, ThemeData theme, bool isDark) {
    final s = AppStrings(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        24,
        MediaQuery.of(context).padding.top + 40,
        24,
        32,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  const Color(0xFF1A2E35),
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
          // Avatar
          GestureDetector(
            onTap: () => _showPhotoPickerSheet(context, s),
            child: Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: photoUrl == null || photoUrl.isEmpty
                        ? const LinearGradient(
                            colors: [AppColors.primary, AppColors.accent],
                          )
                        : null,
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: photoUrl != null && photoUrl.isNotEmpty
                      ? ClipOval(
                          child: SmartImage(
                            imageData: photoUrl,
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
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.scaffoldBackgroundColor,
                        width: 3,
                      ),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
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

          // Phone
          if (phone.isNotEmpty) ...[
            const SizedBox(height: 4),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.phone_rounded,
                      size: 14,
                      color: theme.colorScheme.onSurface.withOpacity(0.5)),
                  const SizedBox(width: 6),
                  Text(
                    phone,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required ThemeData theme,
    required bool isDark,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8, left: 8, bottom: 10),
            child: Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface.withOpacity(0.4),
                letterSpacing: 1,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.06) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                if (!isDark)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Column(
              children: _insertDividers(children, isDark),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _insertDividers(List<Widget> children, bool isDark) {
    final result = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      result.add(children[i]);
      if (i < children.length - 1) {
        result.add(Padding(
          padding: const EdgeInsets.only(left: 60, right: 16),
          child: Divider(
            height: 1,
            thickness: 0.5,
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.grey.withOpacity(0.12),
          ),
        ));
      }
    }
    return result;
  }

  void _showDeleteAccountDialog(BuildContext context, AppStrings s) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: isDark ? const Color(0xFF1E1C20) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warning_rounded,
                    color: AppColors.error, size: 28),
              ),
              const SizedBox(height: 20),
              Text(
                s.isArabic ? 'حذف الحساب' : 'Delete Account',
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                s.isArabic
                    ? 'هل أنتِ متأكدة؟ سيتم حذف حسابك وجميع بياناتك نهائياً.'
                    : 'Are you sure? Your account and all data will be permanently deleted.',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(s.cancel,
                          style:
                              GoogleFonts.cairo(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        final auth = context.read<AuthService>();
                        await auth.deleteAccount();
                        if (!context.mounted) return;
                        AppSnackbar.show(
                          context,
                          message: s.isArabic
                              ? 'تم حذف حسابك وجميع بياناتك نهائياً بنجاح'
                              : 'Your account has been permanently deleted',
                          type: SnackType.success,
                        );
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        s.isArabic ? 'حذف' : 'Delete',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AppStrings s) {
    final authService = context.read<AuthService>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: isDark ? const Color(0xFF1E1C20) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout_rounded,
                    color: AppColors.error, size: 28),
              ),
              const SizedBox(height: 20),
              Text(
                s.logoutConfirmTitle,
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                s.logoutConfirmBody,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.of(ctx).pop();
                    await authService.signOut();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(s.yes,
                      style: GoogleFonts.cairo(
                          fontSize: 16, fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(s.no,
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPhotoPickerSheet(BuildContext context, AppStrings s) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1C20) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                s.isArabic ? 'صورة الملف الشخصي' : 'Profile Photo',
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.photo_camera_rounded, color: AppColors.primary),
                ),
                title: Text(
                  s.isArabic ? 'التقاط صورة بالكاميرا' : 'Take a photo',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndUploadAvatar(context, ImageSource.camera, s);
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9B59B6).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: Color(0xFF9B59B6)),
                ),
                title: Text(
                  s.isArabic ? 'اختيار من المعرض' : 'Choose from gallery',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndUploadAvatar(context, ImageSource.gallery, s);
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.edit_rounded, color: Colors.teal),
                ),
                title: Text(
                  s.isArabic ? 'تعديل البيانات الشخصية' : 'Edit profile info',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickAndUploadAvatar(BuildContext context, ImageSource source, AppStrings s) async {
    try {
      final uploadService = context.read<ImageUploadService>();
      final authService = context.read<AuthService>();
      final uid = authService.userId;
      if (uid == null) {
        AppSnackbar.show(context,
            message: s.isArabic ? 'يجب تسجيل الدخول أولاً' : 'Please login first',
            type: SnackType.warning);
        return;
      }

      AppSnackbar.show(context,
          message: s.isArabic ? 'جاري رفع الصورة...' : 'Uploading photo...',
          type: SnackType.info);

      final url = await uploadService.pickAndUploadImage(
        folder: 'profile_photos',
        fileName: '$uid.jpg',
        maxWidth: 600,
        quality: 80,
        source: source,
      );

      if (url != null && context.mounted) {
        await authService.updateUserPhoto(url);
        AppSnackbar.show(context,
            message: s.isArabic ? 'تم تحديث الصورة الشخصية بنجاح ✓' : 'Profile photo updated successfully ✓',
            type: SnackType.success);
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackbar.show(context,
            message: s.isArabic ? 'حدث خطأ أثناء رفع الصورة' : 'Error uploading photo',
            type: SnackType.error);
      }
    }
  }
}

// ── Profile Tile ──────────────────────────────────────────────────────────────

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Color? titleColor;
  final VoidCallback onTap;

  const _ProfileTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.titleColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: titleColor ?? theme.colorScheme.onSurface,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Theme Toggle Tile ─────────────────────────────────────────────────────────

class _ThemeToggleTile extends StatelessWidget {
  final bool isDark;
  const _ThemeToggleTile({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeService = context.watch<ThemeService>();
    final isArabic = context.watch<LocaleService>().isArabic;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF9B59B6).withOpacity(0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(Icons.palette_rounded,
                color: Color(0xFF9B59B6), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              isArabic ? 'المظهر' : 'Theme',
              style: GoogleFonts.cairo(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          // Toggle buttons
          Container(
            decoration: BoxDecoration(
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ThemeChip(
                  icon: Icons.light_mode_rounded,
                  label: isArabic ? 'فاتح' : 'Light',
                  isSelected: themeService.mode == 'light',
                  onTap: () => themeService.setThemeMode('light'),
                ),
                _ThemeChip(
                  icon: Icons.dark_mode_rounded,
                  label: isArabic ? 'داكن' : 'Dark',
                  isSelected: themeService.mode == 'dark',
                  onTap: () => themeService.setThemeMode('dark'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeChip({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 14, color: isSelected ? Colors.white : Colors.grey),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Language Tile ─────────────────────────────────────────────────────────────

class _LanguageTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = context.watch<LocaleService>().isArabic;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.read<LocaleService>().toggleLanguage(),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF4ECDC4).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(Icons.language_rounded,
                    color: Color(0xFF4ECDC4), size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  isArabic ? 'اللغة' : 'Language',
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              Text(
                isArabic ? 'English' : 'العربية',
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
