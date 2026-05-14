// ignore_for_file: deprecated_member_use, unused_field, unused_field, duplicate_ignore, duplicate_ignore

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../models/service_model.dart';
import '../../../../services/locale_service.dart';
import '../../../Payment/presentation/pages/payment_screen.dart';
import '../widgets/booking_address_card.dart';
import '../widgets/booking_date_picker.dart';
import '../widgets/booking_time_grid.dart';
import '../widgets/booking_price_summary.dart';
import 'address_screen.dart';

class BookingScreen extends StatefulWidget {
  final ServiceModel service;
  final String therapist;
  final String serviceName;

  const BookingScreen({
    super.key,
    required this.service,
    required this.therapist,
    required this.serviceName,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _address;
  // ignore: unused_field
  double? _lat;
  double? _lng;

  static const List<String> _timeSlots = [
    '09:00',
    '09:30',
    '10:00',
    '10:30',
    '11:00',
    '11:30',
    '12:00',
    '12:30',
    '01:00',
    '01:30',
    '02:00',
    '02:30',
    '03:00',
    '03:30',
    '04:00',
    '04:30',
    '05:00',
    '05:30',
    '06:00',
    '06:30',
    '07:00',
    '07:30',
    '08:00',
    '08:30',
  ];

  static const List<String> _timePeriods = [
    'AM',
    'AM',
    'AM',
    'AM',
    'AM',
    'AM',
    'PM',
    'PM',
    'PM',
    'PM',
    'PM',
    'PM',
    'PM',
    'PM',
    'PM',
    'PM',
    'PM',
    'PM',
    'PM',
    'PM',
    'PM',
    'PM',
    'PM',
    'PM',
  ];

  void _goToPayment() {
    if (_selectedDate == null || _selectedTime == null || _address == null) {
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          service: widget.service,
          date:
              '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
          time: _selectedTime!.format(context),
          address: _address!,
          latitude: _lat,
          longitude: _lng,
        ),
      ),
    );
  }

  Future<void> _openAddressScreen() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const AddressScreen()),
    );
    if (result != null && mounted) {
      setState(() {
        _address = result['address'] as String?;
        _lat = result['lat'] as double?;
        _lng = result['lng'] as double?;
      });
    }
  }

  Future<void> _checkTimeConflict(TimeOfDay time) async {
    if (_selectedDate == null) {
      setState(() => _selectedTime = time);
      return;
    }

    final isArabic = context.read<LocaleService>().isArabic;

    // منع حجز وقت في الماضي (نفس اليوم بس وقت فات)
    final now = DateTime.now();
    if (_selectedDate!.year == now.year &&
        _selectedDate!.month == now.month &&
        _selectedDate!.day == now.day) {
      final selectedDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        time.hour,
        time.minute,
      );
      if (selectedDateTime.isBefore(now)) {
        if (mounted) {
          _showTimeError(
            icon: Icons.history_rounded,
            title: isArabic ? 'الوقت فات' : 'Time Passed',
            message: isArabic
                ? 'هذا الوقت فات، اختاري وقت آخر'
                : 'This time has passed, choose another time',
          );
        }
        return;
      }
    }

    final dateStr =
        '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}';

    // Check if ANY user has a booking at this date/time (global conflict)
    final snapshot = await FirebaseFirestore.instance
        .collection('bookings')
        .where('date', isEqualTo: dateStr)
        .where('time', isEqualTo: time.format(context))
        .where('status',
            whereIn: ['pending', 'confirmed', 'pending_payment']).get();

    if (snapshot.docs.isNotEmpty && mounted) {
      _showTimeError(
        icon: Icons.event_busy_rounded,
        title: isArabic ? 'الوقت غير متاح' : 'Time Unavailable',
        message: isArabic
            ? 'هذا الوقت محجوز، اختاري وقت آخر'
            : 'This time is booked, choose another time',
      );
      return;
    }

    if (mounted) {
      setState(() => _selectedTime = time);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(context);
    final isArabic = context.watch<LocaleService>().isArabic;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final canProceed =
        _selectedDate != null && _selectedTime != null && _address != null;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background Orbs
          Positioned(
            top: 100,
            left: -50,
            child:
                _GlowOrb(size: 250, color: AppColors.primary.withOpacity(0.1)),
          ),
          Positioned(
            bottom: 100,
            right: -50,
            child:
                _GlowOrb(size: 200, color: AppColors.accent.withOpacity(0.1)),
          ),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Custom Header
              SliverToBoxAdapter(
                child: _buildHeader(theme, isDark, isArabic),
              ),

              // Content
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // ── Step 1: Address ──
                    _SectionHeader(
                      title: isArabic ? '١. عنوان المنزل' : '1. Home Address',
                      icon: Icons.location_on_rounded,
                    ),
                    const SizedBox(height: 16),
                    BookingAddressCard(
                      address: _address,
                      onTap: _openAddressScreen,
                      isArabic: isArabic,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 32),

                    // ── Step 2: Date ──
                    _SectionHeader(
                      title: isArabic ? '٢. اختاري التاريخ' : '2. Choose Date',
                      icon: Icons.calendar_month_rounded,
                    ),
                    const SizedBox(height: 16),
                    BookingDatePicker(
                      selected: _selectedDate,
                      onSelect: (d) => setState(() => _selectedDate = d),
                    ),
                    const SizedBox(height: 32),

                    // ── Step 3: Time ──
                    _SectionHeader(
                      title: isArabic ? '٣. اختاري الوقت' : '3. Choose Time',
                      icon: Icons.access_time_rounded,
                    ),
                    const SizedBox(height: 16),
                    BookingTimeGrid(
                      slots: _timeSlots,
                      periods: _timePeriods,
                      selected: _selectedTime,
                      onSelect: (slot, period) {
                        final parts = slot.split(':');
                        int hour = int.parse(parts[0]);
                        final minute = int.parse(parts[1]);
                        // Convert 12h to 24h for TimeOfDay
                        if (period == 'PM' && hour != 12) hour += 12;
                        if (period == 'AM' && hour == 12) hour = 0;
                        final selectedTime =
                            TimeOfDay(hour: hour, minute: minute);
                        _checkTimeConflict(selectedTime);
                      },
                    ),
                    const SizedBox(height: 40),

                    BookingPriceSummary(
                      price: widget.service.price,
                      currency: s.egp,
                      totalLabel: s.totalPrice,
                      isArabic: isArabic,
                    ),
                    const SizedBox(height: 32),

                    // CTA Button
                    AppTheme.buildGlassButton(
                      onPressed: canProceed ? _goToPayment : () {},
                      label: s.proceedToPayment,
                    ),
                    const SizedBox(height: 80),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showTimeError({
    required IconData icon,
    required String title,
    required String message,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: isDark ? const Color(0xFF1E1C20) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.error, size: 30),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'حسناً',
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isDark, bool isArabic) {
    return SizedBox(
      height: 300,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              widget.service.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryLight, AppColors.primary],
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    theme.scaffoldBackgroundColor,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: isArabic ? null : 20,
            left: isArabic ? 20 : null,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: IconButton(
                icon: Icon(
                  isArabic
                      ? Icons.arrow_forward_ios_rounded
                      : Icons.arrow_back_ios_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.service.name,
                  style: GoogleFonts.cairo(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        color: AppColors.gold, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.service.rating} • ${widget.service.durationMinutes} ${isArabic ? 'دقيقة' : 'min'}',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Private helpers ───────────────────────────────────────────────────────────

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;
  const _GlowOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(color: color, blurRadius: 50, spreadRadius: 15),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
