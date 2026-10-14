import 'image_upload.dart';
import 'package:servo/core/widgets/notifications_screen.dart';
import '../network/chat_controller.dart';
import '../network/marketplace_api.dart';
import 'service_image.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/responsive.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    this.conversationId,
    this.bookingId,
    this.providerId,
    this.name = '',
    this.avatar = '',
    this.api,
  });
  final String? conversationId;
  final String? bookingId;
  final int? providerId;
  final String name;
  final String avatar;
  final MarketplaceApi? api;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late final ChatController _chat;
  UploadImage? _attachment;
  bool _picking = false;
  @override
  void initState() {
    super.initState();
    _chat = ChatController(
      api: widget.api,
      conversationId: widget.conversationId,
      bookingId: widget.bookingId,
      providerId: widget.providerId,
    );
    _chat.addListener(_refresh);
    _chat.load();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _sendMessage() async {
    try {
      if (await _chat.send(
        _controller.text,
        attachment: _attachment?.multipart(),
      )) {
        if (!mounted) return;
        _controller.clear();
        setState(() => _attachment = null);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  Future<void> _pickImage() async {
    if (_picking || _chat.sending) return;
    setState(() => _picking = true);
    try {
      final image = await chooseImage(context, maxMegabytes: 8);
      if (mounted && image != null) setState(() => _attachment = image);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  void _unavailable() => ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('This feature is not available yet.')),
  );

  @override
  void dispose() {
    _chat.removeListener(_refresh);
    _chat.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,

      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.dark,
        surfaceTintColor: AppColors.dark,
        elevation: 0,

        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.surface),
        ),

        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Chat',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: AppColors.surface),
            ),
          ],
        ),

        actions: [
          IconButton(
            tooltip: 'Refresh messages',
            onPressed: _chat.loading || _chat.sending ? null : _chat.load,
            icon: const Icon(Icons.refresh, color: AppColors.surface),
          ),
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
          SizedBox(width: responsiveWidth(context, 20)),
        ],
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
              SizedBox(height: responsiveHeight(context, 15)),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: responsiveWidth(context, 30),
                  vertical: responsiveHeight(context, 13),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: responsiveWidth(context, 50),
                              height: responsiveHeight(context, 50),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.primary),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(11),
                                child: ServiceImage(
                                  widget.avatar,
                                  isAvatar: true,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: AppColors.grey,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.dark,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: responsiveWidth(context, 15)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: responsiveWidth(context, 185),
                              child: Text(
                                widget.name.isEmpty
                                    ? 'Conversation'
                                    : widget.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                            SizedBox(height: responsiveHeight(context, 5)),
                            Text(
                              '',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppColors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    IconButton(
                      tooltip: 'Call provider',
                      onPressed: _unavailable,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.orange.withAlpha(30),
                        foregroundColor: Colors.orange,
                        shape: const CircleBorder(),
                      ),
                      icon: const Icon(Icons.phone_outlined, size: 20),
                    ),
                  ],
                ),
              ),
              SizedBox(height: responsiveHeight(context, 8)),
              Divider(
                height: responsiveHeight(context, 2),
                thickness: 2,
                color: AppColors.border,
              ),

              Expanded(
                child: _chat.loading && _chat.messages.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : _chat.error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_chat.error!),
                            TextButton(
                              onPressed: _chat.load,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _chat.messages.isEmpty
                    ? const Center(child: Text('No messages yet'))
                    : ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.symmetric(
                          horizontal: responsiveWidth(context, 16),
                          vertical: responsiveHeight(context, 16),
                        ),
                        itemCount: _chat.messages.length,
                        itemBuilder: (context, index) {
                          final message = _chat.messages[index];
                          return _MessageBubble(message: message);
                        },
                      ),
              ),

              if (_attachment != null)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Image.memory(
                        _attachment!.bytes,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                      ),
                      Expanded(
                        child: Text(
                          _attachment!.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Remove attachment',
                        onPressed: _chat.sending
                            ? null
                            : () => setState(() => _attachment = null),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
              Container(
                color: AppColors.surface,
                padding: EdgeInsets.fromLTRB(
                  responsiveWidth(context, 12),
                  responsiveHeight(context, 8),
                  responsiveWidth(context, 12),
                  responsiveHeight(context, 12) +
                      MediaQuery.paddingOf(context).bottom,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed:
                          _picking ||
                              _chat.sending ||
                              _chat.conversationId == null
                          ? null
                          : _pickImage,
                      icon: const Icon(
                        Icons.image_outlined,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    IconButton(
                      onPressed: _unavailable,
                      icon: const Icon(
                        Icons.mic_none_rounded,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        enabled:
                            !_chat.sending &&
                            !_chat.loading &&
                            _chat.conversationId != null,
                        maxLength: 5000,
                        style: Theme.of(context).textTheme.bodyMedium,
                        decoration: InputDecoration(
                          hintText: 'Aa',
                          counterText: '',
                          hintStyle: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                          filled: true,
                          fillColor: AppColors.background,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: responsiveWidth(context, 16),
                            vertical: responsiveHeight(context, 10),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                            onPressed: _unavailable,
                            icon: const Icon(
                              Icons.emoji_emotions_outlined,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _chat.sending || _chat.loading
                          ? null
                          : _sendMessage,
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: _chat.sending
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.surface,
                                ),
                              )
                            : const Icon(
                                Icons.send_rounded,
                                color: AppColors.surface,
                                size: 20,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatRecord message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: responsiveHeight(context, 16)),
      child: Column(
        crossAxisAlignment: message.isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.65,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: responsiveWidth(context, 16),
              vertical: responsiveHeight(context, 12),
            ),
            decoration: BoxDecoration(
              color: message.isMe ? AppColors.primary : AppColors.background,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(message.isMe ? 20 : 4),
                bottomRight: Radius.circular(message.isMe ? 4 : 20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (message.attachment.isNotEmpty)
                  Image.network(
                    message.attachment,
                    width: 200,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) =>
                        SelectableText('Attachment: ${message.attachment}'),
                  ),
                if (message.text.isNotEmpty)
                  Text(
                    message.text,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: message.isMe
                          ? AppColors.surface
                          : AppColors.textPrimary,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: responsiveHeight(context, 4)),
          Text(
            message.time,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
