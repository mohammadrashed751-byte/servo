import 'package:flutter/material.dart';
import 'package:servo/feature/auth/prsentation/screen/register_screen.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';

class ScreenChooseAccount extends StatelessWidget {
  const ScreenChooseAccount({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding:  EdgeInsets.symmetric(horizontal: responsiveWidth(context, 40),vertical: responsiveHeight(context, 60)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [

            Text(
              'Choose the \n account type that \n suits you',
              style: AppTextStyles.heavyTitle,
            ),
            SizedBox(height: responsiveHeight(context, 20)),
            Text(
              'Please select an account \n type to continue',
              style: AppTextStyles.textTheme.displaySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: responsiveHeight(context, 50)),
            SizedBox(
              height: responsiveHeight(context, 65),
              child: FilledButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterScreen(),
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'User Account',
                      style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                        color: AppColors.surface,
                      ),
                    ),
                    SizedBox(width: responsiveWidth(context, 8)),
                    const Icon(Icons.arrow_forward, color: AppColors.surface),
                  ],
                ),
              ),
            ),
            SizedBox(height: responsiveWidth(context, 30)),
            SizedBox(
              height: responsiveHeight(context, 65),
              child: FilledButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterScreen(role: 'provider'),
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  side: const BorderSide(color: AppColors.border, width: 1),
                  backgroundColor: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Company Account',
                      style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(width: responsiveWidth(context, 8)),
                    const Icon(
                      Icons.arrow_forward,
                      color: AppColors.textPrimary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
