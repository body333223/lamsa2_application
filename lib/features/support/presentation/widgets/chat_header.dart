// ignore_for_file: deprecated_member_use, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:ui';
import 'package:firebase_messaging/firebase_messaging.dart'
    show FirebaseMessaging;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_theme.dart';

/// The app bar content for the support chat screen.
class ChatHeader extends StatelessWidget implements PreferredSizeWidget {
  final String userId;

  const ChatHeader({
    super.key,
    required this.userId,
  });

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(context);
    final theme = Theme.of(context);

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 80,
      leadingWidth: 70,
      leading: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Center(
          child: AppTheme.buildGlassContainer(
            context: context,
            padding: EdgeInsets.zero,
            opacity: 0.1,
            borderRadius: BorderRadius.circular(16),
            child: IconButton(
              icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      title: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.accent]),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Center(
                    child: Icon(Icons.support_agent_rounded,
                        color: Colors.white, size: 24)),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.support,
                  style: GoogleFonts.cairo(
                      fontSize: 16, fontWeight: FontWeight.w900)),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                        color: AppColors.success, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'ID: ${userId.length > 8 ? userId.substring(0, 8) : userId}...',
                    style: GoogleFonts.cairo(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface.withOpacity(0.4)),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () async {
                      final token = await FirebaseMessaging.instance.getToken();
                      if (token != null) {
                        Clipboard.setData(ClipboardData(text: token));
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('تم نسخ عنوان الجهاز (FCM Token)')),
                          );
                        }
                      }
                    },
                    child: Icon(Icons.copy_rounded,
                        size: 12, color: AppColors.primary.withOpacity(0.5)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(color: Colors.transparent),
        ),
      ),
    );
  }
}
