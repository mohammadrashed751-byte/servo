import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'marketplace_api.dart';

class ChatRecord {
  const ChatRecord({
    required this.text,
    required this.isMe,
    required this.time,
    this.attachment = '',
  });
  final String text;
  final bool isMe;
  final String time;
  final String attachment;
}

class ChatController extends ChangeNotifier {
  ChatController({
    MarketplaceApi? api,
    this.conversationId,
    this.bookingId,
    this.providerId,
  }) : api = api ?? MarketplaceApi();
  final MarketplaceApi api;
  String? conversationId;
  final String? bookingId;
  final int? providerId;
  String? _selfId;
  bool loading = false;
  bool sending = false;
  bool _disposed = false;
  String? error;
  List<ChatRecord> messages = [];
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> load() async {
    if (loading) return;
    loading = true;
    error = null;
    _notify();
    try {
      if (_selfId == null) {
        final me = apiMap(await api.request('me'));
        if (me['id'] == null) {
          throw const ApiFailure('Unable to identify your account.');
        }
        _selfId = '${me['id']}';
      }
      if (conversationId == null) {
        if (bookingId == null && providerId == null) {
          throw const ApiFailure(
            'Open a conversation from a booking or the messages list.',
          );
        }
        final data = apiMap(
          await api.request(
            'conversations',
            method: 'POST',
            data: {
              if (bookingId != null) 'booking_id': int.parse(bookingId!),
              if (bookingId == null && providerId != null)
                'provider_id': providerId,
            },
          ),
        );
        if (data['id'] == null) {
          throw const ApiFailure(
            'The server did not return a conversation ID.',
          );
        }
        conversationId = '${data['id']}';
      }
      final rows = await api.list('conversations/$conversationId/messages');

      rows.sort(
        (a, b) => apiText(a['created_at']).compareTo(apiText(b['created_at'])),
      );
      messages = rows.map((row) {
        final sender = row['sender_id'] ?? apiMap(row['sender'])['id'];
        final mine = row['is_mine'] ?? row['is_me'];
        if (sender == null && mine is! bool) {
          throw const ApiFailure(
            'The server returned a message without its sender.',
          );
        }
        final rawAttachment = row['attachment_url'] ?? row['attachment'];
        final attachment = rawAttachment is Map
            ? apiText(rawAttachment['url'])
            : apiText(rawAttachment);
        final body = apiText(row['body']);
        if (body.isEmpty && attachment.isEmpty) {
          throw const ApiFailure('The server returned an unsupported message.');
        }
        return ChatRecord(
          text: body,
          attachment: attachment,
          isMe: mine is bool ? mine : '$sender' == _selfId,
          time: apiText(row['created_at']),
        );
      }).toList();
    } catch (e) {
      error = '$e';
    } finally {
      loading = false;
      _notify();
    }
  }

  Future<bool> send(String text, {MultipartFile? attachment}) async {
    if (sending || loading || conversationId == null) return false;
    final body = text.trim();
    if (body.isEmpty && attachment == null) return false;
    if (body.length > 5000) {
      throw const ApiFailure('Messages can contain up to 5000 characters.');
    }
    sending = true;
    _notify();
    try {
      await api.request(
        'conversations/$conversationId/messages',
        method: 'POST',
        data: FormData.fromMap({
          if (body.isNotEmpty) 'body': body,
          'attachment': ?attachment,
        }),
      );
      await load();
      return true;
    } finally {
      sending = false;
      _notify();
    }
  }
}

JsonMap conversationPeer(JsonMap conversation, JsonMap me) {
  for (final key in [
    'other_user',
    'participant',
    me['role'] == 'provider' ? 'customer' : 'provider',
  ]) {
    final candidate = apiMap(conversation[key]);
    if (candidate.isNotEmpty && '${candidate['id']}' != '${me['id']}') {
      return candidate;
    }
  }
  final participants = conversation['participants'];
  if (participants is List) {
    for (final value in participants) {
      final person = apiMap(value);
      if (person['id'] != null && '${person['id']}' != '${me['id']}') {
        return person;
      }
    }
  }
  return {};
}
