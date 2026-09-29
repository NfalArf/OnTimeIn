import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nama_project/main.dart';

void main() {
  testWidgets('validates and returns a note to the task detail', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const OnTimeInApp());

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'naufal@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mobile Programming Assignment').first);
    await tester.pumpAndSettle();
    expect(find.text('Task Detail'), findsOneWidget);

    await tester.tap(find.text('Tulis Catatan'));
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
