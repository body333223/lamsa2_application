// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

/// A modern chat message bubble widget.
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isAdmin ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isAdmin) ...[
            Container(
              width: 30,
              height: 30,
              margin: const EdgeInsets.only(bottom: 2, right: 8),
              // ignore: prefer_const_constructors
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  // ignore: prefer_const_literals_to_create_immutables
                  colors: [AppColors.primary, AppColors.accent],
                ),
              ),
              child: const Icon(Icons.support_agent_rounded,
                  size: 15, color: Colors.white),
            ),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isAdmin
                    ? (isDark
                        ? Colors.white.withOpacity(0.08)
                        : const Color(0xFFF2F2F7))
                    : AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isAdmin ? 4 : 20),
                  bottomRight: Radius.circular(isAdmin ? 20 : 4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                      color:
                          isAdmin ? theme.colorScheme.onSurface : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment:
                        isAdmin ? Alignment.bottomLeft : Alignment.bottomRight,
                    child: Text(
                      timeStr,
                      style: GoogleFonts.cairo(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isAdmin
                            ? theme.colorScheme.onSurface.withOpacity(0.35)
                            : Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!isAdmin) ...[
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}
