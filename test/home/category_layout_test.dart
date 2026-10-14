import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:servo/core/utils/responsive.dart';
import 'package:servo/feature/user_account/home/presentation/widgets/category_item.dart';

void main() {
  for (final size in [
    const Size(320, 568),
    const Size(393, 851),
    const Size(430, 932),
  ]) {
    for (final textScale in [1.0, 2.0]) {
      testWidgets('category labels fit at $size with text scale $textScale', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        var taps = 0;
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(
                size: size,
                textScaler: TextScaler.linear(textScale),
              ),
              child: Scaffold(
                body: Builder(
                  builder: (context) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: SizedBox(
                        height: responsiveHeight(context, 120).clamp(
                          CategoryItem.minimumHeight(context),
                          double.infinity,
                        ),
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            for (final title in [
                              'Home Services',
                              'Moving & Shifting',
                            ])
                              SizedBox(
                                width: responsiveWidth(context, 80),
                                child: CategoryItem(
                                  title: title,
                                  icon: Icons.home,
                                  onTap: () => taps++,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('Moving & Shifting'));
        expect(taps, 1);
      });
    }
  }
}
