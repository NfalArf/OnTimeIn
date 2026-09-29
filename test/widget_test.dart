import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nama_project/main.dart';
import 'package:nama_project/screens/home_screen.dart';

void main() {
  testWidgets('login validates empty credentials', (WidgetTester tester) async {
    await tester.pumpWidget(const OnTimeInApp());

    await tester.tap(find.widgetWithText(FilledButton, 'Login'));
    await tester.pump();

    expect(find.text('Email wajib diisi'), findsOneWidget);
    expect(find.text('Password wajib diisi'), findsOneWidget);
  });

  testWidgets('login rejects invalid email and short password', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const OnTimeInApp());
    await tester.enterText(
      find.byKey(const ValueKey('login-email')),
      'not-an-email',
    );
    await tester.enterText(
      find.byKey(const ValueKey('login-password')),
      'short',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Login'));
    await tester.pump();

    expect(find.text('Masukkan email yang valid'), findsOneWidget);
    expect(find.text('Password minimal 8 karakter'), findsOneWidget);
    expect(find.text('Good Morning, Naufal'), findsNothing);
  });

  testWidgets('login opens Home and task checkbox still works', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const OnTimeInApp());
    await _login(tester);

    expect(find.text('Good Morning, Naufal'), findsOneWidget);
    expect(find.text('Your task overview'), findsOneWidget);
    expect(find.text('Mobile Programming Assignment'), findsOneWidget);
    expect(find.text('Add Task'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    final taskCheckbox = find.byType(Checkbox).first;
    await tester.tap(taskCheckbox);
    await tester.pump();

    expect(tester.widget<Checkbox>(taskCheckbox).value, isTrue);
  });

  testWidgets('task note is returned to DetailScreen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const OnTimeInApp());
    await _login(tester);

    await tester.tap(find.text('Mobile Programming Assignment').first);
    await tester.pumpAndSettle();
    expect(find.text('Pemrograman Mobile'), findsOneWidget);

    await tester.tap(find.text('Tulis Catatan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simpan'));
    await tester.pump();
    expect(find.text('Catatan wajib diisi'), findsOneWidget);

    await tester.enterText(find.byKey(const ValueKey('catatan-field')), 'abc');
    await tester.tap(find.text('Simpan'));
    await tester.pump();
    expect(find.text('Catatan minimal 5 karakter'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('catatan-field')),
      'Review materi praktikum',
    );
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(find.text('Review materi praktikum'), findsOneWidget);

    await tester.tap(find.text('Tulis Catatan'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Review materi praktikum'), findsOneWidget);
  });

  testWidgets('Home exposes retry for simulated repository errors', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: HomeScreen(simulateError: true)),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump();

    expect(find.text('Coba Lagi'), findsOneWidget);
    final retryButton = find.text('Coba Lagi');
    await tester.ensureVisible(retryButton);
    await tester.pump();
    await tester.tap(retryButton);
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    expect(find.text('Coba Lagi'), findsOneWidget);
  });
}

Future<void> _login(WidgetTester tester) async {
  await tester.enterText(
    find.byKey(const ValueKey('login-email')),
    'student@example.com',
  );
  await tester.enterText(
    find.byKey(const ValueKey('login-password')),
    'password123',
  );
  await tester.tap(find.widgetWithText(FilledButton, 'Login'));
  await tester.pump();
  await tester.pump(const Duration(seconds: 2));
  await tester.pump();
}
