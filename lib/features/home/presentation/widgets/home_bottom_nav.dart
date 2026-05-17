// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_theme.dart';

class HomeBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const HomeBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(context);
    final items = [
      (s.home, Icons.home_rounded),
      (s.myBookings, Icons.calendar_month_rounded),
      (s.myAccount, Icons.person_rounded),
    ];

    return AppTheme.buildFloatingNav(
      context: context,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(items.length, (index) {
          final isActive = currentIndex == index;
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onTap(index),
              borderRadius: BorderRadius.circular(20),
              splashColor: AppColors.primary.withOpacity(0.1),
              highlightColor: AppColors.primary.withOpacity(0.05),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primary.withOpacity(0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedScale(
                      scale: isActive ? 1.15 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        items[index].$2,
                        color: isActive
                            ? AppColors.primary
                            : AppColors.textMedium.withOpacity(0.5),
                        size: 24,
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: isActive ? 4 : 0,
                    ),
                    AnimatedOpacity(
                      opacity: isActive ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: isActive
                          ? Text(
                              items[index].$1,
                              style: GoogleFonts.cairo(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
