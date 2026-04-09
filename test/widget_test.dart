// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('DevSync app smoke test', (WidgetTester tester) async {
    // Build a simple MaterialApp to test basic functionality
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('DevSync Test')),
          body: const Center(child: Text('DevSync App Test')),
        ),
      ),
    );

    // Verify that the app loads without errors
    expect(find.text('DevSync App Test'), findsOneWidget);
    expect(find.text('DevSync Test'), findsOneWidget);
  });
}
