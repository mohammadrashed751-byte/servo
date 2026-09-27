import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';

import 'edit_profile_input_decoration.dart';

class EditProfileTextField extends StatelessWidget {
  const EditProfileTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.validator,
    this.keyboardType,
    required this.textInputAction,
    required this.autofillHints,
    this.textCapitalization = TextCapitalization.none,
    this.autocorrect = true,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final FormFieldValidator<String> validator;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final Iterable<String> autofillHints;
  final TextCapitalization textCapitalization;
  final bool autocorrect;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: AppTextStyles.textTheme.bodyMedium?.copyWith(
        color: AppColors.textPrimary,
      ),
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      textCapitalization: textCapitalization,
      autocorrect: autocorrect,
      validator: validator,
      onChanged: onChanged,
      decoration: editProfileInputDecoration(
        context,
        label,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
    );
  }
}

class EditProfilePhoneField extends StatelessWidget {
  const EditProfilePhoneField({
    super.key,
    required this.controller,
    required this.validator,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FormFieldValidator<String> validator;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final textStyles = AppTextStyles.textTheme;
    return EditProfileTextField(
      controller: controller,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.telephoneNumber],
      validator: validator,
      onChanged: onChanged,
      label: 'Phone Number',
      prefixIcon: Padding(
        padding: EdgeInsets.symmetric(horizontal: responsiveWidth(context, 14)),
        child: Text(
          '🇯🇴',
          style: textStyles.headlineMedium?.copyWith(
            fontSize: responsiveWidth(context, 28),
          ),
        ),
      ),
      suffixIcon: validator(controller.text) == null
          ? Icon(
              Icons.check_rounded,
              size: responsiveWidth(context, 20),
              color: AppColors.textPrimary,
            )
          : null,
    );
  }
}
