import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/responsive.dart';

import '../../widgets/booking_time_picker.dart';
import 'booking_success_screen.dart';

class BookScreen extends StatefulWidget {
  const BookScreen({super.key});

  @override
  State<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  final DateTime _today = DateUtils.dateOnly(DateTime.now());

  DateTime? _selectedDate;
  String _selectedPeriod = 'Afternoon';
  String? _selectedTime;

  final Map<String, List<String>> _timeSlots = {
    'Afternoon': ['12:00 PM', '01:00 PM', '02:00 PM', '03:00 PM'],
    'Late Morning': ['10:00 AM', '10:30 AM', '11:00 AM', '11:30 AM'],
  };
  bool _agreeToTerms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        backgroundColor: AppColors.dark,
        surfaceTintColor: AppColors.dark,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.maybePop(context);
          },
          icon: const Icon(Icons.arrow_back, color: AppColors.surface),
        ),
        title: Text(
          'Book',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(color: AppColors.surface),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsiveWidth(context, 20),
                    vertical: responsiveHeight(context, 24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: Theme.of(context).colorScheme.copyWith(
                            primary: AppColors.primary,
                            onPrimary: AppColors.surface,
                            surface: AppColors.surface,
                            onSurface: AppColors.textPrimary,
                          ),
                        ),
                        child: CalendarDatePicker(
                          initialDate: _selectedDate ?? _today,
                          firstDate: _today,
                          lastDate: DateTime(
                            _today.year + 1,
                            _today.month,
                            _today.day,
                          ),
                          onDateChanged: (date) {
                            setState(() {
                              _selectedDate = date;
                            });
                          },
                        ),
                      ),

                      SizedBox(height: responsiveHeight(context, 20)),

                      BookingTimePicker(
                        timeSlots: _timeSlots,
                        selectedPeriod: _selectedPeriod,
                        selectedTime: _selectedTime,
                        onPeriodChanged: (period) {
                          setState(() {
                            _selectedPeriod = period;
                            _selectedTime = null;
                          });
                        },
                        onTimeChanged: (time) {
                          setState(() {
                            _selectedTime = time;
                          });
                        },
                      ),

                      SizedBox(height: responsiveHeight(context, 24)),

                      Row(
                        children: [
                          Checkbox(
                            value: _agreeToTerms,
                            activeColor: AppColors.primary,
                            checkColor: AppColors.surface,
                            onChanged: (value) {
                              setState(() {
                                _agreeToTerms = value ?? false;
                              });
                            },
                          ),
                          Expanded(
                            child: Text(
                              'I agree to the Terms & Conditions and Privacy Policy.',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                    height: 1.5,
                                  ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: responsiveHeight(context, 16)),

                      FilledButton(
                        onPressed: _agreeToTerms && _selectedTime != null
                            ? () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const BookingSuccessScreen(),
                                  ),
                                );
                                final bookingDate = _selectedDate ?? _today;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Selected appointment: '
                                      '${bookingDate.day}/'
                                      '${bookingDate.month}/'
                                      '${bookingDate.year}'
                                      ' at $_selectedTime',
                                    ),
                                  ),
                                );
                              }
                            : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.surface,
                          disabledBackgroundColor: AppColors.border,
                          disabledForegroundColor: AppColors.textSecondary,
                          minimumSize: Size(0, responsiveHeight(context, 56)),
                          padding: EdgeInsets.symmetric(
                            vertical: responsiveHeight(context, 14),
                            horizontal: responsiveWidth(context, 16),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              responsiveWidth(context, 16),
                            ),
                          ),
                        ),
                        child: Text(
                          'Booking',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: _agreeToTerms && _selectedTime != null
                                    ? AppColors.surface
                                    : AppColors.textSecondary,
                              ),
                        ),
                      ),

                      SizedBox(height: responsiveHeight(context, 12)),
                    ],
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
