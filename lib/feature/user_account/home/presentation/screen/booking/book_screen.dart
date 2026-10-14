import 'package:servo/core/network/marketplace_api.dart';
import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/utils/responsive.dart';

import '../../widgets/booking_time_picker.dart';
import 'booking_success_screen.dart';

class BookScreen extends StatefulWidget {
  const BookScreen({super.key, this.serviceId, this.api});
  final MarketplaceApi? api;
  final int? serviceId;

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
  bool _saving = false;
  String? _attemptKey;
  String? _attemptSignature;
  Future<void> _book() async {
    if (_saving || widget.serviceId == null) return;
    final date = _selectedDate ?? _today;
    final parts = _selectedTime!.split(RegExp(r'[: ]'));
    final hour = int.parse(parts[0]) % 12 + (parts[2] == 'PM' ? 12 : 0);
    final scheduled = DateTime(
      date.year,
      date.month,
      date.day,
      hour,
      int.parse(parts[1]),
    );
    if (!scheduled.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose a future date and time.')),
      );
      return;
    }
    final signature = '${widget.serviceId}-$scheduled';
    if (_attemptSignature != signature) {
      _attemptSignature = signature;
      _attemptKey =
          '${widget.serviceId}-${DateTime.now().microsecondsSinceEpoch}';
    }
    setState(() => _saving = true);
    try {
      await (widget.api ?? MarketplaceApi()).request(
        'bookings',
        method: 'POST',
        data: {
          'service_id': widget.serviceId,
          'scheduled_date':
              '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
          'scheduled_time': '${hour.toString().padLeft(2, '0')}:${parts[1]}',
          'idempotency_key': _attemptKey,
        },
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BookingSuccessScreen()),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

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

                      const Text(
                        'Choose your requested time. Confirmation depends on the provider.',
                      ),
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
                        onPressed:
                            !_saving &&
                                widget.serviceId != null &&
                                _agreeToTerms &&
                                _selectedTime != null
                            ? _book
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
