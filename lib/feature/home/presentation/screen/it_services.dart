import 'package:flutter/material.dart';
import 'package:servo/feature/home/presentation/screen/service_details_screen.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../widgets/card_it_service.dart';

class ItServices extends StatelessWidget {
  const ItServices({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        backgroundColor: AppColors.dark,
        surfaceTintColor: AppColors.dark,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.maybePop(context);
          },
          icon: const Icon(Icons.arrow_back, color: AppColors.surface),
        ),
        title: Text(
          'IT Services',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(color: AppColors.surface),
        ),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_rounded,
              color: AppColors.surface,
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsiveWidth(context, 16),
                    vertical: responsiveHeight(context, 20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        style: Theme.of(context).textTheme.bodyMedium,
                        decoration: InputDecoration(
                          hintText: 'Search',
                          hintStyle: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                          filled: true,
                          fillColor: AppColors.surface,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: responsiveWidth(context, 20),
                            vertical: responsiveHeight(context, 18),
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: AppColors.textSecondary,
                            size: 22,
                          ),
                          suffixIcon: IconButton(
                            tooltip: 'Filter services',
                            onPressed: () {},
                            icon: const Icon(
                              Icons.tune_rounded,
                              color: AppColors.textSecondary,
                              size: 22,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: responsiveHeight(context, 16)),

                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ServiceDetailsScreen(),
                            ),
                          );
                        },
                        child: const CardItService(
                          imagePath: 'assets/images/Rectangle.png',
                          logoPath: 'assets/images/Ellipse.png',
                        ),
                      ),

                      SizedBox(height: responsiveHeight(context, 16)),

                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ServiceDetailsScreen(),
                            ),
                          );
                        },
                        child: const CardItService(
                          imagePath: 'assets/images/Rectangle.png',
                          logoPath: 'assets/images/Ellipse.png',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
