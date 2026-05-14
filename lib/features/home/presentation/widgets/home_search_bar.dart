// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../search/presentation/pages/search_screen.dart';

class HomeSearchBar extends StatelessWidget {
  final String hint;
  final bool isDark;

  const HomeSearchBar({super.key, required this.hint, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => const SearchScreen(initialCategory: '')),
      ),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.06) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.1) : AppColors.border,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.15 : 0.04),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Icon(
              Icons.search_rounded,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                hint,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(6),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(11),
              ),
              child:
                  const Icon(Icons.tune_rounded, color: Colors.white, size: 16),
            ),
          ],
        ),
      ),
    );
  }
}
