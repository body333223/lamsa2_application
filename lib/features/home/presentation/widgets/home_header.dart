// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/data_service.dart';
import '../../../notifications/presentation/pages/notifications_screen.dart';
import '../../logic/home_controller.dart';
import 'home_avatar.dart';
import 'home_search_bar.dart';
import 'promo_banner.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final controller = context.watch<HomeController>();
    final authService = context.watch<AuthService>();
    final photoUrl = authService.currentUser?.avatarUrl;

    return FutureBuilder<Map<String, dynamic>?>(
      future: authService.getUserData(),
      builder: (_, snap) {
        final name = (snap.data?['name'] ?? 'ضيفتنا').toString();
        final firstName = name.split(' ').first;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [
                      AppColors.primary.withOpacity(0.08),
                      theme.scaffoldBackgroundColor,
                    ]
                  : [
                      AppColors.primary.withOpacity(0.06),
                      theme.scaffoldBackgroundColor,
                    ],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Top row: Avatar + Greeting + Notification ──
                  Row(
                    children: [
                      HomeAvatar(
                        initial: firstName.isNotEmpty ? firstName[0] : 'ل',
                        photoUrl: photoUrl,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.getGreeting(isArabic: s.isArabic),
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.6),
                              ),
                            ),
                            Text(
                              firstName,
                              style: GoogleFonts.cairo(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _NotifButton(
                        isDark: isDark,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const NotificationsScreen()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // ── Search bar ──
                  HomeSearchBar(hint: s.searchHint, isDark: isDark),
                  const SizedBox(height: 22),

                  // ── Promo banner from Backend ──
                  PromoBanner(isDark: isDark, sliders: controller.sliders),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Notification button with unread count badge ──────────────────────────────

class _NotifButton extends StatelessWidget {
  final bool isDark;
  final VoidCallback onTap;
  const _NotifButton({required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthService>().userId;
    final dataService = context.read<DataService>();

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: userId != null ? dataService.getNotifications(userId) : Future.value([]),
      builder: (context, snapshot) {
        int unreadCount = 0;
        if (snapshot.hasData && snapshot.data != null) {
          unreadCount = snapshot.data!.where((n) => n['isRead'] == false).length;
        }
        final hasUnread = unreadCount > 0;

        return GestureDetector(
          onTap: onTap,
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.08) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  hasUnread
                      ? Icons.notifications_rounded
                      : Icons.notifications_none_rounded,
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 22,
                ),
                if (hasUnread)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.error.withOpacity(0.4),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          unreadCount > 99 ? '99+' : '$unreadCount',
                          style: GoogleFonts.cairo(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1,
                          ),
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
