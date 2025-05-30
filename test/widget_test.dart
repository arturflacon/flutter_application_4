import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/main.dart';
void main() {
  testWidgets('App should load without errors', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ChacaraBookingApp());

    // Verify that the app loads and shows the home screen
    expect(find.text('Chácara Booking'), findsOneWidget);
    expect(find.text('Clientes'), findsOneWidget);
    expect(find.text('Agendamentos'), findsOneWidget);
    expect(find.text('Serviços'), findsOneWidget);
    expect(find.text('Relatórios'), findsOneWidget);
  });

  testWidgets('Navigation cards should be tappable',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ChacaraBookingApp());

    // Find the cards and verify they exist
    expect(find.byIcon(Icons.people), findsOneWidget);
    expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    expect(find.byIcon(Icons.room_service), findsOneWidget);
    expect(find.byIcon(Icons.assessment), findsOneWidget);
  });
}
