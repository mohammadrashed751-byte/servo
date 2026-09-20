import 'package:flutter/material.dart';
import 'package:servo/core/utils/responsive.dart';
import 'package:servo/feature/auth/prsentation/screen/screen_two.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

class ScreenOne extends StatelessWidget {
  const ScreenOne({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                        top: responsiveHeight(context, 81),
                        left: responsiveWidth(context, 20),
                        right: responsiveWidth(context, 20),
                      ),
                      child: Image.asset(
                        AppAssets.authHeader2,
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
                        'Book Services Fast',
                        style: AppTextStyles.heavyTitle1,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: responsiveHeight(context, 30)),
                      Text(
                        'Find trusted service providers and book\nappointments in just a few steps.',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),

                      const Spacer(),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _dot(isActive: true),
                          _dot(isActive: false),
                          _dot(isActive: false),
                        ],
                      ),
                      SizedBox(height: responsiveHeight(context, 30)),
                      SizedBox(
                        height: responsiveHeight(context, 56),
                        width: responsiveWidth(context, 340),
                        child: FilledButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ScreenTwo(),
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

  Widget _dot({required bool isActive}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 20 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.border,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
