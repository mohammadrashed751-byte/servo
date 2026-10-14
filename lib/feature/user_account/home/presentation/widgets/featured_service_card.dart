import 'package:servo/core/network/marketplace_api.dart';
import 'package:servo/core/widgets/service_image.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/responsive.dart';
import '../screen/it_services.dart';

class FeaturedServiceCard extends StatelessWidget {
  final JsonMap service;
  final String imagePath;
  final String? logoPath;

  const FeaturedServiceCard({
    super.key,
    required this.imagePath,
    this.service = const {},
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
                          child: ServiceImage(imagePath, fit: BoxFit.cover),
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
                              builder: (context) => ItServices(
                                categoryId:
                                    apiMap(service['category'])['id'] as int?,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          apiText(apiMap(service['category'])['name']),
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
                        child: ServiceImage(
                          logoPath ?? '',
                          fit: BoxFit.contain,
                          isAvatar: true,
                        ),
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
                      apiText(service['created_at']),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppColors.grey),
                    ),
                    Text(
                      apiText(service['title']),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      apiText(service['description']),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: responsiveHeight(context, 8)),
                    Text(
                      "${service['price']} ${service['currency'] ?? 'JD'}${service['price_type'] == 'hourly' ? ' / hour' : ''}",
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
