import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../domain/entities/home_category.dart';
import '../widgets/category_icon.dart';
import '../widgets/category_item.dart';

class CategoriesScreen extends StatefulWidget {
  final List<HomeCategory> categories;

  const CategoriesScreen({super.key, required this.categories});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  String _searchText = '';

  @override
  Widget build(BuildContext context) {
    final filteredCategories = widget.categories.where((category) {
      final title = category.title;

      return title.toLowerCase().contains(_searchText);
    }).toList();

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
          'Categories',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(color: AppColors.surface),
        ),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () {
              // بنضيف صفحة الإشعارات بعدين .
            },
            icon: const Icon(
              Icons.notifications_rounded,
              color: AppColors.surface,
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              left: responsiveWidth(context, 16),
              right: responsiveWidth(context, 16),
              top: responsiveHeight(context, 24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchText = value.trim().toLowerCase();
                    });
                  },
                  style: Theme.of(context).textTheme.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'Search',
                    hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
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
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: filteredCategories.isEmpty
                      ? Center(
                          child: Text(
                            'No categories found',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.only(bottom: 24),
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          itemCount: filteredCategories.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 20,
                                mainAxisExtent: 140,
                              ),
                          itemBuilder: (context, index) {
                            final category = filteredCategories[index];

                            return CategoryItem(
                              title: category.title,
                              icon: category.icon,
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
