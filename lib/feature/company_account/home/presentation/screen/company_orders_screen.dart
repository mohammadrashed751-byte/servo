import 'package:servo/core/widgets/booking_actions_menu.dart';
import 'package:servo/core/widgets/api_content.dart';
import 'package:servo/core/widgets/service_image.dart';
import 'package:flutter/material.dart';
import 'package:servo/core/theme/app_colors.dart';
import 'package:servo/core/theme/app_theme.dart';
import 'package:servo/core/utils/responsive.dart';
import 'package:servo/core/widgets/company_chat_screen.dart';
import '../controllers/company_services_controller.dart';

class CompanyOrdersScreen extends StatelessWidget {
  const CompanyOrdersScreen({
    super.key,
    required this.serviceId,
    required this.controller,
  });

  final String serviceId;
  final CompanyServicesController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        backgroundColor: AppColors.dark,
        surfaceTintColor: AppColors.dark,
        foregroundColor: AppColors.surface,
        centerTitle: true,
        title: Text(
          'Orders',
          style: AppTextStyles.textTheme.headlineMedium?.copyWith(
            color: AppColors.surface,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(responsiveWidth(context, 36)),
            ),
          ),
          child: ApiContent<bool>(
            load: () async {
              await controller.loadOrders(serviceId);
              return true;
            },
            builder: (context, _) => ListenableBuilder(
              listenable: controller,
              builder: (context, _) {
                final orders = controller.ordersFor(serviceId);
                if (orders.isEmpty) {
                  return Center(
                    child: Text(
                      'No orders yet',
                      style: AppTextStyles.textTheme.bodyMedium,
                    ),
                  );
                }
                return ListView.separated(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsiveWidth(context, 20),
                    vertical: responsiveHeight(context, 36),
                  ),
                  itemCount: orders.length,
                  separatorBuilder: (_, _) =>
                      SizedBox(height: responsiveHeight(context, 20)),
                  itemBuilder: (context, index) =>
                      _orderCard(context, orders[index]),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _orderCard(BuildContext context, CompanyOrderPreview order) {
    return Container(
      padding: EdgeInsets.all(responsiveWidth(context, 10)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(responsiveWidth(context, 28)),
        boxShadow: [
          BoxShadow(
            color: AppColors.dark.withAlpha(18),
            blurRadius: responsiveWidth(context, 12),
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(responsiveWidth(context, 22)),
            child: ServiceImage(
              order.avatarPath,
              isAvatar: true,
              width: responsiveWidth(context, 112),
              height: responsiveHeight(context, 132),
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: responsiveWidth(context, 14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order.date, style: AppTextStyles.textTheme.bodySmall),
                SizedBox(height: responsiveHeight(context, 4)),
                Text(
                  order.name,
                  style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Semantics(
                  label: '${order.rating} out of 5 stars',
                  child: Row(
                    children: List.generate(
                      5,
                      (index) => Icon(
                        Icons.star_rounded,
                        size: responsiveWidth(context, 15),
                        color: index < order.rating
                            ? AppColors.pending
                            : AppColors.grey,
                      ),
                    ),
                  ),
                ),
                Text('Delivery Date', style: AppTextStyles.textTheme.bodySmall),
                Text(
                  order.deliveryDate,
                  style: AppTextStyles.textTheme.headlineMedium?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          BookingActionsMenu(
            id: order.id,
            status: order.status,
            provider: true,
            api: controller.api,
            onChanged: () => controller.loadOrders(serviceId),
          ),
          IconButton(
            tooltip: order.accepted ? 'Open chat' : 'Accept order',
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary.withAlpha(22),
              foregroundColor: AppColors.primary,
            ),
            icon: Icon(
              order.accepted
                  ? Icons.chat_bubble_outline_rounded
                  : Icons.check_rounded,
              size: responsiveWidth(context, 22),
            ),
            onPressed:
                controller.isBusy(order.id) ||
                    (!order.accepted && order.status != 'pending')
                ? null
                : () async {
                    try {
                      if (order.accepted) {
                        Navigator.push<void>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CompanyChatScreen(
                              bookingId: order.id,
                              name: order.name,
                              avatar: order.avatarPath,
                              api: controller.api,
                            ),
                          ),
                        );
                      } else {
                        await controller.acceptOrder(serviceId, order.id);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('$e')));
                      }
                    }
                  },
          ),
        ],
      ),
    );
  }
}
