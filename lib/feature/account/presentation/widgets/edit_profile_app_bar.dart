import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';

AppBar buildEditProfileAppBar(
  BuildContext context, {
  String title = 'Edit Profile',
  required VoidCallback onBack,
  required VoidCallback onNotifications,
}) {
  final textStyles = AppTextStyles.textTheme;
  return AppBar(
    backgroundColor: AppColors.dark,
    surfaceTintColor: AppColors.dark,
    elevation: 0,
    centerTitle: true,
    leading: IconButton(
      tooltip: 'Back',
      onPressed: onBack,
      icon: Icon(
        Icons.arrow_back,
        color: AppColors.surface,
        size: responsiveWidth(context, 24),
      ),
    ),
    title: Text(
      title,
      style: textStyles.headlineSmall?.copyWith(color: AppColors.surface),
    ),
    actions: [
      IconButton(
        tooltip: 'Notifications',
        onPressed: onNotifications,
        icon: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              Icons.notifications_rounded,
              color: AppColors.surface,
              size: responsiveWidth(context, 24),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: responsiveWidth(context, 5),
                height: responsiveWidth(context, 5),
                decoration: const BoxDecoration(
                  color: AppColors.sunsetOrange,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
