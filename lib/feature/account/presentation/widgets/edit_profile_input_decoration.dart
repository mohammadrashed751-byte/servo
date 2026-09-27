import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';

InputDecoration editProfileInputDecoration(
  BuildContext context,
  String label, {
  Widget? prefixIcon,
  Widget? suffixIcon,
  Color? fillColor,
}) {
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(responsiveWidth(context, 18)),
    borderSide: const BorderSide(color: AppColors.border),
  );

  return InputDecoration(
    labelText: label,
    floatingLabelBehavior: FloatingLabelBehavior.always,
    labelStyle: AppTextStyles.textTheme.bodySmall?.copyWith(
      color: AppColors.textSecondary,
    ),
    filled: true,
    fillColor: fillColor ?? AppColors.surface,
    contentPadding: EdgeInsets.symmetric(
      horizontal: responsiveWidth(context, 22),
      vertical: responsiveHeight(context, 20),
    ),
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    border: border,
    enabledBorder: border,
    focusedBorder: border.copyWith(
      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
    ),
    errorBorder: border.copyWith(
      borderSide: const BorderSide(color: AppColors.failed),
    ),
    focusedErrorBorder: border.copyWith(
      borderSide: const BorderSide(color: AppColors.failed, width: 1.5),
    ),
    errorStyle: AppTextStyles.textTheme.bodySmall?.copyWith(
      color: AppColors.failed,
    ),
    errorMaxLines: 2,
  );
}
