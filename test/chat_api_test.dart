import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:servo/core/network/chat_controller.dart';
import 'package:servo/core/network/marketplace_api.dart';

class ChatFixtureApi extends MarketplaceApi {
  bool failSend = false;
  bool failRead = false;
  final sent = <FormData>[];
  final messages = <JsonMap>[];
  @override
  Future<dynamic> request(
    String path, {
    String method = 'GET',
    Object? data,
    JsonMap? query,
  }) async {
    if (path == 'me') return {'id': 2};
    if (path == 'conversations') {
      expect((data as Map)['booking_id'], 7);
      return {'id': 4};
    }
    expect(path, 'conversations/4/messages');
    expect(method, 'POST');
    if (failSend) throw const ApiFailure('Send rejected');
    final form = data! as FormData;
    sent.add(form);
    final fields = Map.fromEntries(form.fields);
    messages.add({
      'id': messages.length + 1,
      'body': fields['body'],
      'sender_id': 2,
      'created_at': '2026-10-13T09:00:00Z',
    });
    return messages.last;
  }

  @override
  Future<List<JsonMap>> list(String path, {JsonMap? query}) async {
    expect(path, 'conversations/4/messages');
    if (failRead) throw const ApiFailure('Unable to refresh');
    return List.of(messages);
  }
}

void main() {
  test(
    'chat sends documented multipart body; failure never creates a local message',
    () async {
      final api = ChatFixtureApi();
      final chat = ChatController(api: api, bookingId: '7');
      addTearDown(chat.dispose);
      await chat.load();
      expect(chat.conversationId, '4');
      expect(chat.messages, isEmpty);
      api.failSend = true;
      await expectLater(chat.send('Hello'), throwsA(isA<ApiFailure>()));
      expect(chat.messages, isEmpty);
      expect(chat.sending, isFalse);
      api.failSend = false;
      expect(await chat.send(' Hello '), isTrue);
      expect(Map.fromEntries(api.sent.single.fields), {'body': 'Hello'});
      expect(chat.messages.single.text, 'Hello');
      expect(chat.messages.single.isMe, isTrue);
    },
  );
  test(
    'acknowledged send remains successful when refreshing messages fails',
    () async {
      final api = ChatFixtureApi();
      final chat = ChatController(api: api, conversationId: '4');
      addTearDown(chat.dispose);
      await chat.load();
      api.failRead = true;
      expect(await chat.send('Once'), isTrue);
      expect(api.sent.length, 1);
      expect(chat.error, 'Unable to refresh');
      api.failRead = false;
      await chat.load();
      expect(chat.messages.single.text, 'Once');
      expect(api.sent.length, 1);
    },
  );
}
