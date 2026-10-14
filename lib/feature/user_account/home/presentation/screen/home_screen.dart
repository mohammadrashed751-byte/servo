import 'package:servo/core/network/marketplace_api.dart';
import 'package:servo/core/widgets/api_content.dart';
import '../../domain/entities/home_category.dart';
import 'it_services.dart';
import 'service_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:servo/core/theme/app_theme.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/responsive.dart';
import '../../../../../core/widgets/onboarding_page_indicator.dart';
import '../../data/datasources/home_local_data_source.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../domain/entities/filter_criteria.dart';
import '../../domain/repositories/home_repository.dart';
import '../cubit/home_cubit.dart';
import '../state/home_state.dart';
import '../widgets/category_icon.dart';
import '../widgets/category_item.dart';
import '../widgets/featured_service_card.dart';
import '../widgets/filter_bottom_sheet.dart';
import 'categories_screen.dart';
import 'package:servo/core/widgets/notifications_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<HomeRepository>(
      create: (_) => const HomeRepositoryImpl(HomeLocalDataSource()),
      child: BlocProvider(
        create: (context) => HomeCubit(context.read<HomeRepository>()),
        child: const _HomeView(),
      ),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  int _featuredIndex = 0;
  Future<void> _openFilters() async {
    FocusScope.of(context).unfocus();
    final homeCubit = context.read<HomeCubit>();
    List<JsonMap> availableCategories;
    try {
      availableCategories = await MarketplaceApi().list('categories');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$e')));
      }
      return;
    }
    if (!mounted) return;
    final result = await showModalBottomSheet<FilterCriteria>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      clipBehavior: Clip.antiAlias,
      builder: (context) => FilterBottomSheet(
        initialFilters: homeCubit.state.filters,
        categoryNames: availableCategories
            .map((c) => apiText(c['name']))
            .toList(),
      ),
    );
    if (!mounted || result == null) return;
    homeCubit.applyFilters(result);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ItServices(filters: result)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ApiContent<JsonMap>(
      load: () async => apiMap(await MarketplaceApi().request('home')),
      builder: _loaded,
    );
  }

  Widget _loaded(BuildContext context, JsonMap data) {
    final featured = (data['featured_services'] as List? ?? []).cast<JsonMap>();
    final rawCategories = (data['categories'] as List? ?? []).cast<JsonMap>();
    final categories = rawCategories
        .map(
          (c) => HomeCategory(
            id: c['id'] as int?,
            title: apiText(c['name']),
            type: switch (apiText(c['name']).toLowerCase()) {
              'design' => HomeCategoryType.design,
              'marketing' => HomeCategoryType.marketing,
              'ai' || 'technology' => HomeCategoryType.technology,
              'cleaning' => HomeCategoryType.cleaning,
              'home services' ||
              'moving & shifting' => HomeCategoryType.repairs,
              _ => HomeCategoryType.itServices,
            },
          ),
        )
        .toList();
    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        backgroundColor: AppColors.dark,
        surfaceTintColor: AppColors.dark,
        centerTitle: true,

        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.grid_view_rounded, color: AppColors.surface),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 12,
              backgroundColor: AppColors.surface,
              child: Icon(
                Icons.diamond_rounded,
                size: 14,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Service',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: AppColors.surface),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.notifications_rounded,
              color: AppColors.surface,
            ),
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: responsiveWidth(context, 16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: responsiveHeight(context, 16)),
                  Text(
                    'Welcome 👋',
                    style: AppTextStyles.heavyTitle1.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: responsiveHeight(context, 8)),
                  Text(
                    'What service do you need today?',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.surface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: responsiveHeight(context, 24)),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        onSubmitted: (value) => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ItServices(query: value),
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
                          suffixIcon: BlocSelector<HomeCubit, HomeState, bool>(
                            selector: (state) => state.filters.isActive,
                            builder: (context, isActive) => IconButton(
                              tooltip: isActive
                                  ? 'Edit filters'
                                  : 'Filter services',
                              onPressed: _openFilters,
                              icon: Icon(
                                Icons.tune_rounded,
                                color: isActive
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                                size: 22,
                              ),
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
                      SizedBox(height: responsiveHeight(context, 24)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Categories',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          IconButton(
                            tooltip: 'View all categories',
                            icon: const Icon(
                              Icons.chevron_right,
                              color: AppColors.textPrimary,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CategoriesScreen(categories: categories),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: responsiveHeight(context, 16)),
                      SizedBox(
                        height: responsiveHeight(context, 120).clamp(
                          CategoryItem.minimumHeight(context),
                          double.infinity,
                        ),
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length,
                          separatorBuilder: (context, index) {
                            return const SizedBox(width: 16);
                          },
                          itemBuilder: (context, index) {
                            final category = categories[index];

                            return SizedBox(
                              width: responsiveWidth(context, 80),
                              child: CategoryItem(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ItServices(categoryId: category.id),
                                  ),
                                ),
                                title: category.title,
                                icon: category.icon,
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: responsiveHeight(context, 8)),

                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: responsiveWidth(context, 16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Featured Services',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            if (featured.isNotEmpty)
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: OnboardingPageIndicator(
                                    activeIndex: _featuredIndex,
                                    count: featured.length,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: responsiveHeight(context, 8)),
                      if (featured.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('No services yet'),
                        )
                      else
                        SizedBox(
                          height:
                              responsiveWidth(context, 430) / 2.5 +
                              MediaQuery.textScalerOf(context).scale(160) +
                              responsiveHeight(context, 60),
                          child: PageView.builder(
                            itemCount: featured.length,
                            onPageChanged: (index) =>
                                setState(() => _featuredIndex = index),
                            itemBuilder: (context, index) {
                              final service = featured[index];
                              return SingleChildScrollView(
                                child: GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ServiceDetailsScreen(
                                        service: service,
                                      ),
                                    ),
                                  ),
                                  child: FeaturedServiceCard(
                                    service: service,
                                    imagePath: apiText(service['thumbnail']),
                                    logoPath: apiText(
                                      apiMap(service['provider'])['avatar'],
                                    ),
                                  ),
                                ),
                              );
                            },
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
