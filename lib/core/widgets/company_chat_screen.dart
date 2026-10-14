import 'package:flutter/material.dart';
import '../network/marketplace_api.dart';
import 'chat_screen.dart';

class CompanyChatScreen extends StatelessWidget {
  const CompanyChatScreen({
    super.key,
    this.conversationId,
    this.bookingId,
    this.name = '',
    this.avatar = '',
    this.api,
  });
  final String? conversationId;
  final String? bookingId;
  final String name;
  final String avatar;
  final MarketplaceApi? api;
  @override
  Widget build(BuildContext context) => ChatScreen(
    conversationId: conversationId,
    bookingId: bookingId,
    name: name,
    avatar: avatar,
    api: api,
  );
}
