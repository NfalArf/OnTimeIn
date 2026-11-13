import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nama_project/main.dart';
import 'package:nama_project/widgets/scratchpad_sketch.dart';
import 'package:nama_project/widgets/task_card.dart';

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
  testWidgets('scratchpad saved from home appears on its task card', (
    WidgetTester tester,
  ) async {
    await _signIn(tester);

    await tester.drag(find.byType(ListView).first, const Offset(0, -260));
    await tester.pumpAndSettle();
    final scratchpadButton = find.text('Scratchpad').first;
    await tester.ensureVisible(scratchpadButton);
    await tester.pumpAndSettle();
    await tester.tap(scratchpadButton);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextField).at(0),
      'Rancang struktur laporan',
    );
    await tester.enterText(
      find.byType(TextField).at(1),
      'Dokumentasi untuk memahami topik.',
    );
    await tester.enterText(
      find.byType(TextFormField).last,
      'https://example.com/referensi',
    );
    final sketchCanvas = find.byKey(const ValueKey('scratchpad-canvas'));
    await tester.ensureVisible(sketchCanvas);
    await tester.pumpAndSettle();
    expect(tester.getSize(sketchCanvas).height, 240);
    expect(tester.getSize(sketchCanvas).width, greaterThan(100));
    await tester.tap(sketchCanvas);
    await tester.pump();
    await tester.dragFrom(tester.getCenter(sketchCanvas), const Offset(70, 0));
    expect(
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, 'Hapus'))
          .onPressed,
      isNotNull,
    );
    await tester.drag(find.byType(ListView).last, const Offset(0, -400));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simpan Scratchpad'));
    await tester.pumpAndSettle();

    expect(find.text('Scratchpad berhasil disimpan'), findsOneWidget);
    expect(find.text('Rancang struktur laporan'), findsOneWidget);
    expect(find.text('Edit Scratchpad'), findsOneWidget);
    expect(find.text('Referensi'), findsOneWidget);
    expect(find.text('Tautan'), findsOneWidget);
    expect(find.byType(ScratchpadSketch), findsOneWidget);
    expect(
      tester
          .widget<TaskCard>(find.byType(TaskCard).first)
          .task
          .scratchpad!
          .strokes,
      isNotEmpty,
    );

    final deleteScratchpadButton = find.text('Hapus Scratchpad');
    await tester.ensureVisible(deleteScratchpadButton);
    await tester.pumpAndSettle();
    await tester.tap(deleteScratchpadButton);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Hapus Scratchpad'));
    await tester.pumpAndSettle();

    expect(find.text('Scratchpad berhasil dihapus'), findsOneWidget);
    expect(find.text('Rancang struktur laporan'), findsNothing);
    expect(
      tester.widget<TaskCard>(find.byType(TaskCard).first).task.scratchpad,
      isNull,
    );
  });

  testWidgets('scratchpad rejects an invalid URL and allows a valid link', (
    WidgetTester tester,
  ) async {
    await _signIn(tester);
    await tester.drag(find.byType(ListView).first, const Offset(0, -260));
    await tester.pumpAndSettle();
    final scratchpadButton = find.text('Scratchpad').first;
    await tester.ensureVisible(scratchpadButton);
    await tester.pumpAndSettle();
    await tester.tap(scratchpadButton);
    await tester.pumpAndSettle();

    final urlField = find.byType(TextFormField).last;
    await tester.enterText(urlField, 'not-a-url');
    await tester.drag(find.byType(ListView).last, const Offset(0, -600));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simpan Scratchpad'));
    await tester.pumpAndSettle();
    expect(
      find.text('Masukkan URL valid (contoh: https://contoh.com).'),
      findsOneWidget,
    );

    await tester.ensureVisible(urlField);
    await tester.enterText(urlField, 'https://example.com/path');
    await tester.drag(find.byType(ListView).last, const Offset(0, -600));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simpan Scratchpad'));
    await tester.pumpAndSettle();
    expect(find.text('Scratchpad berhasil disimpan'), findsOneWidget);
    expect(find.text('Tautan'), findsOneWidget);
  });

  testWidgets('focus timer can be opened from the Focus tab', (
    WidgetTester tester,
  ) async {
    await _signIn(tester);

    await tester.tap(find.text('Focus').last);
    await tester.pumpAndSettle();
    expect(
      find.text('Pilih tugas untuk memulai sesi Pomodoro 25 menit.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Mulai').first);
    await tester.pumpAndSettle();
    expect(find.text('Focus Timer'), findsOneWidget);
    expect(find.text('25:00'), findsOneWidget);
    expect(find.text('Mulai fokus'), findsOneWidget);

    await tester.tap(find.text('Mulai fokus'));
    await tester.pump(const Duration(seconds: 2));
    final finishButton = find.text('Selesaikan dan simpan waktu');
    await tester.ensureVisible(finishButton);
    await tester.pumpAndSettle();
    await tester.tap(finishButton);
    await tester.pumpAndSettle();

    expect(find.text('2 detik tercatat'), findsOneWidget);
  });
}
