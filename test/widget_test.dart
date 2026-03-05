import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('Muestra la lista de productos', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(appBar: AppBar(title: Text('Productos'))),
      ),
    );
    expect(find.text('Productos'), findsOneWidget);
  });
}
