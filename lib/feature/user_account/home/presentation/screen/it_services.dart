import '../widgets/filter_bottom_sheet.dart';
import 'package:servo/core/network/marketplace_api.dart';
import 'package:servo/core/widgets/api_content.dart';
import '../../domain/entities/filter_criteria.dart';
import 'package:servo/core/widgets/notifications_screen.dart';
import 'package:flutter/material.dart';
import 'package:servo/feature/user_account/home/presentation/screen/service_details_screen.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/responsive.dart';
import '../widgets/card_it_service.dart';

class ItServices extends StatelessWidget {
  const ItServices({super.key, this.categoryId, this.query = '', this.filters});
  final int? categoryId;
  final String query;
  final FilterCriteria? filters;

  @override
  Widget build(BuildContext context) {
    return ApiContent<List<JsonMap>>(
      load: () async {
        int? selectedId = categoryId;
        if (filters?.category != null) {
          final categories = await MarketplaceApi().list('categories');
          final match = categories.where(
            (c) => apiText(c['name']) == filters!.category,
          );
          if (match.isNotEmpty) selectedId = match.first['id'] as int;
        }
        return MarketplaceApi().list(
          'services',
          query: {
            'category_id': ?selectedId,
            if (query.isNotEmpty) 'q': query,
            if (filters != null &&
                filters!.minPrice != FilterCriteria.lowestPrice)
              'price_min': filters!.minPrice,
            if (filters != null &&
                filters!.maxPrice != FilterCriteria.highestPrice)
              'price_max': filters!.maxPrice,
          },
        );
      },
      builder: _loaded,
    );
  }

  Widget _loaded(BuildContext context, List<JsonMap> services) {
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
          'Services',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(color: AppColors.surface),
        ),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => Navigator.push<void>(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
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
                        onSubmitted: (value) => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ItServices(
                              categoryId: categoryId,
                              query: value,
                              filters: filters,
                            ),
                          ),
                        ),
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
                            onPressed: () async {
                              try {
                                final categories = await MarketplaceApi().list(
                                  'categories',
                                );
                                if (!context.mounted) return;
                                final selected =
                                    await showModalBottomSheet<FilterCriteria>(
                                      context: context,
                                      isScrollControlled: true,
                                      useSafeArea: true,
                                      builder: (_) => FilterBottomSheet(
                                        initialFilters:
                                            filters ?? const FilterCriteria(),
                                        categoryNames: categories
                                            .map((c) => apiText(c['name']))
                                            .toList(),
                                      ),
                                    );
                                if (!context.mounted || selected == null) {
                                  return;
                                }
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ItServices(
                                      categoryId: categoryId,
                                      query: query,
                                      filters: selected,
                                    ),
                                  ),
                                );
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(SnackBar(content: Text('$e')));
                                }
                              }
                            },
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

                      if (services.isEmpty) const Text('No services found'),
                      for (final service in services)
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ServiceDetailsScreen(service: service),
                            ),
                          ),
                          child: CardItService(
                            service: service,
                            imagePath: apiText(service['thumbnail']),
                            logoPath: apiText(
                              apiMap(service['provider'])['avatar'],
                            ),
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
