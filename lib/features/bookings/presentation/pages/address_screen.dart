// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../services/locale_service.dart';

/// Modern address selection screen with GPS auto-detect.
class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final _addressCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _isLocating = false;
  bool _locationDetected = false;
  String? _detectedCity;
  double? _lat;
  double? _lng;
  String? _errorMessage;

  @override
  void dispose() {
    _addressCtrl.dispose();
    _notesCtrl.dispose();
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
          _errorMessage = 'إذن الموقع مرفوض نهائياً';
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

          final fullAddress = [
            place.street,
            place.subLocality,
            place.locality,
            place.administrativeArea,
          ].where((s) => s != null && s.isNotEmpty).join('، ');

          _addressCtrl.text = fullAddress;
        }
      } catch (_) {
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
      AppSnackbar.show(context,
          message: isArabic ? 'يرجى إدخال العنوان' : 'Please enter an address',
          type: SnackType.warning);
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          isArabic ? 'تحديد الموقع' : 'Select Location',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: theme.colorScheme.onSurface,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: theme.colorScheme.onSurface, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // ── GPS Detection Card ──
            _buildGpsCard(theme, isDark, isArabic),
            const SizedBox(height: 28),

            // ── Address Input ──
            _buildLabel(isArabic ? 'العنوان التفصيلي' : 'Detailed Address',
                Icons.location_on_rounded, theme),
            const SizedBox(height: 12),
            _buildInput(
              controller: _addressCtrl,
              hint: isArabic
                  ? 'شارع الملك فهد، عمارة ٥، شقة ١٢'
                  : 'King Fahd St, Building 5, Apt 12',
              icon: Icons.home_rounded,
              isDark: isDark,
              theme: theme,
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            // ── Notes Input ──
            _buildLabel(isArabic ? 'ملاحظات (اختياري)' : 'Notes (optional)',
                Icons.note_alt_rounded, theme),
            const SizedBox(height: 12),
            _buildInput(
              controller: _notesCtrl,
              hint: isArabic
                  ? 'الدور الثالث، الباب الأيمن...'
                  : '3rd floor, right door...',
              icon: Icons.edit_note_rounded,
              isDark: isDark,
              theme: theme,
              maxLines: 2,
            ),
            const SizedBox(height: 40),

            // ── Confirm Button ──
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _confirmAddress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_rounded, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      isArabic ? 'تأكيد الموقع' : 'Confirm Location',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ─── GPS Card ───────────────────────────────────────────────────────────

  Widget _buildGpsCard(ThemeData theme, bool isDark, bool isArabic) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.06) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _locationDetected
              ? AppColors.success.withOpacity(0.3)
              : isDark
                  ? Colors.white.withOpacity(0.08)
                  : AppColors.border.withOpacity(0.3),
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Icon + Status
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: _locationDetected
                      ? AppColors.success.withOpacity(0.12)
                      : AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _isLocating
                    ? Padding(
                        padding: const EdgeInsets.all(14),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.primary,
                        ),
                      )
                    : Icon(
                        _locationDetected
                            ? Icons.location_on_rounded
                            : Icons.my_location_rounded,
                        color: _locationDetected
                            ? AppColors.success
                            : AppColors.primary,
                        size: 24,
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _locationDetected
                          ? (isArabic ? 'تم تحديد الموقع' : 'Location found')
                          : _errorMessage != null
                              ? _errorMessage!
                              : (isArabic
                                  ? 'تحديد الموقع تلقائياً'
                                  : 'Auto-detect location'),
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _errorMessage != null
                            ? AppColors.error
                            : _locationDetected
                                ? AppColors.success
                                : theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _locationDetected && _detectedCity != null
                          ? _detectedCity!
                          : (isArabic
                              ? 'يستخدم GPS لتحديد موقعك'
                              : 'Uses GPS to find you'),
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Detect button
          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton.icon(
              onPressed: _isLocating ? null : _detectLocation,
              icon: Icon(
                _locationDetected
                    ? Icons.refresh_rounded
                    : Icons.gps_fixed_rounded,
                size: 18,
              ),
              label: Text(
                _isLocating
                    ? (isArabic ? 'جاري التحديد...' : 'Detecting...')
                    : _locationDetected
                        ? (isArabic ? 'تحديث الموقع' : 'Refresh')
                        : (isArabic ? 'حدّدي موقعي' : 'Detect my location'),
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary.withOpacity(0.4)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Helpers ────────────────────────────────────────────────────────────

  Widget _buildLabel(String text, IconData icon, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 18),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildInput({
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : AppColors.border.withOpacity(0.4),
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
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
          prefixIcon:
              Icon(icon, color: AppColors.primary.withOpacity(0.5), size: 20),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
