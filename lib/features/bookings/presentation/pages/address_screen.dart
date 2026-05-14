// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../services/locale_service.dart';

/// Screen for entering/selecting home address with real GPS location detection.
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
  String? _detectedAddress;
  double? _lat;
  double? _lng;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _detectLocation();
  }

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
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLocating = false;
          _errorMessage = 'يرجى تفعيل خدمات الموقع';
        });
        return;
      }

      // Check permissions
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

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _lat = position.latitude;
      _lng = position.longitude;

      // Reverse geocode to get address
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          _detectedAddress = [
            place.street,
            place.subLocality,
            place.locality,
            place.administrativeArea,
          ].where((s) => s != null && s.isNotEmpty).join('، ');

          _addressCtrl.text = _detectedAddress ?? '';
        }
      } catch (_) {
        // Geocoding failed but we still have coordinates
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
    if (_addressCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<LocaleService>().isArabic
                ? 'يرجى إدخال العنوان'
                : 'Please enter an address',
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          isArabic ? 'الموقع' : 'Location',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: theme.colorScheme.onSurface,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            isArabic
                ? Icons.arrow_forward_ios_rounded
                : Icons.arrow_back_ios_rounded,
            size: 20,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Map Preview / Location Card ──
            _LocationCard(
              isLocating: _isLocating,
              locationDetected: _locationDetected,
              detectedAddress: _detectedAddress,
              errorMessage: _errorMessage,
              lat: _lat,
              lng: _lng,
              onRetry: _detectLocation,
              isArabic: isArabic,
              isDark: isDark,
            ),
            const SizedBox(height: 28),

            // ── Address Input ──
            Text(
              isArabic ? 'العنوان التفصيلي' : 'Detailed Address',
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            _ModernTextField(
              controller: _addressCtrl,
              hint: isArabic
                  ? 'مثال: شارع الملك فهد، عمارة ٥، شقة ١٢'
                  : 'e.g. King Fahd St, Building 5, Apt 12',
              icon: Icons.home_rounded,
              isDark: isDark,
              maxLines: 2,
            ),
            const SizedBox(height: 20),

            // ── Notes Input ──
            Text(
              isArabic ? 'ملاحظات للسائق (اختياري)' : 'Driver Notes (optional)',
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            _ModernTextField(
              controller: _notesCtrl,
              hint: isArabic
                  ? 'مثال: الدور الثالث، الباب الأيمن'
                  : 'e.g. 3rd floor, right door',
              icon: Icons.note_alt_rounded,
              isDark: isDark,
              maxLines: 2,
            ),
            const SizedBox(height: 36),

            // ── Confirm Button ──
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _confirmAddress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  isArabic ? 'تأكيد الموقع' : 'Confirm Location',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Location Card with mini map placeholder ──────────────────────────────────

class _LocationCard extends StatelessWidget {
  final bool isLocating;
  final bool locationDetected;
  final String? detectedAddress;
  final String? errorMessage;
  final double? lat;
  final double? lng;
  final VoidCallback onRetry;
  final bool isArabic;
  final bool isDark;

  const _LocationCard({
    required this.isLocating,
    required this.locationDetected,
    required this.detectedAddress,
    required this.errorMessage,
    required this.lat,
    required this.lng,
    required this.onRetry,
    required this.isArabic,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.06) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: locationDetected
              ? AppColors.success.withOpacity(0.3)
              : (isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.12)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Mini map area
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.03)
                  : AppColors.primaryLight.withOpacity(0.3),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: isLocating
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 3,
                    ),
                  )
                : locationDetected
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          // Grid pattern to simulate map
                          GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 8,
                            ),
                            itemCount: 40,
                            itemBuilder: (_, __) => Container(
                              margin: const EdgeInsets.all(0.5),
                              color: (isDark ? Colors.white : AppColors.primary)
                                  .withOpacity(0.03),
                            ),
                          ),
                          // Pin icon
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.location_on_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (lat != null && lng != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${lat!.toStringAsFixed(4)}, ${lng!.toStringAsFixed(4)}',
                                    style: GoogleFonts.cairo(
                                      fontSize: 10,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_off_rounded,
                              size: 40,
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.3),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              errorMessage ??
                                  (isArabic
                                      ? 'اضغطي لتحديد الموقع'
                                      : 'Tap to detect location'),
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                color: errorMessage != null
                                    ? AppColors.error
                                    : theme.colorScheme.onSurface
                                        .withOpacity(0.4),
                              ),
                            ),
                          ],
                        ),
                      ),
          ),

          // Bottom info section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: locationDetected
                        ? AppColors.success.withOpacity(0.12)
                        : AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    locationDetected
                        ? Icons.check_circle_rounded
                        : Icons.my_location_rounded,
                    color: locationDetected
                        ? AppColors.success
                        : AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        locationDetected
                            ? (isArabic
                                ? 'تم تحديد الموقع ✓'
                                : 'Location detected ✓')
                            : (isArabic ? 'تحديد الموقع' : 'Detect Location'),
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: locationDetected
                              ? AppColors.success
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      if (detectedAddress != null)
                        Text(
                          detectedAddress!,
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                // Retry/Refresh button
                GestureDetector(
                  onTap: onRetry,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isLocating
                          ? Icons.hourglass_top_rounded
                          : Icons.refresh_rounded,
                      color: AppColors.primary,
                      size: 20,
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
}

// ── Modern Text Field ────────────────────────────────────────────────────────

class _ModernTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool isDark;
  final int maxLines;

  const _ModernTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.isDark,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.06) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.grey.withOpacity(0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.1 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
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
