import 'package:servo/core/network/marketplace_api.dart';
import 'package:servo/core/widgets/service_image.dart';
import 'company_orders_screen.dart';
import 'package:flutter/material.dart';
import 'package:servo/core/theme/app_colors.dart';
import 'package:servo/core/theme/app_theme.dart';
import 'package:servo/core/utils/responsive.dart';
import '../controllers/company_services_controller.dart';
import 'add_service_screen.dart';

class CompanyServiceDetailsScreen extends StatefulWidget {
  const CompanyServiceDetailsScreen({
    super.key,
    required this.service,
    required this.controller,
  });

  final CompanyServicePreview service;
  final CompanyServicesController controller;

  @override
  State<CompanyServiceDetailsScreen> createState() =>
      _CompanyServiceDetailsScreenState();
}

class _CompanyServiceDetailsScreenState
    extends State<CompanyServiceDetailsScreen> {
  late CompanyServicePreview _service = widget.service;
  bool _deleting = false;
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_refresh);
    _loadOrderCount();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _loadOrderCount() async {
    try {
      await widget.controller.loadOrders(_service.id);
    } catch (_) {
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    super.dispose();
  }

  Future<void> _edit() async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddServiceScreen(
          categories: widget.controller.categories
              .map((c) => apiText(c['name']))
              .toList(),
          initialInput: NewServiceInput(
            name: _service.title,
            category: _service.category,
            durationMinutes: _service.durationMinutes,
            price: _service.price,
            description: _service.description,
          ),
          onSave: (input) async {
            final updated = _service.copyWith(
              title: input.name,
              category: input.category,
              durationMinutes: input.durationMinutes,
              price: input.price,
              description: input.description,
            );
            await widget.controller.update(updated);
            if (mounted) setState(() => _service = updated);
          },
        ),
      ),
    );
  }

  Future<void> _delete() async {
    if (_deleting) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete service?'),
        content: Text('Delete "${_service.title}" from your services?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.failed),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    setState(() => _deleting = true);
    try {
      await widget.controller.delete(_service.id);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) setState(() => _deleting = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final delivery = _service.deliveryDate;
    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        backgroundColor: AppColors.dark,
        surfaceTintColor: AppColors.dark,
        foregroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: responsiveWidth(context, 28),
                vertical: responsiveHeight(context, 16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(
                      responsiveWidth(context, 24),
                    ),
                    onTap: () => Navigator.push<void>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CompanyOrdersScreen(
                          serviceId: _service.id,
                          controller: widget.controller,
                        ),
                      ),
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: responsiveWidth(context, 14),
                        vertical: responsiveHeight(context, 10),
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withAlpha(15),
                        borderRadius: BorderRadius.circular(
                          responsiveWidth(context, 24),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Orders',
                            style: AppTextStyles.textTheme.bodySmall?.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(width: responsiveWidth(context, 10)),
                          CircleAvatar(
                            radius: 10,
                            backgroundColor: AppColors.pending,
                            child: Text(
                              widget.controller.hasLoadedOrders(_service.id)
                                  ? '${widget.controller.ordersFor(_service.id).length}'
                                  : '–',
                              style: AppTextStyles.textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _edit,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      backgroundColor: AppColors.surface.withAlpha(15),
                    ),
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(responsiveWidth(context, 36)),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(responsiveWidth(context, 14)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          responsiveWidth(context, 32),
                        ),
                        child: ServiceImage(
                          _service.imagePath,
                          height: responsiveHeight(context, 235),
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: responsiveWidth(context, 16),
                          vertical: responsiveHeight(context, 24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              _service.date,
                              style: AppTextStyles.textTheme.bodySmall,
                            ),
                            Text(
                              _service.title,
                              style: AppTextStyles.textTheme.headlineLarge,
                            ),
                            SizedBox(height: responsiveHeight(context, 12)),
                            Text(
                              _service.description.isEmpty
                                  ? 'No description provided.'
                                  : _service.description,
                              style: AppTextStyles.textTheme.bodyMedium
                                  ?.copyWith(height: 1.8),
                            ),
                            SizedBox(height: responsiveHeight(context, 24)),
                            Container(
                              padding: EdgeInsets.all(
                                responsiveWidth(context, 16),
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withAlpha(45),
                                borderRadius: BorderRadius.circular(
                                  responsiveWidth(context, 16),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_month_outlined,
                                    color: AppColors.primary,
                                  ),
                                  SizedBox(width: responsiveWidth(context, 14)),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Delivery Date',
                                          style: AppTextStyles
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: AppColors.textPrimary,
                                              ),
                                        ),
                                        Text(
                                          delivery == null
                                              ? 'Not scheduled'
                                              : '${delivery.year}/${delivery.month.toString().padLeft(2, '0')}/${delivery.day.toString().padLeft(2, '0')}',
                                          style: AppTextStyles
                                              .textTheme
                                              .headlineSmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: responsiveHeight(context, 16)),
                            Text(
                              _service.durationMinutes == null
                                  ? 'Duration: Not specified'
                                  : 'Duration: ${_service.durationMinutes} minutes',
                              style: AppTextStyles.textTheme.bodyMedium,
                            ),
                            SizedBox(height: responsiveHeight(context, 8)),
                            Text(
                              "Price: ${_service.price.toStringAsFixed(2)} JD${_service.priceType == 'hourly' ? ' / hour' : ''}",
                              style: AppTextStyles.textTheme.headlineSmall
                                  ?.copyWith(color: AppColors.primary),
                            ),
                            SizedBox(height: responsiveHeight(context, 36)),
                            FilledButton(
                              onPressed: _deleting ? null : _delete,
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.sunsetOrange,
                                foregroundColor: AppColors.surface,
                                minimumSize: Size(
                                  double.infinity,
                                  responsiveHeight(
                                    context,
                                    60,
                                  ).clamp(48, 80).toDouble(),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    responsiveWidth(context, 18),
                                  ),
                                ),
                              ),
                              child: const Text('Delete'),
                            ),
                          ],
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
