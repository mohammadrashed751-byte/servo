import 'package:servo/core/widgets/api_content.dart';
import 'package:servo/core/network/marketplace_api.dart';
import 'package:servo/core/widgets/service_image.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/utils/responsive.dart';
import 'booking/book_screen.dart';
import 'package:servo/core/widgets/chat_screen.dart';

class ServiceDetailsScreen extends StatelessWidget {
  const ServiceDetailsScreen({
    super.key,
    this.service = const {},
    this.loaded = false,
  });
  final JsonMap service;
  final bool loaded;

  @override
  Widget build(BuildContext context) {
    if (!loaded && service['id'] != null) {
      return ApiContent<JsonMap>(
        load: () async =>
            apiMap(await MarketplaceApi().request('services/${service['id']}')),
        builder: (_, data) => ServiceDetailsScreen(service: data, loaded: true),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        backgroundColor: AppColors.dark,
        surfaceTintColor: AppColors.dark,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.maybePop(context);
          },
          icon: const Icon(Icons.arrow_back, color: AppColors.surface),
        ),
      ),
      body: SafeArea(
        bottom: false,
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
                    vertical: responsiveHeight(context, 12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          responsiveWidth(context, 24),
                        ),
                        child: AspectRatio(
                          aspectRatio: 1.2,
                          child: ServiceImage(
                            apiText(service['thumbnail']),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: responsiveHeight(context, 20)),
                      Padding(
                        padding: EdgeInsets.only(
                          left: responsiveWidth(context, 12),
                          right: responsiveWidth(context, 8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              apiText(service['created_at']),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),

                            SizedBox(height: responsiveHeight(context, 6)),

                            Text(
                              apiText(service['title']),
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),

                            SizedBox(height: responsiveHeight(context, 8)),

                            Text(
                              apiText(service['description']),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                    height: responsiveHeight(context, 1.6),
                                  ),
                            ),
                            SizedBox(height: responsiveHeight(context, 12)),

                            SizedBox(height: responsiveHeight(context, 4)),

                            Text(
                              apiText(apiMap(service['category'])['name']),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                    height: 1.6,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: responsiveHeight(context, 20)),

                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: responsiveWidth(context, 10),
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: responsiveWidth(context, 80),
                            vertical: responsiveHeight(context, 14),
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(40),
                            borderRadius: BorderRadius.circular(
                              responsiveWidth(context, 12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.calendar_month_outlined,
                                color: AppColors.primary,
                                size: responsiveWidth(context, 35),
                              ),

                              SizedBox(width: responsiveWidth(context, 12)),

                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Delivery Date',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                    SizedBox(
                                      height: responsiveHeight(context, 2),
                                    ),
                                    Text(
                                      'Choose when booking',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
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
                      SizedBox(height: responsiveHeight(context, 20)),

                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: responsiveWidth(context, 10),
                        ),

                        child: Row(
                          children: [
                            Container(
                              width: responsiveWidth(context, 60),
                              height: responsiveWidth(context, 60),
                              padding: EdgeInsets.all(
                                responsiveWidth(context, 0),
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(
                                  responsiveWidth(context, 14),
                                ),
                                border: Border.all(
                                  color: AppColors.primary,
                                  width: 1.5,
                                ),
                              ),
                              child: ServiceImage(
                                apiText(apiMap(service['provider'])['avatar']),
                                fit: BoxFit.contain,
                              ),
                            ),

                            SizedBox(width: responsiveWidth(context, 6)),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    apiText(
                                      apiMap(service['provider'])['name'],
                                    ),
                                    style: AppTextStyles.heavyTitle3,
                                  ),

                                  SizedBox(
                                    height: responsiveHeight(context, 6),
                                  ),

                                  Wrap(
                                    spacing: responsiveWidth(context, 4),
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: List.generate(
                                          5,
                                          (index) => Icon(
                                            index <
                                                    (double.tryParse(
                                                              '${apiMap(service['provider'])['rating_avg']}',
                                                            ) ??
                                                            0)
                                                        .round()
                                                ? Icons.star_rounded
                                                : Icons.star_border_rounded,
                                            color: Colors.amber,
                                            size: responsiveWidth(context, 14),
                                          ),
                                        ),
                                      ),
                                      Text(
                                        "(${apiMap(service['provider'])['rating_count'] ?? 0} reviews)",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            IconButton(
                              tooltip: 'Call provider',
                              onPressed: () {},
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.orange.withAlpha(20),
                                foregroundColor: Colors.orange,
                                shape: const CircleBorder(),
                              ),
                              icon: const Icon(Icons.phone_outlined, size: 20),
                            ),

                            IconButton(
                              tooltip: 'Message provider',
                              onPressed:
                                  apiMap(service['provider'])['id'] == null
                                  ? null
                                  : () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ChatScreen(
                                          providerId:
                                              apiMap(service['provider'])['id']
                                                  as int,
                                          name: apiText(
                                            apiMap(service['provider'])['name'],
                                          ),
                                          avatar: apiText(
                                            apiMap(
                                              service['provider'],
                                            )['avatar'],
                                          ),
                                        ),
                                      ),
                                    ),
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.primary.withAlpha(
                                  20,
                                ),
                                foregroundColor: AppColors.primary,
                                shape: const CircleBorder(),
                              ),
                              icon: const Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: responsiveHeight(context, 24)),

                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: responsiveWidth(context, 20),
                        ),
                        child: Text(
                          "Price: ${service['price']} ${service['currency'] ?? 'JD'}${service['price_type'] == 'hourly' ? ' / hour' : ''}",
                          style: AppTextStyles.textTheme.displaySmall?.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      SizedBox(height: responsiveHeight(context, 24)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: ColoredBox(
        color: AppColors.surface,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: responsiveWidth(context, 24),
              vertical: responsiveHeight(context, 16),
            ),
            child: FilledButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        BookScreen(serviceId: service['id'] as int?),
                  ),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: Size(0, responsiveHeight(context, 56)),
                padding: EdgeInsets.symmetric(
                  vertical: responsiveHeight(context, 14),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    responsiveWidth(context, 16),
                  ),
                ),
              ),
              child: Text(
                'Book',
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: AppColors.surface),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
