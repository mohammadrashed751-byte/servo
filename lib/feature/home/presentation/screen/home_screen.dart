import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:servo/core/theme/app_theme.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../data/datasources/home_local_data_source.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../domain/entities/filter_criteria.dart';
import '../../domain/repositories/home_repository.dart';
import '../cubit/home_cubit.dart';
import '../state/home_state.dart';
import '../widgets/category_icon.dart';
import '../widgets/category_item.dart';
import '../widgets/experience_review_launcher.dart';
import '../widgets/featured_service_card.dart';
import '../widgets/filter_bottom_sheet.dart';
import 'categories_screen.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatelessWidget {
  final bool showReviewOnOpen;

  const HomeScreen({super.key, this.showReviewOnOpen = false});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<HomeRepository>(
      create: (_) => const HomeRepositoryImpl(HomeLocalDataSource()),
      child: BlocProvider(
        create: (context) => HomeCubit(context.read<HomeRepository>()),
        child: _HomeView(showReviewOnOpen: showReviewOnOpen),
      ),
    );
  }
}

class _HomeView extends StatefulWidget {
  final bool showReviewOnOpen;

  const _HomeView({required this.showReviewOnOpen});

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  Future<void> _openFilters() async {
    FocusScope.of(context).unfocus();
    final homeCubit = context.read<HomeCubit>();
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
        categoryNames: homeCubit.state.categories
            .map((category) => category.title)
            .toList(),
      ),
    );
    if (!mounted || result == null) return;
    homeCubit.applyFilters(result);
  }

  @override
  void initState() {
    super.initState();

    if (widget.showReviewOnOpen) {
      ExperienceReviewLauncher.showAfterBuild(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.read<HomeCubit>().state.categories;
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
                        height: responsiveHeight(context, 120),
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
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _dot(isActive: true),
                                _dot(isActive: false),
                                _dot(isActive: false),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: responsiveHeight(context, 8)),
                      const FeaturedServiceCard(
                        imagePath: 'assets/images/Rectangle.png',
                        logoPath: 'assets/images/Ellipse.png',
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
