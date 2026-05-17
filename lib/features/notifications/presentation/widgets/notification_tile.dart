// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

/// A single notification card widget with modern design.
class NotificationTile extends StatelessWidget {
  final String title;
  final String body;
  final String? imageUrl;
  final DateTime? time;
  final String? type;
  final bool isRead;

  const NotificationTile({
    super.key,
    required this.title,
    required this.body,
    this.imageUrl,
    this.time,
    this.type,
    this.isRead = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final config = _getNotifConfig(type);

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(isRead ? 0.04 : 0.08)
            : isRead
                ? Colors.white
                : AppColors.primary.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(isRead ? 0.06 : 0.12)
              : isRead
                  ? AppColors.border.withOpacity(0.3)
                  : AppColors.primary.withOpacity(0.15),
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
          // Image (if available)
          if (imageUrl != null && imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              child: CachedNetworkImage(
                imageUrl: imageUrl!,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => const SizedBox(),
              ),
            ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: config.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(config.icon, color: config.color, size: 20),
                ),
                const SizedBox(width: 12),

                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title + time row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: theme.colorScheme.onSurface,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (time != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              _formatTime(time!),
                              style: GoogleFonts.cairo(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.4),
                              ),
                            ),
                          ],
                        ],
                      ),

                      // Body
                      if (body.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          body,
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                            height: 1.5,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      // Unread indicator
                      if (!isRead) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'جديد',
                            style: GoogleFonts.cairo(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return '${diff.inMinutes} د';
    if (diff.inHours < 24) return '${diff.inHours} س';
    if (diff.inDays < 7) return '${diff.inDays} ي';
    return '${date.day}/${date.month}';
  }

  _NotifConfig _getNotifConfig(String? type) {
    switch (type) {
      case 'booking_status':
        return _NotifConfig(
          icon: Icons.calendar_today_rounded,
          color: const Color(0xFF6366F1),
        );
      case 'chat':
        return _NotifConfig(
          icon: Icons.chat_bubble_rounded,
          color: const Color(0xFF45B7D1),
        );
      case 'offer':
        return _NotifConfig(
          icon: Icons.local_offer_rounded,
          color: AppColors.gold,
        );
      default:
        return _NotifConfig(
          icon: Icons.notifications_rounded,
          color: AppColors.primary,
        );
    }
  }
}

class _NotifConfig {
  final IconData icon;
  final Color color;

  const _NotifConfig({required this.icon, required this.color});
}
