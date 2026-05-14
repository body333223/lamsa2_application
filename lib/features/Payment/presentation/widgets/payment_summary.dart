// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

/// Displays the booking summary section in the payment screen.
class PaymentSummary extends StatelessWidget {
  final String serviceLabel;
  final String serviceName;
  final String dateLabel;
  final String dateValue;
  final String timeLabel;
  final String timeValue;

  const PaymentSummary({
    super.key,
    required this.serviceLabel,
    required this.serviceName,
    required this.dateLabel,
    required this.dateValue,
    required this.timeLabel,
    required this.timeValue,
  });

  @override
  Widget build(BuildContext context) {
    return AppTheme.buildGlassContainer(
      context: context,
      padding: const EdgeInsets.all(24),
      opacity: 0.1,
      borderRadius: BorderRadius.circular(28),
      child: Column(
        children: [
          _SummaryRow(label: serviceLabel, value: serviceName),
          const SizedBox(height: 12),
          _SummaryRow(label: dateLabel, value: dateValue),
          const SizedBox(height: 12),
          _SummaryRow(label: timeLabel, value: timeValue),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface.withOpacity(0.4))),
        Text(value,
            style:
                GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w800)),
      ],
    );
  }
}
