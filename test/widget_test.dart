// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:tasky/app/my_app.dart';

void main() {
  testWidgets('App renders WelcomeScreen when username is null', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(username: null));
    await tester.pumpAndSettle();

    expect(find.text('Tasky'), findsWidgets);
    expect(find.text('Welcome To Tasky'), findsOneWidget);
  });
}
