import 'package:flutter/material.dart';

import 'package:servo/core/theme/app_colors.dart';
import 'package:servo/core/utils/responsive.dart';

import '../widgets/notification_item.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

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
          'Notification',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(color: AppColors.surface),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ColoredBox(
                color: AppColors.surface,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsiveWidth(context, 24),
                    vertical: responsiveHeight(context, 24),
                  ),
                  child: Text(
                    'Today',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ),

              Divider(
                height: responsiveHeight(context, 1),
                thickness: 1,
                color: AppColors.border,
              ),

              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsiveWidth(context, 20),
                  ),
                  children: [
                    NotificationItem(
                      title: 'New Booking',
                      message:
                          'You have a new booking for Web Design '
                          'service at 3:00 PM tomorrow',
                      time: '13min',
                      backgroundColor: AppColors.primary.withAlpha(18),
                      icon: const Icon(
                        Icons.notifications_rounded,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),

                    const Divider(height: 1, color: AppColors.border),

                    NotificationItem(
                      title: 'Booking Confirmed',
                      message:
                          'Your booking for Logo Design '
                          'has been confirmed by the provider',
                      time: '1hr',
                      backgroundColor: AppColors.success.withAlpha(28),
                      icon: const Icon(
                        Icons.verified_rounded,
                        color: AppColors.success,
                        size: 28,
                      ),
                    ),

                    const Divider(height: 1, color: AppColors.border),

                    NotificationItem(
                      title: 'Booking Canceled',
                      message:
                          'Your booking for Social Media '
                          'Management has been canceled',
                      time: '1hr',
                      backgroundColor: AppColors.failed.withAlpha(25),
                      icon: const Text('🎉', style: TextStyle(fontSize: 28)),
                    ),

                    const Divider(height: 1, color: AppColors.border),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
