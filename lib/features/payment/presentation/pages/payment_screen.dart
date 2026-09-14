// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lamsa/core/localization/app_strings.dart' show AppStrings;
import 'package:lamsa/core/theme/app_theme.dart' show AppTheme, AppColors;
import 'package:lamsa/core/widgets/glow_orb.dart' show GlowOrb;
import 'package:lamsa/features/payment/presentation/pages/confirmation_screen.dart'
    show ConfirmationScreen;
import 'package:lamsa/features/payment/presentation/widgets/payment_method_tile.dart'
    show PaymentMethodTile;
import 'package:lamsa/features/payment/presentation/widgets/payment_summary.dart'
    show PaymentSummary;
import 'package:lamsa/services/data_service.dart' show DataService;
import 'package:lamsa/core/widgets/app_snackbar.dart';
import 'package:provider/provider.dart';
import '../../../../models/service_model.dart';
import '../../../../services/auth_service.dart';

class PaymentScreen extends StatefulWidget {
  final ServiceModel service;
  final String date;
  final String time;
  final String address;
  final double? latitude;
  final double? longitude;

  const PaymentScreen({
    super.key,
    required this.service,
    required this.date,
    required this.time,
    this.address = '',
    this.latitude,
    this.longitude,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _loading = false;
  String _selectedMethod = 'card';

  Future<void> _payNow() async {
    setState(() => _loading = true);

    try {
      final firestore = context.read<DataService>();
      final authService = context.read<AuthService>();
      final userId = authService.userId ?? '';

      // Get phone from Auth first, then Firestore
      String clientPhone = authService.currentUser?.phoneNumber ?? '';
      String clientName = authService.currentUser?.displayName ?? '';

      if (clientPhone.isEmpty || clientName.isEmpty) {
        final userData = await firestore.getUserData(userId);
        if (userData != null) {
          if (clientPhone.isEmpty) {
            clientPhone = (userData['phone'] ?? '').toString();
          }
          if (clientName.isEmpty) {
            clientName = (userData['name'] ?? '').toString();
          }
        }
      }

      final booking = await firestore.createBooking(
        userId: userId,
        serviceName: widget.service.name,
        price: widget.service.price,
        date: widget.date,
        time: widget.time,
        status: 'pending',
        serviceImageUrl: widget.service.imageUrl,
        location: widget.address,
        clientName: clientName,
        clientPhone: clientPhone,
        latitude: widget.latitude,
        longitude: widget.longitude,
      );

      final bookingId = booking.id;

      await firestore.confirmPayment(bookingId);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ConfirmationScreen(
            bookingId: bookingId,
            serviceName: widget.service.name,
            date: widget.date,
            time: widget.time,
            price: widget.service.price,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final s = AppStrings(context);
      AppSnackbar.show(context,
          message: '${s.errorOccurred}: $e', type: SnackType.error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(s.payment,
            style:
                GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 20)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 150,
            right: -100,
            child:
                GlowOrb(size: 300, color: AppColors.primary.withOpacity(0.1)),
          ),
          Positioned(
            bottom: 100,
            left: -100,
            child: GlowOrb(size: 250, color: AppColors.accent.withOpacity(0.1)),
          ),
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
                24, MediaQuery.of(context).padding.top + 80, 24, 40),
            child: Column(
              children: [
                // Price Card
                AppTheme.buildGlassContainer(
                  context: context,
                  padding: const EdgeInsets.all(32),
                  opacity: isDark ? 0.2 : 0.6,
                  borderRadius: BorderRadius.circular(32),
                  child: Column(
                    children: [
                      Text(s.totalAmount,
                          style: GoogleFonts.cairo(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface
                                  .withOpacity(0.5))),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '${widget.service.price.toInt()}',
                            style: GoogleFonts.cairo(
                                fontSize: 48,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            s.egp,
                            style: GoogleFonts.cairo(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary.withOpacity(0.7)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Booking Summary
                _SectionTitle(title: s.bookingSummary),
                const SizedBox(height: 16),
                PaymentSummary(
                  serviceLabel: s.service,
                  serviceName: widget.service.name,
                  dateLabel: s.date,
                  dateValue: widget.date,
                  timeLabel: s.time,
                  timeValue: widget.time,
                ),
                const SizedBox(height: 32),

                // Payment Methods
                _SectionTitle(title: s.paymentMethod),
                const SizedBox(height: 16),
                PaymentMethodTile(
                  id: 'card',
                  title: s.creditCard,
                  subtitle: 'Visa, Mastercard',
                  icon: Icons.credit_card_rounded,
                  selected: _selectedMethod == 'card',
                  onSelect: (id) => setState(() => _selectedMethod = id),
                ),
                const SizedBox(height: 12),
                PaymentMethodTile(
                  id: 'wallet',
                  title: s.digitalWallet,
                  subtitle: 'Apple Pay, Google Pay',
                  icon: Icons.account_balance_wallet_rounded,
                  selected: _selectedMethod == 'wallet',
                  onSelect: (id) => setState(() => _selectedMethod = id),
                ),
                const SizedBox(height: 40),

                // Pay Button
                AppTheme.buildGlassButton(
                  onPressed: _loading ? () {} : _payNow,
                  label: s.payNow,
                  isLoading: _loading,
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(s.cancel,
                      style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface.withOpacity(0.4))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(title,
          style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w800)),
    );
  }
}
