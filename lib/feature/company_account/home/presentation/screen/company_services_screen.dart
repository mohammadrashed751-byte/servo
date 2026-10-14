import 'package:servo/core/network/marketplace_api.dart';
import 'package:servo/core/widgets/notifications_screen.dart';
import '../widgets/company_service_filter.dart';
import '../controllers/company_services_controller.dart';
import 'company_service_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:servo/core/theme/app_colors.dart';
import 'package:servo/core/theme/app_theme.dart';
import 'package:servo/core/utils/responsive.dart';
import 'package:servo/feature/company_account/home/presentation/widgets/company_service_card.dart';
import 'add_service_screen.dart';

class CompanyServicesScreen extends StatefulWidget {
  const CompanyServicesScreen({super.key, required this.controller});
  final CompanyServicesController controller;

  @override
  State<CompanyServicesScreen> createState() => _CompanyServicesScreenState();
}

class _CompanyServicesScreenState extends State<CompanyServicesScreen> {
  String _searchQuery = '';
  CompanyServiceFilter _filter = const CompanyServiceFilter();

  Future<void> _openFilter() async {
    FocusScope.of(context).unfocus();
    final result = await showModalBottomSheet<CompanyServiceFilter>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(responsiveWidth(context, 36)),
        ),
      ),
      builder: (_) => CompanyServiceFilterSheet(
        initialFilter: _filter,
        categories: widget.controller.categories
            .map((c) => apiText(c['name']))
            .toList(),
      ),
    );
    if (!mounted || result == null) return;
    setState(() => _filter = result);
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredServices = widget.controller.services.where((service) {
      return service.title.toLowerCase().contains(_searchQuery) &&
          (_filter.category == null || service.category == _filter.category) &&
          (_filter.status == null || service.status == _filter.status);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.dark,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add service',
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(responsiveWidth(context, 24)),
        ),
        onPressed: () {
          Navigator.push<bool>(
            context,
            MaterialPageRoute<bool>(
              builder: (_) => AddServiceScreen(
                categories: widget.controller.categories
                    .map((c) => apiText(c['name']))
                    .toList(),
                onSave: (input) async {
                  final now = DateTime.now();
                  await widget.controller.add(
                    CompanyServicePreview(
                      id: now.microsecondsSinceEpoch.toString(),
                      title: input.name,
                      category: input.category,
                      date: '${now.year}/${now.month}/${now.day}',
                      durationMinutes: input.durationMinutes,
                      price: input.price,
                      description: input.description,
                    ),
                  );
                },
              ),
            ),
          );
        },
        child: Icon(Icons.add, size: responsiveWidth(context, 30)),
      ),
      appBar: AppBar(
        backgroundColor: AppColors.dark,
        foregroundColor: AppColors.surface,
        surfaceTintColor: AppColors.dark,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: responsiveHeight(context, 64),
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, size: responsiveWidth(context, 24)),
        ),
        title: Text(
          'Service',
          style: AppTextStyles.textTheme.headlineMedium?.copyWith(
            color: AppColors.surface,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: responsiveWidth(context, 20)),
            child: IconButton(
              tooltip: 'Notifications',
              onPressed: () => Navigator.push<void>(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              ),
              icon: Icon(
                Icons.notifications_rounded,
                size: responsiveWidth(context, 22),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(responsiveWidth(context, 36)),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  responsiveWidth(context, 24),
                  responsiveHeight(context, 28),
                  responsiveWidth(context, 24),
                  responsiveHeight(context, 20),
                ),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.trim().toLowerCase();
                    });
                  },
                  style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search',
                    hintStyle: AppTextStyles.textTheme.bodyMedium,
                    filled: true,
                    fillColor: AppColors.surface,
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      size: responsiveWidth(context, 24),
                      color: AppColors.textSecondary,
                    ),
                    suffixIcon: IconButton(
                      tooltip: 'Filter services',
                      onPressed: _openFilter,
                      icon: Icon(
                        Icons.tune_rounded,
                        size: responsiveWidth(context, 24),
                        color: _filter.isActive
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: responsiveWidth(context, 16),
                      vertical: responsiveHeight(context, 16),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        responsiveWidth(context, 18),
                      ),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        responsiveWidth(context, 18),
                      ),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: widget.controller.loading
                    ? const Center(child: CircularProgressIndicator())
                    : widget.controller.error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(widget.controller.error!),
                            TextButton(
                              onPressed: widget.controller.load,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : filteredServices.isEmpty
                    ? Center(
                        child: Text(
                          'No services found',
                          style: AppTextStyles.textTheme.bodyMedium,
                        ),
                      )
                    : ListView.separated(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: EdgeInsets.fromLTRB(
                          responsiveWidth(context, 16),
                          responsiveHeight(context, 4),
                          responsiveWidth(context, 16),
                          responsiveHeight(context, 110),
                        ),
                        itemCount: filteredServices.length,
                        separatorBuilder: (_, _) =>
                            SizedBox(height: responsiveHeight(context, 16)),
                        itemBuilder: (context, index) {
                          final service = filteredServices[index];

                          return InkWell(
                            borderRadius: BorderRadius.circular(
                              responsiveWidth(context, 24),
                            ),
                            onTap: () => Navigator.push<void>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CompanyServiceDetailsScreen(
                                  service: service,
                                  controller: widget.controller,
                                ),
                              ),
                            ),
                            child: CompanyServiceCard(
                              id: service.id,
                              title: service.title,
                              date: service.date,
                              imagePath: service.imagePath,
                              isActive:
                                  service.status ==
                                  CompanyServiceStatus.accepted,
                              status: service.status,
                              description: service.description,
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
