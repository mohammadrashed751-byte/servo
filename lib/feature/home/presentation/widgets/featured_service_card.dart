import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../screen/it_services.dart';

class FeaturedServiceCard extends StatelessWidget {
  final String imagePath;
  final String? logoPath;

  const FeaturedServiceCard({
    super.key,
    required this.imagePath,
    this.logoPath,
  });

  @override
  Widget build(BuildContext context) {
    final logoSize = responsiveWidth(context, 48);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        responsiveWidth(context, 4),
        responsiveHeight(context, 4),
        responsiveWidth(context, 12),
        responsiveHeight(context, 16),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(responsiveWidth(context, 24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: responsiveWidth(context, 12),
              offset: Offset(0, responsiveHeight(context, 4)),
            ),
            BoxShadow(
              color: AppColors.textSecondary,
              blurRadius: 0,
              offset: Offset(
                responsiveWidth(context, 7),
                responsiveHeight(context, 9),
              ),
            ),
            BoxShadow(
              color: AppColors.border,
              blurRadius: 0,
              offset: Offset(
                responsiveWidth(context, 3),
                responsiveHeight(context, 5),
              ),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: responsiveHeight(context, 8),

            horizontal: responsiveWidth(context, 8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          responsiveWidth(context, 20),
                        ),
                        child: AspectRatio(
                          aspectRatio: 2.5,
                          child: Image.asset(imagePath, fit: BoxFit.cover),
                        ),
                      ),

                      SizedBox(height: responsiveWidth(context, 10)),
                    ],
                  ),

                  Positioned(
                    top: responsiveHeight(context, 10),
                    left: responsiveWidth(context, 10),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: responsiveWidth(context, 22),
                        vertical: responsiveHeight(context, 8),
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(
                          responsiveWidth(context, 24),
                        ),
                      ),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ItServices(),
                            ),
                          );
                        },
                        child: Text(
                          'IT Services',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.surface,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    right: responsiveWidth(context, 16),
                    bottom: 0,
                    child: Container(
                      width: logoSize,
                      height: logoSize,

                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary),
                      ),
                      child: ClipOval(
                        child: Image.asset(logoPath!, fit: BoxFit.contain),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  responsiveWidth(context, 10),
                  0,
                  responsiveWidth(context, 10),
                  responsiveHeight(context, 8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Friday, May 11, 2021',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppColors.grey),
                    ),
                    Text(
                      'Web Development',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      'Build responsive websites that engage users '
                      'and drive results',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: responsiveHeight(context, 8)),
                    Text(
                      '\$150/hr',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
