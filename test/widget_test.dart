import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vitalaid/test_app.dart';

void main() {
  testWidgets('TestApp loads correctly', (WidgetTester tester) async {
    // Build our test app and trigger a frame.
    await tester.pumpWidget(const TestApp());

    // Verify that our test app loads with the expected content.
    expect(find.text('VitalAid Test App'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('TestApp is a StatelessWidget', (WidgetTester tester) async {
    await tester.pumpWidget(const TestApp());
    expect(find.byType(TestApp), findsOneWidget);
  });

  testWidgets('App has proper theme', (WidgetTester tester) async {
    await tester.pumpWidget(const TestApp());
    
    // Verify that MaterialApp is properly configured
    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.title, equals('VitalAid (Test)'));
    expect(materialApp.theme, isNotNull);
  });
}
