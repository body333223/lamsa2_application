// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_theme.dart';

/// The chat input bar with text field and send button.
class ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.sending,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: AppTheme.buildGlassContainer(
          context: context,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          opacity: isDark ? 0.15 : 0.6,
          borderRadius: BorderRadius.circular(32),
          child: Row(
            children: [
              AppTheme.buildGlassContainer(
                context: context,
                padding: EdgeInsets.zero,
                opacity: 0.1,
                borderRadius: BorderRadius.circular(24),
                child: IconButton(
                  icon: Icon(Icons.add_rounded, color: AppColors.primary),
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller,
                  style: GoogleFonts.cairo(
                      fontSize: 14, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    hintText: s.typeMessage,
                    hintStyle: GoogleFonts.cairo(
                        color: theme.colorScheme.onSurface.withOpacity(0.3)),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onSubmitted: (_) => onSend(),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: sending ? null : onSend,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.accent]),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 5)),
                    ],
                  ),
                  child: sending
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.send_rounded,
                          color: Colors.white, size: 22),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
