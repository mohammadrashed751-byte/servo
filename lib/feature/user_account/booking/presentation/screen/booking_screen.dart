import 'package:servo/core/network/marketplace_api.dart';
import 'package:servo/core/widgets/api_content.dart';
import 'package:servo/core/widgets/notifications_screen.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/utils/responsive.dart';
import '../widgets/card_booking.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});
  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  String _tab = 'active';
  int _revision = 0;
  Future<void> _refresh() async {
    if (mounted) setState(() => _revision++);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        backgroundColor: AppColors.dark,
        surfaceTintColor: AppColors.dark,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.grid_view_rounded, color: AppColors.surface),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 12,
              backgroundColor: AppColors.surface,
              child: Icon(
                Icons.diamond_rounded,
                size: 14,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Booking',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: AppColors.surface),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => Navigator.push<void>(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
            icon: const Icon(
              Icons.notifications_rounded,
              color: AppColors.surface,
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ColoredBox(
                  color: AppColors.surface,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsiveWidth(context, 24),
                      vertical: responsiveHeight(context, 13),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _tab == 'active'
                              ? 'Active bookings'
                              : _tab == 'completed'
                              ? 'Completed bookings'
                              : 'Cancelled bookings',
                          style: AppTextStyles.heavyTitle4,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            PopupMenuButton<String>(
                              tooltip: 'Filter bookings',
                              initialValue: _tab,
                              onSelected: (value) =>
                                  setState(() => _tab = value),
                              icon: const Icon(
                                Icons.tune_rounded,
                                color: AppColors.textPrimary,
                                size: 22,
                              ),
                              itemBuilder: (_) => const [
                                PopupMenuItem(
                                  value: 'active',
                                  child: Text('Active'),
                                ),
                                PopupMenuItem(
                                  value: 'completed',
                                  child: Text('Completed'),
                                ),
                                PopupMenuItem(
                                  value: 'cancelled',
                                  child: Text('Cancelled'),
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: _refresh,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: const Icon(
                                Icons.refresh,
                                color: AppColors.textPrimary,
                                size: 22,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(
                  height: responsiveHeight(context, 1),
                  thickness: 1,
                  color: AppColors.border,
                ),
                SizedBox(height: responsiveHeight(context, 12)),

                ApiContent<List<JsonMap>>(
                  key: ValueKey('$_tab-$_revision'),
                  load: () =>
                      MarketplaceApi().list('bookings', query: {'tab': _tab}),
                  builder: (context, bookings) => bookings.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(24),
                          child: Text('No bookings yet'),
                        )
                      : Column(
                          children: [
                            for (final booking in bookings)
                              CardBooking(
                                booking: booking,
                                onChanged: _refresh,
                                imagePath: apiText(
                                  apiMap(booking['service'])['thumbnail'],
                                ),
                                bookingNumber: '${booking['id']}',
                                status: apiText(booking['status']),
                              ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
