import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nama_project/main.dart';

Future<void> _signIn(WidgetTester tester) async {
  await tester.pumpWidget(const OnTimeInApp());
  await tester.enterText(
    find.byType(TextFormField).at(0),
    'student@example.com',
  );
  await tester.enterText(find.byType(TextFormField).at(1), 'password123');
  await tester.ensureVisible(find.text('Masuk'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Masuk'));
  await tester.pump(const Duration(seconds: 2));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders the OnTimeIn home screen', (WidgetTester tester) async {
    await _signIn(tester);

    expect(find.text('Good Morning, Sir'), findsOneWidget);
    expect(find.text("Let's get your tasks done."), findsOneWidget);
    expect(find.text('Mobile Programming Assignment'), findsOneWidget);
    expect(find.text('Add Task'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('can mark an upcoming task as completed', (
    WidgetTester tester,
  ) async {
    await _signIn(tester);

    final taskCheckbox = find.byType(Checkbox).first;
    await tester.tap(taskCheckbox);
    await tester.pump();

    expect(tester.widget<Checkbox>(taskCheckbox).value, isTrue);
  });
}
