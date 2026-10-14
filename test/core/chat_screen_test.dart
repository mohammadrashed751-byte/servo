import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:servo/core/widgets/chat_screen.dart';
import '../chat_api_test.dart' show ChatFixtureApi;

void main() {
  testWidgets(
    'chat retains text after rejection and clears only after acknowledgement',
    (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final api = ChatFixtureApi()..failSend = true;
      await tester.pumpWidget(
        MaterialApp(
          home: ChatScreen(conversationId: '4', name: 'Company', api: api),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'A new message');
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'A new message',
      );
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      api.failSend = false;
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
      expect(find.text('A new message'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
    },
  );
}
