import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:servo/core/widgets/chat_screen.dart';

void main() {
  testWidgets('Closing chat before delayed scrolling is safe', (tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: ChatScreen()));
    await tester.enterText(find.byType(TextField), 'A new message');
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pump();

    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );

    // Dispose the screen while its delayed scroll is still pending.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 200));

    expect(tester.takeException(), isNull);
  });
}
