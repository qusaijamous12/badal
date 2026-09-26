import 'package:badal/app/swap/discover_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  testWidgets('category chips build and react without an improper Obx error', (
    tester,
  ) async {
    final category = 'الكل'.obs;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: CategoryFilters(category: category)),
      ),
    );

    expect(tester.takeException(), isNull);
    await tester.tap(find.text('كتب'));
    await tester.pump();
    expect(category.value, 'كتب');
    expect(tester.takeException(), isNull);
  });
}
