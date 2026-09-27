import 'package:flutter/material.dart';

import '../../../../../core/shell/main_shell.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/responsive.dart';

class BookingSuccessScreen extends StatelessWidget {
  const BookingSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final illustrationSize = responsiveWidth(
      context,
      180,
    ).clamp(120.0, 200.0).toDouble();

    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        backgroundColor: AppColors.dark,
        surfaceTintColor: AppColors.dark,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const MainShell(showReviewOnOpen: true),
              ),
              (route) => false,
            );
          },
          icon: const Icon(Icons.arrow_back, color: AppColors.surface),
        ),
        title: Text(
          'Book',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(color: AppColors.surface),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(responsiveWidth(context, 50)),
              topRight: Radius.circular(responsiveWidth(context, 50)),
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: responsiveWidth(context, 24),
                vertical: responsiveHeight(context, 24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/Success.png',
                    width: illustrationSize,
                    height: illustrationSize,
                    fit: BoxFit.contain,
                  ),

                  SizedBox(height: responsiveHeight(context, 32)),

                  Text(
                    'Service booked successfully',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),

                  SizedBox(height: responsiveHeight(context, 16)),

                  Text(
                    'The service provider will contact you '
                    'at the scheduled time.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.6,
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
