import 'package:servo/core/widgets/notifications_screen.dart';
import '../controllers/company_services_controller.dart';
import '../widgets/company_service_filter.dart';
import 'company_service_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:servo/core/theme/app_colors.dart';
import 'package:servo/core/theme/app_theme.dart';
import 'package:servo/core/utils/responsive.dart';
import '../widgets/company_service_card.dart';
import '../widgets/company_stats_card.dart';
import 'company_services_screen.dart';

class CompanyDashboardScreen extends StatefulWidget {
  const CompanyDashboardScreen({super.key});

  @override
  State<CompanyDashboardScreen> createState() => _CompanyDashboardScreenState();
}

class _CompanyDashboardScreenState extends State<CompanyDashboardScreen> {
  final _controller = CompanyServicesController();

  @override
  void initState() {
    super.initState();
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) => Scaffold(
        backgroundColor: AppColors.dark,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.dark,
          foregroundColor: AppColors.surface,
          surfaceTintColor: AppColors.dark,
          elevation: 0,
          centerTitle: true,
          toolbarHeight: responsiveHeight(context, 64),
          leadingWidth: responsiveWidth(context, 56),
          leading: Icon(
            Icons.dashboard_rounded,
            size: responsiveWidth(context, 22),
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: responsiveWidth(context, 14),
                backgroundColor: AppColors.surface,
                child: Icon(
                  Icons.diamond_rounded,
                  color: AppColors.primary,
                  size: responsiveWidth(context, 16),
                ),
              ),
              SizedBox(width: responsiveWidth(context, 8)),
              Text(
                'Service',
                style: AppTextStyles.textTheme.headlineMedium?.copyWith(
                  color: AppColors.surface,
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: responsiveWidth(context, 20)),
              child: IconButton(
                tooltip: 'Notifications',
                onPressed: () => Navigator.push<void>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationsScreen(),
                  ),
                ),
                icon: Icon(
                  Icons.notifications_rounded,
                  size: responsiveWidth(context, 22),
                ),
              ),
            ),
          ],
        ),
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  responsiveWidth(context, 28),
                  responsiveHeight(context, 24),
                  responsiveWidth(context, 28),
                  responsiveHeight(context, 32),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${_controller.companyName} 👋',
                      style: AppTextStyles.heavyTitle1.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: responsiveHeight(context, 8)),
                    Text(
                      'Service Provider',
                      style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                        color: AppColors.surface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: responsiveWidth(context, 20),
                  vertical: responsiveHeight(context, 24),
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(responsiveWidth(context, 36)),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_controller.loading) const LinearProgressIndicator(),
                    if (_controller.error != null) ...[
                      Text(_controller.error!),
                      TextButton(
                        onPressed: _controller.load,
                        child: const Text('Retry'),
                      ),
                    ],
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: responsiveWidth(context, 16),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: CompanyStatsCard(
                              title: 'Total Services',
                              value: _controller.services.length.toString(),
                            ),
                          ),
                          SizedBox(width: responsiveWidth(context, 28)),
                          Expanded(
                            child: CompanyStatsCard(
                              title: 'Active Services',
                              value: _controller.activeCount.toString(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: responsiveHeight(context, 28)),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: responsiveWidth(context, 4),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Service',
                              style: AppTextStyles.heavyTitle4,
                            ),
                          ),
                          IconButton(
                            tooltip: 'View all services',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (_) => CompanyServicesScreen(
                                    controller: _controller,
                                  ),
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.textPrimary,
                              size: responsiveWidth(context, 24),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: responsiveHeight(context, 16)),
                    if (_controller.services.isEmpty)
                      Text(
                        'No services found',
                        style: AppTextStyles.textTheme.bodyMedium,
                      ),
                    for (final service in _controller.services.take(2)) ...[
                      InkWell(
                        borderRadius: BorderRadius.circular(
                          responsiveWidth(context, 24),
                        ),
                        onTap: () => Navigator.push<void>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CompanyServiceDetailsScreen(
                              service: service,
                              controller: _controller,
                            ),
                          ),
                        ),
                        child: CompanyServiceCard(
                          id: service.id,
                          title: service.title,
                          date: service.date,
                          imagePath: service.imagePath,
                          isActive:
                              service.status == CompanyServiceStatus.accepted,
                          status: service.status,
                          description: service.description,
                        ),
                      ),
                      SizedBox(height: responsiveHeight(context, 16)),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
