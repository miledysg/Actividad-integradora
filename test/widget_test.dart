import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tarea1/main.dart';

void main() {
  testWidgets('App loads and shows navigation destinations', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the navigation labels are present
    expect(find.text('Usuarios'), findsAtLeast(1));
    expect(find.text('Favoritos'), findsAtLeast(1));
    
    // Specifically check for the AppBar title in UserListScreen
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Usuarios'),
      ),
      findsOneWidget,
    );
  });
}
