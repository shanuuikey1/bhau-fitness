// Basic smoke test for the BHAU FITNESS app.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bhau_fitness_flutter/theme/app_theme.dart';

void main() {
  testWidgets('theme builds and renders a basic scaffold', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildBhauTheme(),
      home: const Scaffold(body: Center(child: Text('BHAU FITNESS'))),
    ));
    expect(find.text('BHAU FITNESS'), findsOneWidget);
  });
}
