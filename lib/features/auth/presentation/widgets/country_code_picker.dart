// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

class CountryCode {
  final String name;
  final String nameAr;
  final String dialCode;
  final String flag;

  const CountryCode({
    required this.name,
    required this.nameAr,
    required this.dialCode,
    required this.flag,
  });
}

const List<CountryCode> countryCodes = [
  CountryCode(
      name: 'Saudi Arabia', nameAr: 'السعودية', dialCode: '+966', flag: '🇸🇦'),
  CountryCode(name: 'UAE', nameAr: 'الإمارات', dialCode: '+971', flag: '🇦🇪'),
  CountryCode(name: 'Egypt', nameAr: 'مصر', dialCode: '+20', flag: '🇪🇬'),
  CountryCode(name: 'Kuwait', nameAr: 'الكويت', dialCode: '+965', flag: '🇰🇼'),
  CountryCode(name: 'Qatar', nameAr: 'قطر', dialCode: '+974', flag: '🇶🇦'),
  CountryCode(
      name: 'Bahrain', nameAr: 'البحرين', dialCode: '+973', flag: '🇧🇭'),
  CountryCode(name: 'Oman', nameAr: 'عُمان', dialCode: '+968', flag: '🇴🇲'),
  CountryCode(name: 'Jordan', nameAr: 'الأردن', dialCode: '+962', flag: '🇯🇴'),
  CountryCode(name: 'Iraq', nameAr: 'العراق', dialCode: '+964', flag: '🇮🇶'),
  CountryCode(name: 'Lebanon', nameAr: 'لبنان', dialCode: '+961', flag: '🇱🇧'),
  CountryCode(
      name: 'Palestine', nameAr: 'فلسطين', dialCode: '+970', flag: '🇵🇸'),
  CountryCode(name: 'Syria', nameAr: 'سوريا', dialCode: '+963', flag: '🇸🇾'),
  CountryCode(name: 'Yemen', nameAr: 'اليمن', dialCode: '+967', flag: '🇾🇪'),
  CountryCode(name: 'Libya', nameAr: 'ليبيا', dialCode: '+218', flag: '🇱🇾'),
  CountryCode(name: 'Tunisia', nameAr: 'تونس', dialCode: '+216', flag: '🇹🇳'),
  CountryCode(
      name: 'Algeria', nameAr: 'الجزائر', dialCode: '+213', flag: '🇩🇿'),
  CountryCode(
      name: 'Morocco', nameAr: 'المغرب', dialCode: '+212', flag: '🇲🇦'),
  CountryCode(name: 'Sudan', nameAr: 'السودان', dialCode: '+249', flag: '🇸🇩'),
  CountryCode(name: 'Turkey', nameAr: 'تركيا', dialCode: '+90', flag: '🇹🇷'),
  CountryCode(
      name: 'Pakistan', nameAr: 'باكستان', dialCode: '+92', flag: '🇵🇰'),
  CountryCode(name: 'India', nameAr: 'الهند', dialCode: '+91', flag: '🇮🇳'),
  CountryCode(
      name: 'United States', nameAr: 'أمريكا', dialCode: '+1', flag: '🇺🇸'),
  CountryCode(
      name: 'United Kingdom',
      nameAr: 'بريطانيا',
      dialCode: '+44',
      flag: '🇬🇧'),
];

class CountryCodePicker extends StatelessWidget {
  final CountryCode selectedCountry;
  final ValueChanged<CountryCode> onChanged;
  final bool isArabic;

  const CountryCodePicker({
    super.key,
    required this.selectedCountry,
    required this.onChanged,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _showCountryPicker(context),
      child: Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selectedCountry.flag,
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(width: 6),
            Text(
              selectedCountry.dialCode,
              style: GoogleFonts.cairo(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: AppColors.primary.withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
  }

  void _showCountryPicker(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _CountryPickerSheet(
          isArabic: isArabic,
          isDark: isDark,
          theme: theme,
          onSelected: (country) {
            onChanged(country);
            Navigator.pop(ctx);
          },
        );
      },
    );
  }
}

class _CountryPickerSheet extends StatefulWidget {
  final bool isArabic;
  final bool isDark;
  final ThemeData theme;
  final ValueChanged<CountryCode> onSelected;

  const _CountryPickerSheet({
    required this.isArabic,
    required this.isDark,
    required this.theme,
    required this.onSelected,
  });

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  final _searchCtrl = TextEditingController();
  List<CountryCode> _filtered = countryCodes;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _filter(String query) {
    setState(() {
      if (query.isEmpty) {
        _filtered = countryCodes;
      } else {
        _filtered = countryCodes.where((c) {
          return c.name.toLowerCase().contains(query.toLowerCase()) ||
              c.nameAr.contains(query) ||
              c.dialCode.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: widget.theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: widget.theme.colorScheme.onSurface.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            widget.isArabic ? 'اختاري الدولة' : 'Select Country',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: widget.theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),

          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _filter,
              style: GoogleFonts.cairo(fontSize: 14),
              decoration: InputDecoration(
                hintText:
                    widget.isArabic ? 'ابحثي عن دولة...' : 'Search country...',
                hintStyle: GoogleFonts.cairo(
                  color: widget.theme.colorScheme.onSurface.withOpacity(0.4),
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: AppColors.primary.withOpacity(0.6),
                ),
                filled: true,
                fillColor: (widget.isDark ? Colors.white : Colors.black)
                    .withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // List
          Expanded(
            child: ListView.builder(
              itemCount: _filtered.length,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemBuilder: (_, index) {
                final country = _filtered[index];
                return ListTile(
                  onTap: () => widget.onSelected(country),
                  leading: Text(
                    country.flag,
                    style: const TextStyle(fontSize: 28),
                  ),
                  title: Text(
                    widget.isArabic ? country.nameAr : country.name,
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: widget.theme.colorScheme.onSurface,
                    ),
                  ),
                  trailing: Text(
                    country.dialCode,
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
