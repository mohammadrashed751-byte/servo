import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';

class BookingTimePicker extends StatelessWidget {
  final Map<String, List<String>> timeSlots;
  final String selectedPeriod;
  final String? selectedTime;
  final ValueChanged<String> onPeriodChanged;
  final ValueChanged<String> onTimeChanged;

  const BookingTimePicker({
    super.key,
    required this.timeSlots,
    required this.selectedPeriod,
    required this.selectedTime,
    required this.onPeriodChanged,
    required this.onTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final times = timeSlots[selectedPeriod] ?? const <String>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pick time',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),

        SizedBox(height: responsiveHeight(context, 12)),

        Wrap(
          spacing: responsiveWidth(context, 8),
          runSpacing: responsiveHeight(context, 8),
          children: [
            for (final period in timeSlots.keys)
              ChoiceChip(
                label: Text(period),
                selected: selectedPeriod == period,
                showCheckmark: false,
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.surface,
                labelStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: selectedPeriod == period
                      ? AppColors.surface
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: responsiveWidth(context, 35),
                  vertical: responsiveHeight(context, 8),
                ),
                shape: const StadiumBorder(),
                side: BorderSide(
                  color: selectedPeriod == period
                      ? AppColors.primary
                      : AppColors.border,
                ),
                onSelected: (selected) {
                  if (selected) {
                    onPeriodChanged(period);
                  }
                },
              ),
          ],
        ),

        SizedBox(height: responsiveHeight(context, 12)),

        Wrap(
          spacing: responsiveWidth(context, 12),
          runSpacing: responsiveHeight(context, 8),
          children: [
            for (final time in times)
              ChoiceChip(
                label: Text(time),
                selected: selectedTime == time,
                showCheckmark: false,
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.surface,
                labelStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: selectedTime == time
                      ? AppColors.surface
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: responsiveWidth(context, 35),
                  vertical: responsiveHeight(context, 8),
                ),
                shape: const StadiumBorder(),
                side: BorderSide(
                  color: selectedTime == time
                      ? AppColors.primary
                      : AppColors.border,
                ),
                onSelected: (selected) {
                  if (selected) {
                    onTimeChanged(time);
                  }
                },
              ),
          ],
        ),
      ],
    );
  }
}
