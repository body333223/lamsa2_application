// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/smart_image.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/data_service.dart';
import '../../../../services/image_upload_service.dart';

/// Full-page edit profile screen.
/// Allows editing: name, phone, and profile photo.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _photoUrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authService = context.read<AuthService>();
    final user = authService.currentUser;

    // Load instantly from local cache (no network)
    _nameController.text = user?.displayName ?? '';
    _photoUrl = user?.photoURL;
    _phoneController.text = user?.phoneNumber ?? '';

    // Then try to get phone from Firestore (background, non-blocking)
    final uid = user?.uid;
    if (uid != null) {
      try {
        final firestoreData =
            await context.read<DataService>().getUserData(uid);
        if (mounted && firestoreData != null) {
          final phone = (firestoreData['phone'] ?? '').toString();
          final name = (firestoreData['name'] ?? '').toString();
          if (phone.isNotEmpty && _phoneController.text.isEmpty) {
            _phoneController.text = phone;
          }
          if (name.isNotEmpty && _nameController.text.isEmpty) {
            _nameController.text = name;
          }
          setState(() {});
        }
      } catch (_) {}
    }
  }

  void _pickPhoto() {
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
                'تغيير الصورة الشخصية',
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
                  'التقاط صورة بالكاميرا',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _uploadFromSource(ImageSource.camera);
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
                  'اختيار من المعرض',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _uploadFromSource(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _uploadFromSource(ImageSource source) async {
    try {
      final uploadService = context.read<ImageUploadService>();
      final authService = context.read<AuthService>();
      final uid = authService.userId;
      if (uid == null) return;

      AppSnackbar.show(context, message: 'جاري رفع الصورة...', type: SnackType.info);

      final url = await uploadService.pickAndUploadImage(
        folder: 'profile_photos',
        fileName: '$uid.jpg',
        maxWidth: 600,
        quality: 80,
        source: source,
      );

      if (url != null) {
        if (!mounted) return;
        await authService.updateUserPhoto(url);
        if (!mounted) return;
        setState(() {
          _photoUrl = url;
        });
        AppSnackbar.show(context,
            message: 'تم تحديث الصورة الشخصية بنجاح ✓', type: SnackType.success);
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.show(context,
            message: 'حدث خطأ أثناء رفع الصورة', type: SnackType.error);
      }
    }
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty) {
      AppSnackbar.show(context,
          message: 'الاسم مطلوب', type: SnackType.warning);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final authService = context.read<AuthService>();
      final firestoreService = context.read<DataService>();
      final uid = authService.userId;

      // Update name in Firebase Auth
      await authService.updateUserName(name);

      // Update phone in Firestore
      if (uid != null) {
        await firestoreService.updateUserData(
          userId: uid,
          data: {'phone': phone, 'name': name},
        );
      }

      if (mounted) {
        AppSnackbar.show(context,
            message: 'تم حفظ التعديلات ✓', type: SnackType.success);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.show(context,
            message: 'حدث خطأ أثناء الحفظ', type: SnackType.error);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'تعديل الملف الشخصي',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: theme.colorScheme.onSurface, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // ── Avatar ──
            _buildAvatarSection(theme, isDark),
            const SizedBox(height: 40),

            // ── Name Field ──
            _buildTextField(
              controller: _nameController,
              label: 'الاسم',
              hint: 'اكتبي اسمك',
              icon: Icons.person_rounded,
              theme: theme,
              isDark: isDark,
            ),
            const SizedBox(height: 20),

            // ── Phone Field ──
            _buildTextField(
              controller: _phoneController,
              label: 'رقم الجوال',
              hint: '05xxxxxxxx',
              icon: Icons.phone_rounded,
              theme: theme,
              isDark: isDark,
              keyboardType: TextInputType.phone,
              textDirection: TextDirection.ltr,
            ),
            const SizedBox(height: 40),

            // ── Save Button ──
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        'حفظ التعديلات',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection(ThemeData theme, bool isDark) {
    final hasPhoto = _photoUrl != null && _photoUrl!.isNotEmpty;

    return GestureDetector(
      onTap: _pickPhoto,
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: hasPhoto
                      ? null
                      : const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: hasPhoto
                    ? ClipOval(
                        child: SmartImage(
                          imageData: _photoUrl!,
                          width: 120,
                          height: 120,
                        ),
                      )
                    : Center(
                        child: Text(
                          _nameController.text.isNotEmpty
                              ? _nameController.text[0].toUpperCase()
                              : '?',
                          style: GoogleFonts.cairo(
                            fontSize: 42,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  width: 36,
                  height: 36,
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
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'اضغطي لتغيير الصورة',
            style: GoogleFonts.cairo(
              fontSize: 13,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required ThemeData theme,
    required bool isDark,
    TextInputType? keyboardType,
    TextDirection? textDirection,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 4, bottom: 8),
          child: Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.06) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : AppColors.border.withOpacity(0.5),
            ),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            textDirection: textDirection,
            onChanged: (_) {},
            style: GoogleFonts.cairo(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.cairo(
                color: theme.colorScheme.onSurface.withOpacity(0.3),
              ),
              prefixIcon: Icon(
                icon,
                color: AppColors.primary.withOpacity(0.6),
                size: 22,
              ),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}
