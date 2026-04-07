import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saptak_access_app/auth/login_page.dart';

void main() {
  testWidgets('Login page renders expected text', (tester) async {
    await tester.pumpWidget(const TestApp());

    expect(find.text('Saptak Container Access'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: LoginPage());
  }
}
