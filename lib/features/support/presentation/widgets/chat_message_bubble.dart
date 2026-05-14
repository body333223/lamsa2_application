// ignore_for_file: deprecated_member_use, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

/// A single chat message bubble widget.
class ChatMessageBubble extends StatelessWidget {
  final String text;
  final bool isAdmin;
  final DateTime? time;

  const ChatMessageBubble({
    super.key,
    required this.text,
    required this.isAdmin,
    this.time,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final timeStr = time != null
        ? "${time!.hour}:${time!.minute.toString().padLeft(2, '0')}"
        : "";

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Align(
        alignment: isAdmin ? Alignment.centerLeft : Alignment.centerRight,
        child: Column(
          crossAxisAlignment:
              isAdmin ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (isAdmin) ...[
                  Container(
                    width: 32,
                    height: 32,
                    margin: const EdgeInsets.only(bottom: 4, right: 8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.4),
                          AppColors.accent.withOpacity(0.4)
                        ],
                      ),
                    ),
                    child: const Icon(Icons.support_agent_rounded,
                        size: 16, color: Colors.white),
                  ),
                ],
                Flexible(
                  child: Container(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.72),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: isAdmin
                          ? (isDark
                              ? Colors.white.withOpacity(0.08)
                              : Colors.black.withOpacity(0.06))
                          : null,
                      gradient: isAdmin
                          ? null
                          : LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primaryDark
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(24),
                        topRight: const Radius.circular(24),
                        bottomLeft: Radius.circular(isAdmin ? 6 : 28),
                        bottomRight: Radius.circular(isAdmin ? 28 : 6),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isAdmin
                              ? Colors.black.withOpacity(0.05)
                              : AppColors.primary.withOpacity(0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: isAdmin
                          ? Border.all(color: Colors.white.withOpacity(0.1))
                          : null,
                    ),
                    child: Text(
                      text,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.6,
                        color: isAdmin
                            ? theme.colorScheme.onSurface
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
                if (!isAdmin) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 32,
                    height: 32,
                    margin: const EdgeInsets.only(bottom: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withOpacity(0.15),
                      border: Border.all(
                          color: AppColors.primary.withOpacity(0.3), width: 1),
                    ),
                    child: const Icon(Icons.person_rounded,
                        size: 16, color: AppColors.primary),
                  ),
                ],
              ],
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: 6, right: isAdmin ? 0 : 40, left: isAdmin ? 40 : 0),
              child: Text(
                timeStr,
                style: GoogleFonts.cairo(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface.withOpacity(0.3)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
