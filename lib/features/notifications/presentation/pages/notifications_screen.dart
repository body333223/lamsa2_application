// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glow_orb.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/data_service.dart';
import '../../../../services/locale_service.dart';
import '../widgets/notification_tile.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final auth = context.read<AuthService>();
    if (!auth.isLoggedIn) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final data = context.read<DataService>();
      final notifs = await data.getNotifications(auth.userId!);
      setState(() {
        _notifications = notifs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _markAllRead() async {
    try {
      final data = context.read<DataService>();
      await data.markAllNotificationsAsRead();
      setState(() {
        _notifications = _notifications
            .map((n) => {...n, 'is_read': true})
            .toList();
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(context);
    final isArabic = context.watch<LocaleService?>()?.isArabic ?? true;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          s.notifications,
          style: GoogleFonts.cairo(
              fontWeight: FontWeight.w900,
              fontSize: 22,
              color: theme.colorScheme.onSurface),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: theme.colorScheme.onSurface, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _markAllRead,
            child: Text(
              isArabic ? 'قراءة الكل' : 'Read All',
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
              top: -50,
              right: -50,
              child: GlowOrb(
                  size: 300, color: AppColors.primary.withOpacity(0.15))),
          Positioned(
              bottom: 100,
              left: -100,
              child: GlowOrb(
                  size: 400, color: AppColors.accent.withOpacity(0.08))),
          if (_isLoading)
            ListView.builder(
              padding: EdgeInsets.fromLTRB(
                  20, MediaQuery.of(context).padding.top + 100, 20, 40),
              itemCount: 4,
              itemBuilder: (_, __) => _ShimmerNotification(),
            )
          else if (_error != null)
            _buildEmptyState(context, 'صار خطأ', Icons.warning_amber_rounded)
          else if (_notifications.isEmpty)
            _buildEmptyState(
                context, s.noNotifications, Icons.notifications_off_outlined)
          else
            RefreshIndicator(
              onRefresh: _loadNotifications,
              color: AppColors.primary,
              child: ListView.builder(
                padding: EdgeInsets.fromLTRB(
                    20, MediaQuery.of(context).padding.top + 100, 20, 120),
                itemCount: _notifications.length,
                itemBuilder: (context, i) {
                  final data = _notifications[i];
                  final title = (data['title'] ?? '').toString().trim();
                  final body = (data['body'] ?? '').toString().trim();

                  if (title.isEmpty && body.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  DateTime? time;
                  final raw = data['created_at'];
                  if (raw != null) {
                    time = DateTime.tryParse(raw.toString());
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: NotificationTile(
                      title: title.isNotEmpty ? title : 'إشعار',
                      body: body,
                      imageUrl: data['image_url']?.toString(),
                      time: time,
                      type: data['type']?.toString(),
                      isRead: data['is_read'] as bool? ?? false,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child:
                Icon(icon, color: AppColors.primary.withOpacity(0.4), size: 60),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ShimmerNotification extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 110,
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withOpacity(0.04),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.05)),
      ),
    );
  }
}
