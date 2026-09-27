import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import 'booking/book_screen.dart';

class ServiceDetailsScreen extends StatelessWidget {
  const ServiceDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                          child: Image.asset(
                            'assets/images/Rectangle.png',
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
                              'Friday, May 11, 2021',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),

                            SizedBox(height: responsiveHeight(context, 6)),

                            Text(
                              'Web Development',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),

                            SizedBox(height: responsiveHeight(context, 8)),

                            Text(
                              'We provide professional web development services '
                              'to help your business establish a strong online '
                              'presence. Our services include:',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                    height: responsiveHeight(context, 1.6),
                                  ),
                            ),
                            SizedBox(height: responsiveHeight(context, 12)),

                            _descriptionPoint(
                              context,
                              'Responsive Websites: Fully optimized for mobile and desktop.',
                            ),

                            _descriptionPoint(
                              context,
                              'Custom Web Solutions: Tailored to your business needs.',
                            ),

                            _descriptionPoint(
                              context,
                              'Performance & SEO: Fast loading websites that rank well.',
                            ),

                            _descriptionPoint(
                              context,
                              'Ongoing Support: Maintenance and updates after launch.',
                            ),

                            SizedBox(height: responsiveHeight(context, 4)),

                            Text(
                              'Whether you need a simple landing page or a '
                              'complex web application, we deliver high-quality, '
                              'reliable solutions to meet your goals.',
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
                                      '2024/10/27',
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
                              child: Image.asset(
                                'assets/images/Rectangle1.png',
                                fit: BoxFit.contain,
                              ),
                            ),

                            SizedBox(width: responsiveWidth(context, 6)),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'CODERZ',
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
                                            index < 4
                                                ? Icons.star_rounded
                                                : Icons.star_border_rounded,
                                            color: Colors.amber,
                                            size: responsiveWidth(context, 14),
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '(32 reviews)',
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
                              onPressed: () {},
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
                          'Price: \$150 / hour',
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
                  MaterialPageRoute(builder: (context) => const BookScreen()),
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

  Widget _descriptionPoint(BuildContext context, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: responsiveHeight(context, 10)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '•',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w900,
              height: 1.6,
            ),
          ),
          SizedBox(width: responsiveWidth(context, 6)),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
