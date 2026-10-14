import 'package:servo/core/widgets/service_image.dart';
import 'company_service_filter.dart';
import 'package:flutter/material.dart';
import 'package:servo/core/theme/app_colors.dart';
import 'package:servo/core/theme/app_theme.dart';
import 'package:servo/core/utils/responsive.dart';

class CompanyServiceCard extends StatelessWidget {
  const CompanyServiceCard({
    super.key,
    required this.id,
    required this.title,
    required this.date,
    required this.imagePath,
    required this.isActive,
    this.description,
    this.status,
  });

  final String id;
  final String title;
  final String date;
  final String imagePath;
  final bool isActive;
  final CompanyServiceStatus? status;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsiveWidth(context, 10),
        vertical: responsiveHeight(context, 10),
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(responsiveWidth(context, 24)),
        boxShadow: [
          BoxShadow(
            color: AppColors.dark.withAlpha(15),
            blurRadius: responsiveWidth(context, 12),
            offset: Offset(0, responsiveHeight(context, 3)),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(responsiveWidth(context, 20)),
            child: ServiceImage(
              imagePath,
              width: responsiveWidth(context, 110),
              height: responsiveHeight(context, 125),
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: responsiveWidth(context, 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: responsiveWidth(context, 8),
                  runSpacing: responsiveHeight(context, 6),
                  children: [
                    _buildBadge(
                      context,
                      label: '#$id',
                      color: AppColors.primary,
                    ),
                    _buildBadge(
                      context,
                      label: status?.label ?? (isActive ? 'Active' : 'Pending'),
                      color: status == CompanyServiceStatus.completed
                          ? AppColors.textSecondary
                          : isActive
                          ? AppColors.success
                          : AppColors.pending,
                    ),
                  ],
                ),
                SizedBox(height: responsiveHeight(context, 12)),
                Text(date, style: AppTextStyles.textTheme.bodySmall),
                SizedBox(height: responsiveHeight(context, 4)),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (description != null) ...[
                  SizedBox(height: responsiveHeight(context, 4)),
                  Text(
                    description!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(
    BuildContext context, {
    required String label,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsiveWidth(context, 14),
        vertical: responsiveHeight(context, 10),
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(responsiveWidth(context, 30)),
      ),
      child: Text(
        label,
        style: AppTextStyles.textTheme.bodySmall?.copyWith(
          color: AppColors.surface,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
