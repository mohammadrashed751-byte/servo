import 'package:flutter/material.dart';
import '../network/chat_controller.dart';
import '../network/marketplace_api.dart';
import '../theme/app_colors.dart';
import '../utils/responsive.dart';
import 'api_content.dart';
import 'chat_screen.dart';
import 'company_chat_screen.dart';
import 'service_image.dart';

class ConversationsList extends StatefulWidget {
  const ConversationsList({super.key, this.company = false});
  final bool company;
  @override
  State<ConversationsList> createState() => _ConversationsListState();
}

class _ConversationsListState extends State<ConversationsList> {
  String _query = '';
  int _revision = 0;
  @override
  Widget build(BuildContext context) => ApiContent<JsonMap>(
    key: ValueKey(_revision),
    load: () async {
      final api = MarketplaceApi();
      final values = await Future.wait([
        api.list('conversations'),
        api.request('me'),
      ]);
      return {'items': values[0], 'me': values[1]};
    },
    builder: (context, data) {
      final me = apiMap(data['me']);
      final items = (data['items'] as List<JsonMap>)
          .where(
            (row) => apiText(
              conversationPeer(row, me)['name'],
            ).toLowerCase().contains(_query),
          )
          .toList();
      return Column(
        children: [
          Padding(
            padding: EdgeInsets.all(responsiveWidth(context, 20)),
            child: TextField(
              onChanged: (value) =>
                  setState(() => _query = value.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search',
                filled: true,
                fillColor: AppColors.surface,
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textSecondary,
                ),
                suffixIcon: IconButton(
                  tooltip: 'Refresh conversations',
                  onPressed: () => setState(() {
                    _query = '';
                    _revision++;
                  }),
                  icon: const Icon(Icons.refresh),
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
          ),
          Expanded(
            child: items.isEmpty
                ? const Center(child: Text('No conversations found'))
                : ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsiveWidth(context, 20),
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final peer = conversationPeer(item, me);
                      final name = apiText(peer['name']);
                      final avatar = apiText(peer['avatar']);
                      return SizedBox(
                        height: responsiveWidth(context, 76),
                        child: Row(
                          children: [
                            Container(
                              width: responsiveWidth(context, 56),
                              height: responsiveWidth(context, 56),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.primary),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(11),
                                child: ServiceImage(avatar, isAvatar: true),
                              ),
                            ),
                            SizedBox(width: responsiveWidth(context, 10)),
                            Expanded(
                              child: Text(
                                name.isEmpty
                                    ? 'Conversation #${item['id']}'
                                    : name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Open chat',
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.primary.withAlpha(
                                  20,
                                ),
                                foregroundColor: AppColors.primary,
                              ),
                              icon: const Icon(
                                Icons.chat_bubble_outline_rounded,
                              ),
                              onPressed: item['id'] == null
                                  ? null
                                  : () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => widget.company
                                            ? CompanyChatScreen(
                                                conversationId: '${item['id']}',
                                                name: name,
                                                avatar: avatar,
                                              )
                                            : ChatScreen(
                                                conversationId: '${item['id']}',
                                                name: name,
                                                avatar: avatar,
                                              ),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      );
    },
  );
}
