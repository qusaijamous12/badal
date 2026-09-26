import 'package:badal/app/auth/welcome_page.dart';
import 'package:badal/app/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('welcome page fits a small phone and shows both entry paths', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: BadalTheme.light,
        home: const Directionality(
          textDirection: TextDirection.rtl,
          child: WelcomePage(),
        ),
      ),
    );

    expect(find.text('ابدأ رحلتك مع بدل'), findsOneWidget);
    expect(find.text('لدي حساب بالفعل'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
