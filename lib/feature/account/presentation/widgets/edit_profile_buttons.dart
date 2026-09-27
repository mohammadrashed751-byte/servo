import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';

class ChangePasswordButton extends StatelessWidget {
  const ChangePasswordButton({super.key, required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final textStyles = AppTextStyles.textTheme;
    return OutlinedButton(
      onPressed: () {
        onPressed?.call();
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        disabledForegroundColor: AppColors.textSecondary,
        side: const BorderSide(color: AppColors.border),
        minimumSize: Size(double.infinity, responsiveHeight(context, 60)),
        padding: EdgeInsets.symmetric(
          horizontal: responsiveWidth(context, 16),
          vertical: responsiveHeight(context, 16),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(responsiveWidth(context, 18)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              'Change Password',
              textAlign: TextAlign.center,
              style: textStyles.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: responsiveWidth(context, 10)),
          Icon(
            Icons.arrow_forward,
            size: responsiveWidth(context, 18),
            color: AppColors.textPrimary,
          ),
        ],
      ),
    );
  }
}

class SaveProfileButton extends StatelessWidget {
  const SaveProfileButton({
    super.key,
    required this.onPressed,
    this.isSaving = false,
  });

  final VoidCallback onPressed;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    final textStyles = AppTextStyles.textTheme;
    return ElevatedButton(
      onPressed: isSaving ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        elevation: 0,
        minimumSize: Size(double.infinity, responsiveHeight(context, 62)),
        padding: EdgeInsets.symmetric(
          horizontal: responsiveWidth(context, 16),
          vertical: responsiveHeight(context, 16),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(responsiveWidth(context, 18)),
        ),
        textStyle: textStyles.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      child: isSaving
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                semanticsLabel: 'Saving profile',
              ),
            )
          : const Text('Save Changes'),
    );
  }
}
