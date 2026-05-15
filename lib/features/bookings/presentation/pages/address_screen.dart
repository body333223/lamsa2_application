// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../services/locale_service.dart';

/// Modern address selection screen with GPS auto-detect.
class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen>
    with SingleTickerProviderStateMixin {
  final _addressCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _isLocating = false;
  bool _locationDetected = false;
  String? _detectedCity;
  String? _detectedStreet;
  double? _lat;
  double? _lng;
  String? _errorMessage;

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    _notesCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _detectLocation() async {
    setState(() {
      _isLocating = true;
      _errorMessage = null;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLocating = false;
          _errorMessage = 'يرجى تفعيل خدمات الموقع';
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLocating = false;
            _errorMessage = 'تم رفض إذن الموقع';
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLocating = false;
          _errorMessage = 'إذن الموقع مرفوض نهائياً. فعّليه من الإعدادات';
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _lat = position.latitude;
      _lng = position.longitude;

      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          _detectedCity = place.locality ?? place.administrativeArea ?? '';
          _detectedStreet = place.street ?? '';

          final fullAddress = [
            place.street,
            place.subLocality,
            place.locality,
            place.administrativeArea,
          ].where((s) => s != null && s.isNotEmpty).join('، ');

          _addressCtrl.text = fullAddress;
        }
      } catch (_) {
        // Geocoding failed but we still have coordinates
        _detectedCity =
            '${_lat!.toStringAsFixed(4)}, ${_lng!.toStringAsFixed(4)}';
      }

      if (mounted) {
        setState(() {
          _isLocating = false;
          _locationDetected = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLocating = false;
          _errorMessage = 'تعذر تحديد الموقع';
        });
      }
    }
  }

  void _confirmAddress() {
    final isArabic = context.read<LocaleService>().isArabic;
    if (_addressCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic ? 'يرجى إدخال العنوان' : 'Please enter an address',
            style: GoogleFonts.cairo(),
          ),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    Navigator.pop(context, {
      'address': _addressCtrl.text.trim(),
      'notes': _notesCtrl.text.trim(),
      'lat': _lat,
      'lng': _lng,
    });
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LocaleService>().isArabic;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App Bar ──
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            pinned: true,
            centerTitle: true,
            title: Text(
              isArabic ? 'تحديد الموقع' : 'Select Location',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                color: theme.colorScheme.onSurface,
              ),
            ),
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                decoration: BoxDecoration(
                  color:
                      (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(
                    isArabic
                        ? Icons.arrow_forward_ios_rounded
                        : Icons.arrow_back_ios_rounded,
                    size: 18,
                    color: theme.colorScheme.onSurface,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 20),

                // ── GPS Location Card ──
                _buildLocationCard(theme, isDark, isArabic),
                const SizedBox(height: 28),

                // ── Address Input Section ──
                _buildSectionTitle(
                  isArabic ? 'العنوان التفصيلي' : 'Detailed Address',
                  Icons.edit_location_alt_rounded,
                  theme,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _addressCtrl,
                  hint: isArabic
                      ? 'شارع الملك فهد، عمارة ٥، شقة ١٢'
                      : 'King Fahd St, Building 5, Apt 12',
                  icon: Icons.home_rounded,
                  isDark: isDark,
                  maxLines: 2,
                  theme: theme,
                ),
                const SizedBox(height: 20),

                // ── Notes Section ──
                _buildSectionTitle(
                  isArabic ? 'ملاحظات (اختياري)' : 'Notes (optional)',
                  Icons.sticky_note_2_rounded,
                  theme,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _notesCtrl,
                  hint: isArabic
                      ? 'الدور الثالث، الباب الأيمن...'
                      : '3rd floor, right door...',
                  icon: Icons.note_alt_rounded,
                  isDark: isDark,
                  maxLines: 2,
                  theme: theme,
                ),
                const SizedBox(height: 36),

                // ── Confirm Button ──
                Container(
                  width: double.infinity,
                  height: 58,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.accent],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _confirmAddress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_rounded,
                            color: Colors.white, size: 22),
                        const SizedBox(width: 10),
                        Text(
                          isArabic ? 'تأكيد الموقع' : 'Confirm Location',
                          style: GoogleFonts.cairo(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(ThemeData theme, bool isDark, bool isArabic) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: _locationDetected
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.success.withOpacity(isDark ? 0.15 : 0.08),
                  AppColors.success.withOpacity(isDark ? 0.05 : 0.02),
                ],
              )
            : null,
        color: _locationDetected
            ? null
            : (isDark ? Colors.white.withOpacity(0.06) : Colors.white),
        border: Border.all(
          color: _locationDetected
              ? AppColors.success.withOpacity(0.3)
              : (isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.grey.withOpacity(0.1)),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _locationDetected
                ? AppColors.success.withOpacity(0.1)
                : Colors.black.withOpacity(isDark ? 0.15 : 0.04),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top visual area
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: _locationDetected
                    ? [
                        AppColors.success.withOpacity(isDark ? 0.2 : 0.12),
                        AppColors.success.withOpacity(isDark ? 0.05 : 0.03),
                      ]
                    : [
                        AppColors.primary.withOpacity(isDark ? 0.15 : 0.08),
                        AppColors.primary.withOpacity(isDark ? 0.03 : 0.01),
                      ],
              ),
            ),
            child: _isLocating
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 44,
                          height: 44,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: AppColors.primary,
                            backgroundColor:
                                AppColors.primary.withOpacity(0.15),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          isArabic
                              ? 'جاري تحديد موقعك...'
                              : 'Detecting location...',
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  )
                : _locationDetected
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.success.withOpacity(0.3),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.location_on_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (_detectedCity != null)
                              Text(
                                _detectedCity!,
                                style: GoogleFonts.cairo(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            if (_detectedStreet != null &&
                                _detectedStreet!.isNotEmpty)
                              Text(
                                _detectedStreet!,
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.5),
                                ),
                              ),
                          ],
                        ),
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedBuilder(
                              animation: _pulseAnim,
                              builder: (_, child) => Transform.scale(
                                scale: _pulseAnim.value,
                                child: child,
                              ),
                              child: Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.location_searching_rounded,
                                  color: AppColors.primary,
                                  size: 28,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _errorMessage ??
                                  (isArabic
                                      ? 'اضغطي لتحديد موقعك'
                                      : 'Tap to detect your location'),
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _errorMessage != null
                                    ? AppColors.error
                                    : theme.colorScheme.onSurface
                                        .withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
          ),

          // Bottom action area
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Status icon
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: _locationDetected
                        ? AppColors.success.withOpacity(0.12)
                        : AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    _locationDetected
                        ? Icons.check_circle_rounded
                        : Icons.gps_fixed_rounded,
                    color: _locationDetected
                        ? AppColors.success
                        : AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),

                // Status text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _locationDetected
                            ? (isArabic
                                ? 'تم تحديد الموقع ✓'
                                : 'Location detected ✓')
                            : (isArabic
                                ? 'تحديد الموقع تلقائياً'
                                : 'Auto-detect location'),
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: _locationDetected
                              ? AppColors.success
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        _locationDetected
                            ? (isArabic
                                ? 'اضغطي لتحديث الموقع'
                                : 'Tap to refresh')
                            : (isArabic
                                ? 'يستخدم GPS لتحديد موقعك'
                                : 'Uses GPS to find you'),
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          color: theme.colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                ),

                // Action button
                GestureDetector(
                  onTap: _isLocating ? null : _detectLocation,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isLocating
                              ? Icons.hourglass_top_rounded
                              : Icons.my_location_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _locationDetected
                              ? (isArabic ? 'تحديث' : 'Refresh')
                              : (isArabic ? 'حدّدي' : 'Detect'),
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, ThemeData theme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    required ThemeData theme,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.06) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.grey.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.1 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.cairo(
            color: theme.colorScheme.onSurface.withOpacity(0.3),
            fontSize: 13,
          ),
          prefixIcon: Icon(
            icon,
            color: AppColors.primary.withOpacity(0.6),
            size: 22,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
