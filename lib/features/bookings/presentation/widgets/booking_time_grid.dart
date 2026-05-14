// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../services/locale_service.dart';

/// Modern time picker with period tabs (Morning / Afternoon / Evening)
class BookingTimeGrid extends StatefulWidget {
  final List<String> slots;
  final List<String> periods;
  final TimeOfDay? selected;
  final void Function(String slot, String period) onSelect;

  const BookingTimeGrid({
    super.key,
    required this.slots,
    required this.periods,
    required this.selected,
    required this.onSelect,
  });

  @override
  State<BookingTimeGrid> createState() => _BookingTimeGridState();
}

class _BookingTimeGridState extends State<BookingTimeGrid> {
  int _selectedPeriod = 0; // 0=Morning, 1=Afternoon, 2=Evening

  // Categorize slots into periods
  List<_TimeSlot> get _morningSlots => _buildSlots(9, 12); // 9AM - 11:30AM
  List<_TimeSlot> get _afternoonSlots => _buildSlots(12, 17); // 12PM - 4:30PM
  List<_TimeSlot> get _eveningSlots => _buildSlots(17, 21); // 5PM - 8:30PM

  List<_TimeSlot> _buildSlots(int startHour, int endHour) {
    final slots = <_TimeSlot>[];
    for (int i = 0; i < widget.slots.length; i++) {
      final parts = widget.slots[i].split(':');
      int hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final period = widget.periods[i];

      // Convert to 24h
      int hour24 = hour;
      if (period == 'PM' && hour != 12) hour24 += 12;
      if (period == 'AM' && hour == 12) hour24 = 0;

      if (hour24 >= startHour && hour24 < endHour) {
        slots.add(_TimeSlot(
          display: '${widget.slots[i]} $period',
          hour24: hour24,
          minute: minute,
          slot: widget.slots[i],
          period: period,
        ));
      }
    }
    return slots;
  }

  List<_TimeSlot> get _currentSlots {
    switch (_selectedPeriod) {
      case 0:
        return _morningSlots;
      case 1:
        return _afternoonSlots;
      case 2:
        return _eveningSlots;
      default:
        return _morningSlots;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isArabic = context.watch<LocaleService>().isArabic;

    final periodLabels = isArabic
        ? ['صباحاً', 'ظهراً', 'مساءً']
        : ['Morning', 'Afternoon', 'Evening'];

    final periodIcons = [
      Icons.wb_sunny_rounded,
      Icons.wb_cloudy_rounded,
      Icons.nightlight_round,
    ];

    return Column(
      children: [
        // Period Tabs
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.grey.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: List.generate(3, (i) {
              final isActive = _selectedPeriod == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedPeriod = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isActive
                          ? (isDark ? AppColors.primary : Colors.white)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          periodIcons[i],
                          size: 16,
                          color: isActive
                              ? (isDark ? Colors.white : AppColors.primary)
                              : theme.colorScheme.onSurface.withOpacity(0.4),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          periodLabels[i],
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight:
                                isActive ? FontWeight.w800 : FontWeight.w600,
                            color: isActive
                                ? (isDark ? Colors.white : AppColors.primary)
                                : theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 20),

        // Time Slots Grid
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _currentSlots.isEmpty
              ? Padding(
                  key: ValueKey(_selectedPeriod),
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    isArabic ? 'لا توجد مواعيد متاحة' : 'No slots available',
                    style: GoogleFonts.cairo(
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
                )
              : GridView.builder(
                  key: ValueKey(_selectedPeriod),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 2.6,
                  ),
                  itemCount: _currentSlots.length,
                  itemBuilder: (context, index) {
                    final slot = _currentSlots[index];
                    final isSelected = widget.selected != null &&
                        widget.selected!.hour == slot.hour24 &&
                        widget.selected!.minute == slot.minute;

                    return GestureDetector(
                      onTap: () => widget.onSelect(slot.slot, slot.period),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : (isDark
                                  ? Colors.white.withOpacity(0.06)
                                  : Colors.white),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : (isDark
                                    ? Colors.white.withOpacity(0.1)
                                    : Colors.grey.withOpacity(0.15)),
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.25),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            slot.display,
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Colors.white
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _TimeSlot {
  final String display;
  final int hour24;
  final int minute;
  final String slot;
  final String period;

  const _TimeSlot({
    required this.display,
    required this.hour24,
    required this.minute,
    required this.slot,
    required this.period,
  });
}
