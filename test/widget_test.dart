import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nama_project/data/task_repository.dart';
import 'package:nama_project/main.dart';
import 'package:nama_project/routes/app_routes.dart';
import 'package:nama_project/screens/home_screen.dart';

void main() {
  testWidgets('validates login fields', (WidgetTester tester) async {
    await tester.pumpWidget(const OnTimeInApp());

    await tester.tap(find.text('Login'));
    await tester.pump();

    expect(find.text('Email wajib diisi'), findsOneWidget);
    expect(find.text('Password wajib diisi'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('login-email')),
      'bad-email',
    );
    await tester.enterText(
      find.byKey(const ValueKey('login-password')),
      'short',
    );
    await tester.tap(find.text('Login'));
    await tester.pump();

    expect(find.text('Format email tidak valid'), findsOneWidget);
    expect(find.text('Password minimal 8 karakter'), findsOneWidget);
  });

  testWidgets('opens Home after valid login and renders existing UI', (
    WidgetTester tester,
  ) async {
    await _loginAndOpenHome(tester);

    expect(find.text('Good Morning, Naufal'), findsOneWidget);
    expect(find.text('Your task overview'), findsOneWidget);
    expect(find.text('Mobile Programming Assignment'), findsOneWidget);
    expect(find.text('Add Task'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('can mark an upcoming task as completed', (
    WidgetTester tester,
  ) async {
    await _loginAndOpenHome(tester);

    final taskCheckbox = find.byType(Checkbox).first;
    await tester.tap(taskCheckbox);
    await tester.pump();

    expect(tester.widget<Checkbox>(taskCheckbox).value, isTrue);
  });

  testWidgets('opens task detail and saves a note', (
    WidgetTester tester,
  ) async {
    await _loginAndOpenHome(tester);
    await tester.tap(find.text('Mobile Programming Assignment'));
    await tester.pumpAndSettle();

    expect(find.text('Pemrograman Mobile'), findsOneWidget);
    expect(find.text('Tomorrow, 23:59'), findsOneWidget);

    await tester.tap(find.text('Tulis Catatan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simpan'));
    await tester.pump();
    expect(find.text('Catatan wajib diisi'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'Catatan tugas');
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(find.text('Catatan tugas'), findsOneWidget);
  });

  testWidgets('shows empty state when repository has no tasks', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(repository: TaskRepository(tasks: [])),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Belum ada task.'), findsOneWidget);
  });

  testWidgets('shows retry action when task loading fails', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: HomeScreen(simulateError: true)),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Gagal memuat data. Periksa koneksi internet.'),
      findsOneWidget,
    );
    expect(find.text('Coba Lagi'), findsOneWidget);
  });

  testWidgets('routes invalid details and unknown names to not found', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const OnTimeInApp());
    final navigator = tester.state<NavigatorState>(
      find.byType(Navigator).first,
    );

    navigator.pushNamed(AppRoutes.detail);
    await tester.pumpAndSettle();
    expect(find.text('Data task tidak valid.'), findsOneWidget);

    navigator.pop();
    await tester.pumpAndSettle();
    navigator.pushNamed('/unknown-route');
    await tester.pumpAndSettle();

    expect(
      find.text('Halaman tidak ditemukan: /unknown-route'),
      findsOneWidget,
    );
  });
}

Future<void> _loginAndOpenHome(WidgetTester tester) async {
  await tester.pumpWidget(const OnTimeInApp());
  await tester.enterText(
    find.byKey(const ValueKey('login-email')),
    'user@example.com',
  );
  await tester.enterText(
    find.byKey(const ValueKey('login-password')),
    'password123',
  );
  await tester.tap(find.text('Login'));
  await tester.pumpAndSettle();
}
