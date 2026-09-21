import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nama_project/main.dart';

void main() {
  testWidgets('renders the OnTimeIn home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const OnTimeInApp());

    expect(find.text('Good Morning, Naufal'), findsOneWidget);
    expect(find.text('Your task overview'), findsOneWidget);
    expect(find.text('Mobile Programming Assignment'), findsOneWidget);
    expect(find.text('Add Task'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('can mark an upcoming task as completed', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const OnTimeInApp());

    final taskCheckbox = find.byType(Checkbox).first;
    await tester.tap(taskCheckbox);
    await tester.pump();

    expect(tester.widget<Checkbox>(taskCheckbox).value, isTrue);
  });
}
