import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';

import 'edit_profile_input_decoration.dart';

class EditProfileSpecializationField extends StatelessWidget {
  const EditProfileSpecializationField({
    super.key,
    required this.value,
    required this.specializations,
    required this.validator,
    required this.onChanged,
  });

  final String? value;
  final List<String> specializations;
  final FormFieldValidator<String> validator;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final inputStyle = AppTextStyles.textTheme.bodyMedium?.copyWith(
      color: AppColors.textPrimary,
    );
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      style: inputStyle,
      dropdownColor: AppColors.surface,
      decoration: editProfileInputDecoration(context, 'Specialization'),
      icon: Icon(
        Icons.arrow_drop_down_rounded,
        color: AppColors.grey,
        size: responsiveWidth(context, 24),
      ),
      items: specializations.map((specialization) {
        return DropdownMenuItem<String>(
          value: specialization,
          child: Text(specialization),
        );
      }).toList(),
      validator: validator,
      onChanged: onChanged,
    );
  }
}
