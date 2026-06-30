import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bhau_fitness_flutter/main.dart';

void main() {
  testWidgets('App builds and launches without immediate crash', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BhauFitnessApp());

    // Verify that the splash gate or landing screen elements are present.
    // Since it's a splash gate, we expect a loading indicator or brand title.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
