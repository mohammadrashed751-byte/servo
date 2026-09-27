import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.labelText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.suffixIcon,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.onChanged,
    this.errorText,
    this.isValid = false,
    this.controller,
    this.validator,
    this.validateMode = AutovalidateMode.disabled,
  });

  final String labelText;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final bool autocorrect;
  final bool enableSuggestions;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final bool isValid;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final AutovalidateMode validateMode;

  @override
  Widget build(BuildContext context) {
    final manualError = validator == null ? errorText : null;
    final showSuccess = isValid && manualError == null;

    return TextFormField(
      controller: controller,
      validator: validator,
      autovalidateMode: validateMode,
      style: showSuccess
          ? Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.success)
          : Theme.of(context).textTheme.bodyLarge,
      keyboardType: keyboardType,
      obscureText: obscureText,
      autocorrect: autocorrect,
      enableSuggestions: enableSuggestions,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: labelText,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: manualError != null
              ? AppColors.failed
              : showSuccess
              ? AppColors.success
              : AppColors.textSecondary,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: responsiveWidth(context, 16),
          vertical: responsiveHeight(context, 18),
        ),
        suffixIcon: suffixIcon,
        errorText: manualError,
        errorMaxLines: 2,
        errorStyle: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: AppColors.failed),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: showSuccess ? AppColors.success : AppColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: showSuccess ? AppColors.success : AppColors.primary,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.failed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.failed),
        ),
      ),
    );
  }
}
