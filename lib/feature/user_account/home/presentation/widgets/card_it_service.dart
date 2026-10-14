import 'package:servo/core/network/marketplace_api.dart';
import 'package:servo/core/widgets/service_image.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/responsive.dart';

class CardItService extends StatelessWidget {
  final JsonMap service;
  final String imagePath;
  final String? logoPath;

  const CardItService({
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
              color: Colors.black.withAlpha(12),
              blurRadius: responsiveWidth(context, 10),
              offset: Offset(0, responsiveHeight(context, 3)),
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
                          aspectRatio: 2,
                          child: ServiceImage(imagePath, fit: BoxFit.cover),
                        ),
                      ),

                      SizedBox(height: responsiveWidth(context, 10)),
                    ],
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
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppColors.grey),
                    ),
                    Text(
                      apiText(service['title']),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      apiText(service['description']),
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
