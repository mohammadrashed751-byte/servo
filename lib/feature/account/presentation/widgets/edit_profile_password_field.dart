import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

import 'edit_profile_input_decoration.dart';

class EditProfilePasswordField extends StatelessWidget {
  const EditProfilePasswordField({super.key});

  @override
  Widget build(BuildContext context) {
    final inputStyle = AppTextStyles.textTheme.bodyMedium?.copyWith(
      color: AppColors.textPrimary,
    );
    return InputDecorator(
      decoration: editProfileInputDecoration(
        context,
        'Password',
        fillColor: AppColors.background,
      ),
      child: Text('••••••', style: inputStyle?.copyWith(letterSpacing: 3)),
    );
  }
}
