// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_strings.dart';

/// Search bar and category chips header for the search screen.
class SearchHeader extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String query;
  final bool isArabic;
  final String selectedCategory;
  final List<Map<String, String>> categories;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<String> onCategorySelected;
  final VoidCallback onClear;
  final VoidCallback onBack;

  const SearchHeader({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.query,
    required this.isArabic,
    required this.selectedCategory,
    required this.categories,
    required this.onQueryChanged,
    required this.onCategorySelected,
    required this.onClear,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final strings = AppStrings(context);

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.fromLTRB(
              20, MediaQuery.of(context).padding.top + 10, 20, 20),
          decoration: BoxDecoration(
            color: (isDark ? Colors.black : Colors.white).withOpacity(0.2),
            border: Border(
                bottom: BorderSide(color: Colors.white.withOpacity(0.1))),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                        isArabic
                            ? Icons.arrow_forward_ios_rounded
                            : Icons.arrow_back_ios_rounded,
                        color: theme.colorScheme.onSurface,
                        size: 20),
                    onPressed: onBack,
                  ),
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: (isDark ? Colors.white : Colors.black)
                            .withOpacity(0.05),
                        borderRadius: BorderRadius.circular(25),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: TextField(
                        controller: controller,
                        focusNode: focusNode,
                        textDirection:
                            isArabic ? TextDirection.rtl : TextDirection.ltr,
                        onChanged: onQueryChanged,
                        style: GoogleFonts.cairo(
                            fontSize: 15, fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          hintText: strings.searchPlaceholder,
                          hintStyle: GoogleFonts.cairo(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.3)),
                          border: InputBorder.none,
                          prefixIcon: const Icon(Icons.search_rounded,
                              color: AppColors.primary, size: 22),
                          suffixIcon: query.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.close_rounded,
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.5),
                                      size: 18),
                                  onPressed: onClear,
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Categories Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: isArabic,
                child: Row(
                  children: categories.map((cat) {
                    final bool isSelected = selectedCategory == cat['key'];
                    return GestureDetector(
                      onTap: () => onCategorySelected(cat['key']!),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : (isDark
                                  ? Colors.white10
                                  : Colors.black.withOpacity(0.05)),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                      color: AppColors.primary.withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4))
                                ]
                              : [],
                        ),
                        child: Text(
                          cat['label']!,
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight:
                                isSelected ? FontWeight.w800 : FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
