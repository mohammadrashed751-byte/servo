import 'package:flutter/material.dart';

import 'package:servo/core/theme/app_colors.dart';
import 'package:servo/core/utils/responsive.dart';

class NotificationItem extends StatelessWidget {
  final String title;
  final String message;
  final String time;
  final Color backgroundColor;
  final Widget icon;

  const NotificationItem({
    super.key,
    required this.title,
    required this.message,
    required this.time,
    required this.backgroundColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final iconBoxSize = responsiveWidth(
      context,
      64,
    ).clamp(48.0, 72.0).toDouble();

    return Padding(
      padding: EdgeInsets.symmetric(vertical: responsiveHeight(context, 22)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: iconBoxSize,
            height: iconBoxSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(responsiveWidth(context, 22)),
            ),
            child: icon,
          ),

          SizedBox(width: responsiveWidth(context, 16)),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    SizedBox(width: responsiveWidth(context, 8)),

                    Text(
                      time,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppColors.grey),
                    ),
                  ],
                ),

                SizedBox(height: responsiveHeight(context, 6)),

                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
