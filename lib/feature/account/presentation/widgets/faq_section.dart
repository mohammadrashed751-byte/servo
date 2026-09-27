import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';

class FaqEntry {
  const FaqEntry({
    required this.question,
    required this.answer,
    this.initiallyExpanded = false,
  });

  final String question;
  final String answer;
  final bool initiallyExpanded;
}

class FaqSection extends StatelessWidget {
  const FaqSection({super.key, required this.title, required this.entries});

  final String title;
  final List<FaqEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: AppTextStyles.textTheme.bodyMedium?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: responsiveHeight(context, 8)),
        for (final entry in entries) ...[
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.only(
              bottom: responsiveHeight(context, 16),
            ),
            expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
            shape: const Border(),
            collapsedShape: const Border(),
            iconColor: AppColors.textPrimary,
            collapsedIconColor: AppColors.textPrimary,
            title: Text(
              entry.question,
              style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            children: [
              Text(
                'A: ${entry.answer}',
                style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                  height: 1.8,
                ),
              ),
            ],
          ),
          const Divider(height: 1, thickness: 0.5, color: AppColors.border),
        ],
      ],
    );
  }
}
