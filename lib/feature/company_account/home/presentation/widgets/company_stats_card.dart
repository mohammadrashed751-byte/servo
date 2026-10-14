import 'package:flutter/material.dart';
import 'package:servo/core/theme/app_colors.dart';
import 'package:servo/core/theme/app_theme.dart';
import 'package:servo/core/utils/responsive.dart';

class CompanyStatsCard extends StatelessWidget {
  const CompanyStatsCard({
    super.key,
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsiveWidth(context, 12),
        vertical: responsiveHeight(context, 24),
      ),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(
          responsiveWidth(context, 26),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.textTheme.bodySmall?.copyWith(
              color: AppColors.surface,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: responsiveHeight(context, 12)),
          Text(
            value,
            style: AppTextStyles.heavyTitle.copyWith(
              color: AppColors.surface,
            ),
          ),
        ],
      ),
    );
  }
}