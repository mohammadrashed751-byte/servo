import 'package:servo/core/widgets/booking_actions_menu.dart';
import 'package:servo/feature/user_account/home/presentation/widgets/experience_review_sheet.dart';
import 'package:servo/core/network/marketplace_api.dart';
import 'package:servo/core/widgets/service_image.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/utils/responsive.dart';
import '../../../../../core/widgets/chat_screen.dart';

class CardBooking extends StatelessWidget {
  final JsonMap booking;
  final Future<void> Function()? onChanged;
  final String imagePath;
  final String? logoPath;
  final String bookingNumber;
  final String status;

  const CardBooking({
    super.key,
    required this.imagePath,
    required this.bookingNumber,
    required this.status,
    this.logoPath,
    this.booking = const {},
    this.onChanged,
  });

  Color _statusColor() {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        responsiveWidth(context, 4),
        responsiveHeight(context, 4),
        responsiveWidth(context, 12),
        responsiveHeight(context, 16),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(responsiveWidth(context, 24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(12),
              blurRadius: responsiveWidth(context, 10),
              offset: Offset(0, responsiveHeight(context, 3)),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: responsiveHeight(context, 8),
            horizontal: responsiveWidth(context, 8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          responsiveWidth(context, 20),
                        ),
                        child: AspectRatio(
                          aspectRatio: 2.8,
                          child: ServiceImage(imagePath, fit: BoxFit.cover),
                        ),
                      ),
                      SizedBox(height: responsiveWidth(context, 10)),
                    ],
                  ),

                  Positioned(
                    bottom: responsiveHeight(context, 30),
                    left: responsiveWidth(context, 20),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: responsiveWidth(context, 20),
                        vertical: responsiveHeight(context, 8),
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '#$bookingNumber',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.surface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: responsiveHeight(context, 30),
                    right: responsiveWidth(context, 20),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: responsiveWidth(context, 25),
                        vertical: responsiveHeight(context, 15),
                      ),
                      decoration: BoxDecoration(
                        color: _statusColor(),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.surface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(
                  responsiveWidth(context, 10),
                  0,
                  responsiveWidth(context, 10),
                  responsiveHeight(context, 8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      apiText(booking['scheduled_date']),
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppColors.grey),
                    ),
                    Text(
                      apiText(apiMap(booking['service'])['title']),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      apiText(apiMap(booking['service'])['description']),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: responsiveHeight(context, 8)),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: responsiveWidth(context, 0),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: responsiveWidth(context, 50),
                            height: responsiveWidth(context, 50),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(
                                responsiveWidth(context, 14),
                              ),
                              border: Border.all(
                                color: AppColors.primary,
                                width: 1.5,
                              ),
                            ),
                            child: ServiceImage(
                              apiText(apiMap(booking['provider'])['avatar']),
                              isAvatar: true,
                              fit: BoxFit.contain,
                            ),
                          ),
                          SizedBox(width: responsiveWidth(context, 6)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  apiText(apiMap(booking['provider'])['name']),
                                  style: AppTextStyles.heavyTitle3,
                                ),
                                SizedBox(height: responsiveHeight(context, 6)),
                              ],
                            ),
                          ),
                          if (booking['id'] != null)
                            BookingActionsMenu(
                              id: '${booking['id']}',
                              status: status,
                              onChanged: onChanged ?? () async {},
                              onReview: () async {
                                await showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  useSafeArea: true,
                                  builder: (_) => ExperienceReviewSheet(
                                    onSubmit: (rating, review) async {
                                      await MarketplaceApi().request(
                                        'bookings/${booking['id']}/review',
                                        method: 'POST',
                                        data: {
                                          'rating': rating,
                                          'comment': review,
                                        },
                                      );
                                    },
                                  ),
                                );
                                await onChanged?.call();
                              },
                            ),
                          IconButton(
                            tooltip: 'Message provider',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                    bookingId: '${booking['id']}',
                                    name: apiText(
                                      apiMap(booking['provider'])['name'],
                                    ),
                                    avatar: apiText(
                                      apiMap(booking['provider'])['avatar'],
                                    ),
                                  ),
                                ),
                              );
                            },
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.primary.withAlpha(20),
                              foregroundColor: AppColors.primary,
                              shape: const CircleBorder(),
                            ),
                            icon: const Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
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
