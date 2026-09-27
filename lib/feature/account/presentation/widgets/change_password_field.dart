import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import 'edit_profile_input_decoration.dart';

class ChangePasswordField extends StatelessWidget {
  const ChangePasswordField({
    super.key,
    required this.controller,
    required this.label,
    required this.validator,
    this.obscureText = true,
    this.enabled = true,
    this.isValid = false,
    this.textInputAction = TextInputAction.next,
    this.autofillHints,
    this.onChanged,
    this.onFieldSubmitted,
    this.onToggleVisibility,
  });

  final TextEditingController controller;
  final String label;
  final FormFieldValidator<String> validator;
  final bool obscureText;
  final bool enabled;
  final bool isValid;
  final TextInputAction textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final VoidCallback? onToggleVisibility;

  @override
  Widget build(BuildContext context) {
    final successBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(responsiveWidth(context, 18)),
      borderSide: const BorderSide(color: AppColors.success),
    );
    final decoration = editProfileInputDecoration(
      context,
      label,
      suffixIcon: isValid
          ? Icon(
              Icons.check_rounded,
              color: AppColors.success,
              size: responsiveWidth(context, 20),
            )
          : onToggleVisibility == null
          ? null
          : IconButton(
              tooltip: obscureText ? 'Show password' : 'Hide password',
              onPressed: enabled ? onToggleVisibility : null,
              icon: Icon(
                obscureText
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.grey,
                size: responsiveWidth(context, 24),
              ),
            ),
    );

    return TextFormField(
      controller: controller,
      enabled: enabled,
      obscureText: obscureText,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      autocorrect: false,
      enableSuggestions: false,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      style: AppTextStyles.textTheme.bodyMedium?.copyWith(
        color: isValid ? AppColors.success : AppColors.textPrimary,
      ),
      decoration: isValid
          ? decoration.copyWith(
              enabledBorder: successBorder,
              focusedBorder: successBorder,
              labelStyle: AppTextStyles.textTheme.bodySmall?.copyWith(
                color: AppColors.success,
              ),
              floatingLabelStyle: AppTextStyles.textTheme.bodySmall?.copyWith(
                color: AppColors.success,
              ),
            )
          : decoration,
    );
  }
}
