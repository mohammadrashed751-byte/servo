import 'package:servo/core/network/marketplace_api.dart';
import 'package:servo/core/widgets/api_content.dart';
import 'package:flutter/material.dart';

import 'package:servo/core/theme/app_colors.dart';
import 'package:servo/core/utils/responsive.dart';

import 'notification_item.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          'Notification',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(color: AppColors.surface),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ColoredBox(
                color: AppColors.surface,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsiveWidth(context, 24),
                    vertical: responsiveHeight(context, 24),
                  ),
                  child: Text(
                    'Notifications',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ),

              Divider(
                height: responsiveHeight(context, 1),
                thickness: 1,
                color: AppColors.border,
              ),

              Expanded(
                child: ApiContent<List<JsonMap>>(
                  load: () => MarketplaceApi().list('notifications'),
                  builder: (context, items) => items.isEmpty
                      ? const Center(child: Text('No notifications yet'))
                      : ListView.separated(
                          padding: EdgeInsets.symmetric(
                            horizontal: responsiveWidth(context, 20),
                          ),
                          itemCount: items.length,
                          separatorBuilder: (_, _) =>
                              const Divider(height: 1, color: AppColors.border),
                          itemBuilder: (context, index) {
                            final item = items[index];
                            final payload = apiMap(item['data']);
                            return InkWell(
                              onTap: () async {
                                try {
                                  await MarketplaceApi().request(
                                    'notifications/${item['id']}/read',
                                    method: 'POST',
                                  );
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('$e')),
                                    );
                                  }
                                }
                              },
                              child: NotificationItem(
                                title: apiText(
                                  item['title'] ?? payload['title'],
                                ),
                                message: apiText(
                                  item['body'] ??
                                      payload['body'] ??
                                      payload['message'],
                                ),
                                time: apiText(item['created_at']),
                                backgroundColor: AppColors.primary.withAlpha(
                                  18,
                                ),
                                icon: const Icon(
                                  Icons.notifications_rounded,
                                  color: AppColors.primary,
                                  size: 28,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
