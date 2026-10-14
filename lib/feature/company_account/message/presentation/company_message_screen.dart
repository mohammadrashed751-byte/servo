import 'package:servo/core/widgets/notifications_screen.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/responsive.dart';
import 'package:servo/core/widgets/conversations_list.dart';

class CompanyMessageScreen extends StatelessWidget {
  const CompanyMessageScreen({super.key});

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
            SizedBox(width: responsiveWidth(context, 8)),
            Text(
              'Messages',
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
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: ConversationsList(company: true),
        ),
      ),
    );
  }
}
