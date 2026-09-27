import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'experience_review_sheet.dart';

class ExperienceReviewLauncher {
  ExperienceReviewLauncher._();

  static void showAfterBuild(
    BuildContext context, {
    ValueChanged<Map<String, Object>>? onSubmitted,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!context.mounted) return;

      final review = await showModalBottomSheet<Map<String, Object>>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        showDragHandle: true,
        backgroundColor: AppColors.surface,
        barrierColor: Colors.black54,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        clipBehavior: Clip.antiAlias,
        builder: (context) {
          return const ExperienceReviewSheet();
        },
      );

      if (!context.mounted || review == null) return;

      onSubmitted?.call(review);
    });
  }
}
