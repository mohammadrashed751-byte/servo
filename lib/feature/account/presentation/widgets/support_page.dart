import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import 'edit_profile_app_bar.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({
    super.key,
    required this.appBarTitle,
    required this.title,
    required this.description,
    required this.onGoHomepage,
    required this.child,
  });

  final String appBarTitle;
  final String title;
  final String description;
  final VoidCallback onGoHomepage;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: buildEditProfileAppBar(
        context,
        title: appBarTitle,
        onBack: () => Navigator.pop(context),
        onNotifications: () {},
      ),
      body: SafeArea(
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(responsiveWidth(context, 32)),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    responsiveWidth(context, 32),
                    responsiveHeight(context, 44),
                    responsiveWidth(context, 32),
                    responsiveHeight(context, 24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(title, style: AppTextStyles.heavyTitle),
                      SizedBox(height: responsiveHeight(context, 8)),
                      Text(
                        description,
                        style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                          height: 1.7,
                        ),
                      ),
                      SizedBox(height: responsiveHeight(context, 32)),
                      child,
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  responsiveWidth(context, 44),
                  responsiveHeight(context, 12),
                  responsiveWidth(context, 44),
                  responsiveHeight(context, 32),
                ),
                child: OutlinedButton(
                  onPressed: onGoHomepage,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    minimumSize: Size(
                      double.infinity,
                      responsiveHeight(context, 58),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: responsiveWidth(context, 16),
                      vertical: responsiveHeight(context, 16),
                    ),
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        responsiveWidth(context, 16),
                      ),
                    ),
                    textStyle: AppTextStyles.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Flexible(child: Text('Go to Homepage')),
                      SizedBox(width: responsiveWidth(context, 10)),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: responsiveWidth(context, 16),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
