// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/locale_service.dart';
import '../../../../services/theme_service.dart';
import '../../../favorites/presentation/pages/favorites_screen.dart';
import '../../../notifications/presentation/pages/notifications_screen.dart';
import '../../../support/presentation/pages/support_chat_screen.dart';
import '../../../auth/presentation/pages/login_screen.dart';

class ProfileMenu extends StatelessWidget {
  final String name;

  const ProfileMenu({
    super.key,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── General Section ──
          _SectionCard(
            context: context,
            children: [
              _MenuTile(
                icon: Icons.person_outline_rounded,
                iconBg: const Color(0xFF6C63FF),
                title: s.editProfile,
                onTap: () => _showEditNameDialog(context, name),
              ),
              _Divider(isDark: isDark),
              _MenuTile(
                icon: Icons.favorite_outline_rounded,
                iconBg: const Color(0xFFFF6B6B),
                title: s.favorites,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                ),
              ),
              _Divider(isDark: isDark),
              _MenuTile(
                icon: Icons.notifications_none_rounded,
                iconBg: const Color(0xFFFFB347),
                title: s.notifications,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const NotificationsScreen()),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Preferences Section ──
          _SectionCard(
            context: context,
            children: [
              _MenuTile(
                icon: Icons.language_rounded,
                iconBg: const Color(0xFF4ECDC4),
                title: s.useLanguage,
                trailing: Text(
                  s.language,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                onTap: () => context.read<LocaleService>().toggleLanguage(),
              ),
              _Divider(isDark: isDark),
              _MenuTile(
                icon: Icons.palette_outlined,
                iconBg: const Color(0xFF9B59B6),
                title: s.isArabic ? 'المظهر' : 'Appearance',
                trailing: Text(
                  _themeLabel(context),
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                onTap: () => _showThemePicker(context),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Support Section ──
          _SectionCard(
            context: context,
            children: [
              _MenuTile(
                icon: Icons.chat_bubble_outline_rounded,
                iconBg: const Color(0xFF45B7D1),
                title: s.helpAndSupport,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const SupportChatScreen(userId: '')),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Logout Button — Modern Style ──
          Center(
            child: GestureDetector(
              onTap: () => _showLogoutDialog(context),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(isDark ? 0.15 : 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.error.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.logout_rounded,
                        color: AppColors.error, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      s.logout,
                      style: GoogleFonts.cairo(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // App version
          Center(
            child: Text(
              'Lamsa v1.0.0',
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withOpacity(0.3),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _themeLabel(BuildContext context) {
    final mode = context.watch<ThemeService>().mode;
    final isArabic = context.watch<LocaleService>().isArabic;
    switch (mode) {
      case 'system':
        return isArabic ? 'تلقائي' : 'Auto';
      case 'light':
        return isArabic ? 'فاتح' : 'Light';
      case 'dark':
        return isArabic ? 'داكن' : 'Dark';
      default:
        return isArabic ? 'تلقائي' : 'Auto';
    }
  }

  void _showThemePicker(BuildContext context) {
    final isArabic = context.read<LocaleService>().isArabic;
    final themeService = context.read<ThemeService>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
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
            const SizedBox(height: 24),
            Text(
              isArabic ? 'اختاري المظهر' : 'Choose Appearance',
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 24),
            _ThemeOption(
              icon: Icons.phone_android_rounded,
              title: isArabic ? 'تلقائي (حسب الجهاز)' : 'Auto (System)',
              isSelected: themeService.mode == 'system',
              onTap: () {
                themeService.setThemeMode('system');
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 12),
            _ThemeOption(
              icon: Icons.light_mode_rounded,
              title: isArabic ? 'الوضع الفاتح' : 'Light Mode',
              isSelected: themeService.mode == 'light',
              onTap: () {
                themeService.setThemeMode('light');
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 12),
            _ThemeOption(
              icon: Icons.dark_mode_rounded,
              title: isArabic ? 'الوضع الداكن' : 'Dark Mode',
              isSelected: themeService.mode == 'dark',
              onTap: () {
                themeService.setThemeMode('dark');
                Navigator.pop(ctx);
              },
            ),
            SizedBox(height: MediaQuery.of(ctx).padding.bottom + 16),
          ],
        ),
      ),
    );
  }

  void _showEditNameDialog(BuildContext context, String currentName) {
    final s = AppStrings(context);
    final controller = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(s.editName,
            style: GoogleFonts.cairo(fontWeight: FontWeight.w800)),
        content: TextField(
          controller: controller,
          style: GoogleFonts.cairo(),
          decoration: InputDecoration(
            hintText: s.yourName,
            hintStyle: GoogleFonts.cairo(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s.cancel,
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                await ctx.read<AuthService>().updateUserName(newName);
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: Text(s.save,
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final authService = context.read<AuthService>();
    final s = AppStrings(context);

    showDialog(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final isDark = theme.brightness == Brightness.dark;
        final actionColor = AppColors.error;

        return Dialog(
          backgroundColor: isDark ? const Color(0xFF1E1C20) : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: actionColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child:
                      Icon(Icons.logout_rounded, color: actionColor, size: 30),
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
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.of(ctx).pop();
                      await authService.signOut();
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                          (route) => false,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: actionColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      s.yes,
                      style: GoogleFonts.cairo(
                          fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text(
                      s.no,
                      style: GoogleFonts.cairo(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Section Card — Groups menu items in a card ────────────────────────────────

class _SectionCard extends StatelessWidget {
  final BuildContext context;
  final List<Widget> children;

  const _SectionCard({required this.context, required this.children});

  @override
  Widget build(BuildContext buildContext) {
    final theme = Theme.of(buildContext);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
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
      child: Column(children: children),
    );
  }
}

// ── Menu Tile — iOS Settings style ───────────────────────────────────────────

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String title;
  final Widget? trailing;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.iconBg,
    required this.title,
    this.trailing,
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Icon with colored background
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 14),
              // Title
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              // Trailing or chevron
              if (trailing != null) ...[
                trailing!,
                const SizedBox(width: 6),
              ],
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.25),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Divider ───────────────────────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  final bool isDark;
  const _Divider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 66, right: 16),
      child: Divider(
        height: 1,
        thickness: 0.5,
        color: isDark
            ? Colors.white.withOpacity(0.08)
            : Colors.grey.withOpacity(0.12),
      ),
    );
  }
}

// ── Theme Option ──────────────────────────────────────────────────────────────

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : (isDark ? Colors.white.withOpacity(0.05) : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withOpacity(0.4)
                : (isDark ? Colors.white.withOpacity(0.08) : AppColors.border),
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isSelected
                    ? AppColors.primary
                    : theme.colorScheme.onSurface,
                size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? AppColors.primary
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.primary, size: 22),
          ],
        ),
      ),
    );
  }
}
