import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nama_project/main.dart';

import 'support/fake_task_reminder_service.dart';
import 'support/in_memory_app_data.dart';

void main() {
  testWidgets('validates and returns a note to the task detail', (
    WidgetTester tester,
  ) async {
    final appData = InMemoryAppData.create();
    addTearDown(appData.dispose);
    await tester.pumpWidget(
      OnTimeInApp(
        dataRepository: appData.repository,
        reminderService: FakeTaskReminderService(),
      ),
    );

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'naufal@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Masuk'));
    await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView).first, const Offset(0, -700));
    await tester.pumpAndSettle();
    final taskTitle = find.text('Mobile Programming Assignment').first;
    await tester.ensureVisible(taskTitle);
    await tester.pumpAndSettle();
    await tester.tap(taskTitle);
    await tester.pumpAndSettle();
    expect(find.text('Task Detail'), findsOneWidget);

    await tester.drag(find.byType(ListView).last, const Offset(0, -700));
    await tester.pumpAndSettle();
    final noteButton = find.text('Tulis Catatan');
    await tester.ensureVisible(noteButton);
    await tester.pumpAndSettle();
    await tester.tap(noteButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simpan'));
    await tester.pump();
    expect(find.text('Catatan wajib diisi'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'abc');
    await tester.pump();
    expect(find.text('Catatan minimal 5 karakter'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'Catatan untuk tugas');
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    expect(find.text('Catatan: Catatan untuk tugas'), findsOneWidget);
    expect(find.text('Catatan berhasil disimpan'), findsOneWidget);

    await tester.tap(find.text('Tulis Catatan'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Catatan: Catatan untuk tugas'), findsOneWidget);
  });
}
