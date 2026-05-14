// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glow_orb.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/locale_service.dart';
import '../widgets/notification_tile.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(context);
    final isArabic = context.watch<LocaleService>().isArabic;
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
            onPressed: () => _markAllRead(context),
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
          // Listen to both collections — filtered by user
          StreamBuilder<QuerySnapshot>(
            stream: _getFilteredNotifications(context),
            builder: (context, snapshot1) {
              return StreamBuilder<QuerySnapshot>(
                stream: _getFilteredLegacyNotifications(context),
                builder: (context, snapshot2) {
                  if (snapshot1.connectionState == ConnectionState.waiting &&
                      snapshot2.connectionState == ConnectionState.waiting) {
                    return ListView.builder(
                      padding: EdgeInsets.fromLTRB(
                          20, MediaQuery.of(context).padding.top + 100, 20, 40),
                      itemCount: 4,
                      itemBuilder: (_, __) => _ShimmerNotification(),
                    );
                  }

                  if (snapshot1.hasError && snapshot2.hasError) {
                    return _buildEmptyState(
                        context,
                        isArabic ? 'صار خطأ' : 'Error',
                        Icons.warning_amber_rounded);
                  }

                  final docs1 = snapshot1.data?.docs ?? [];
                  final docs2 = snapshot2.data?.docs ?? [];
                  final allDocs = [...docs1, ...docs2];

                  if (allDocs.isEmpty) {
                    return _buildEmptyState(context, s.noNotifications,
                        Icons.notifications_off_outlined);
                  }

                  // Sort by time (newest first) — client side
                  allDocs.sort((a, b) {
                    final dataA = a.data() as Map<String, dynamic>;
                    final dataB = b.data() as Map<String, dynamic>;
                    final timeA = _getTime(dataA);
                    final timeB = _getTime(dataB);
                    return timeB.compareTo(timeA);
                  });

                  // Deduplicate by title+body
                  final seen = <String>{};
                  final uniqueDocs = <QueryDocumentSnapshot>[];
                  for (final doc in allDocs) {
                    final data = doc.data() as Map<String, dynamic>;
                    final key = '${data['title'] ?? ''}_${data['body'] ?? ''}';
                    if (!seen.contains(key)) {
                      seen.add(key);
                      uniqueDocs.add(doc);
                    }
                  }

                  return ListView.builder(
                    padding: EdgeInsets.fromLTRB(
                        20, MediaQuery.of(context).padding.top + 100, 20, 120),
                    itemCount: uniqueDocs.length,
                    itemBuilder: (context, i) {
                      final data = uniqueDocs[i].data() as Map<String, dynamic>;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: NotificationTile(
                          title: data['title'] ?? '',
                          body: data['body'] ?? '',
                          imageUrl: data['imageUrl'],
                          time: _getTimeNullable(data),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  /// Get notifications filtered by current user
  Stream<QuerySnapshot> _getFilteredNotifications(BuildContext context) {
    final userId = context.read<AuthService>().currentUser?.uid;
    if (userId == null) {
      // لو مفيش مستخدم، نعرض العامة بس
      return FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: 'all')
          .snapshots();
    }
    return FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', whereIn: [userId, 'all']).snapshots();
  }

  /// Get legacy notifications filtered by current user
  Stream<QuerySnapshot> _getFilteredLegacyNotifications(BuildContext context) {
    final userId = context.read<AuthService>().currentUser?.uid;
    if (userId == null) {
      return FirebaseFirestore.instance
          .collection('Notification')
          .where('userId', whereIn: ['all', '']).snapshots();
    }
    return FirebaseFirestore.instance
        .collection('Notification')
        .where('userId', whereIn: [userId, 'all', '']).snapshots();
  }

  DateTime _getTime(Map<String, dynamic> data) {
    final sentAt = data['sentAt'];
    final createdAt = data['createdAt'];
    if (sentAt is Timestamp) return sentAt.toDate();
    if (createdAt is Timestamp) return createdAt.toDate();
    return DateTime(2000);
  }

  DateTime? _getTimeNullable(Map<String, dynamic> data) {
    final sentAt = data['sentAt'];
    final createdAt = data['createdAt'];
    if (sentAt is Timestamp) return sentAt.toDate();
    if (createdAt is Timestamp) return createdAt.toDate();
    return null;
  }

  Future<void> _markAllRead(BuildContext context) async {
    final userId = context.read<AuthService>().currentUser?.uid;
    final batch = FirebaseFirestore.instance.batch();

    // Mark notifications for this user as read
    final snap1 = await FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', whereIn: [userId ?? '', 'all']).get();
    for (final doc in snap1.docs) {
      final data = doc.data();
      if (data['isRead'] != true) {
        batch.update(doc.reference, {'isRead': true});
      }
    }

    // Same for legacy collection
    try {
      final snap2 = await FirebaseFirestore.instance
          .collection('Notification')
          .where('userId', whereIn: [userId ?? '', 'all', '']).get();
      for (final doc in snap2.docs) {
        final data = doc.data();
        if (data['isRead'] != true) {
          batch.update(doc.reference, {'isRead': true});
        }
      }
    } catch (_) {}

    await batch.commit();
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
