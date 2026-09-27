import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';

class EditProfilePhoto extends StatelessWidget {
  const EditProfilePhoto({super.key, required this.imagePath, this.onTap});

  final String imagePath;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final size = responsiveWidth(context, 140);

    return Center(
      child: Semantics(
        button: true,
        label: 'Change profile photo',
        child: GestureDetector(
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(responsiveWidth(context, 44)),
            child: SizedBox(
              width: size,
              height: size,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(imagePath, fit: BoxFit.cover),
                  ColoredBox(color: AppColors.dark.withAlpha(145)),
                  Center(
                    child: Icon(
                      Icons.camera_alt_outlined,
                      color: AppColors.surface,
                      size: responsiveWidth(context, 32),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
