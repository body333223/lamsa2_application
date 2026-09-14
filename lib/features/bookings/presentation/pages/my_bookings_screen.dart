// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../models/booking_model.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/data_service.dart';
import '../../../../services/locale_service.dart';
import '../widgets/booking_card.dart';
import '../widgets/empty_bookings.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  List<BookingModel> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    final auth = context.read<AuthService>();
    if (!auth.isLoggedIn) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final data = context.read<DataService>();
      final bookings = await data.getUserBookings();
      // Sort newest first
      bookings.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      setState(() {
        _bookings = bookings;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LocaleService>().isArabic;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final auth = context.read<AuthService>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _loadBookings,
        color: AppColors.primary,
        backgroundColor: theme.scaffoldBackgroundColor,
        displacement: 60,
        strokeWidth: 2.5,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Stack(
                children: [
                  Positioned(
                    top: -60,
                    right: -40,
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            AppColors.primary.withOpacity(isDark ? 0.2 : 0.3),
                      ),
                    ),
                  ),
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(40)),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                      child: Container(
                        padding: EdgeInsets.fromLTRB(
                          24,
                          MediaQuery.of(context).padding.top + 24,
                          24,
                          30,
                        ),
                        decoration: BoxDecoration(
                          color: (isDark ? Colors.black : Colors.white)
                              .withOpacity(0.3),
                          borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(40)),
                          border: Border(
                            bottom: BorderSide(
                              color:
                                  Colors.white.withOpacity(isDark ? 0.05 : 0.4),
                              width: 1.5,
                            ),
                          ),
                        ),
                        child: Row(
                          textDirection:
                              isArabic ? TextDirection.rtl : TextDirection.ltr,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.15),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: AppColors.primary.withOpacity(0.3)),
                              ),
                              child: const Icon(Icons.calendar_month_rounded,
                                  color: AppColors.primary, size: 28),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              isArabic ? 'حجوزاتي' : 'My Bookings',
                              style: GoogleFonts.cairo(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: theme.colorScheme.onSurface,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bookings list
            SliverPadding(
              padding: const EdgeInsets.only(
                  top: 32, left: 24, right: 24, bottom: 120),
              sliver: !auth.isLoggedIn
                  ? SliverToBoxAdapter(
                      child: EmptyBookings(isArabic: isArabic),
                    )
                  : _isLoading
                      ? SliverToBoxAdapter(
                          child: Column(
                            children: List.generate(
                              3,
                              (_) => _BookingShimmer(isDark: isDark),
                            ),
                          ),
                        )
                      : _bookings.isEmpty
                          ? SliverToBoxAdapter(
                              child: EmptyBookings(isArabic: isArabic),
                            )
                          : SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, i) => BookingCard(
                                    booking: _bookings[i], isArabic: isArabic),
                                childCount: _bookings.length,
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingShimmer extends StatelessWidget {
  final bool isDark;
  const _BookingShimmer({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      height: 150,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(32),
      ),
    );
  }
}
