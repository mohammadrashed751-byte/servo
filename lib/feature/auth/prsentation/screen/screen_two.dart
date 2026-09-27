import 'package:flutter/material.dart';
import 'package:servo/feature/auth/prsentation/screen/screen_three.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/onboarding_page_indicator.dart';
import '../../../../core/utils/responsive.dart';

class ScreenTwo extends StatelessWidget {
  const ScreenTwo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.5,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: responsiveHeight(context, 38),
                      right: 16,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.warning,
                        ),
                        onPressed: () {},
                        child: const Text(
                          'Skip',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: responsiveHeight(context, 108),
                        left: responsiveWidth(context, 30),
                        right: responsiveWidth(context, 30),
                        bottom: responsiveHeight(context, 62),
                      ),
                      child: Image.asset(
                        AppAssets.authHeader3,
                        fit: BoxFit.contain,
                        width: double.infinity,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: responsiveHeight(context, 30)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Find&Book Services',
                        style: AppTextStyles.heavyTitle1,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: responsiveHeight(context, 30)),
                      Text(
                        'Browse services, choose the best provider,\n and book your preferred time instantly.',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),

                      const Spacer(),

                      const OnboardingPageIndicator(activeIndex: 1),
                      SizedBox(height: responsiveHeight(context, 30)),
                      SizedBox(
                        height: responsiveHeight(context, 56),
                        width: responsiveWidth(context, 340),
                        child: FilledButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ScreenThree(),
                              ),
                            );
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'Next',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(color: AppColors.surface),
                          ),
                        ),
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
