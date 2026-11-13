import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nama_project/models/course.dart';
import 'package:nama_project/main.dart';
import 'package:nama_project/models/task.dart';
import 'package:nama_project/widgets/task_card.dart';

import 'support/fake_task_reminder_service.dart';
import 'support/in_memory_app_data.dart';

Future<InMemoryAppData> _signIn(WidgetTester tester) async {
  final appData = InMemoryAppData.create();
  await tester.pumpWidget(
    OnTimeInApp(
      dataRepository: appData.repository,
      reminderService: FakeTaskReminderService(),
    ),
  );
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
  return appData;
}

void main() {
  testWidgets('renders the OnTimeIn home screen', (WidgetTester tester) async {
    final appData = await _signIn(tester);
    addTearDown(appData.dispose);

    expect(find.text('Good Morning, Sir'), findsOneWidget);
    expect(find.text("Let's get your tasks done."), findsOneWidget);
    expect(find.text('Add Task'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    await tester.drag(find.byType(ListView).first, const Offset(0, -700));
    await tester.pumpAndSettle();
    final taskTitle = find.text('Mobile Programming Assignment').first;
    await tester.ensureVisible(taskTitle);
    await tester.pumpAndSettle();
    expect(find.text('Mobile Programming Assignment'), findsOneWidget);
  });

  testWidgets('can mark an upcoming task as completed', (
    WidgetTester tester,
  ) async {
    final appData = await _signIn(tester);
    addTearDown(appData.dispose);

    await tester.drag(find.byType(ListView).first, const Offset(0, -700));
    await tester.pumpAndSettle();
    final taskCard = tester
        .widgetList<TaskCard>(find.byType(TaskCard))
        .firstWhere(
          (card) => card.task.title == 'Mobile Programming Assignment',
        );
    final taskCheckbox = find.descendant(
      of: find.byWidget(taskCard),
      matching: find.byType(Checkbox),
    );
    await tester.ensureVisible(taskCheckbox);
    await tester.pumpAndSettle();
    await tester.tap(taskCheckbox);
    await tester.pumpAndSettle();

    final updatedTask = tester
        .widgetList<TaskCard>(find.byType(TaskCard))
        .firstWhere(
          (card) => card.task.title == 'Mobile Programming Assignment',
        )
        .task;
    expect(updatedTask.isCompleted, isTrue);
  });

  testWidgets('completion updates the daily summary', (
    WidgetTester tester,
  ) async {
    final now = DateTime.now();
    final appData = InMemoryAppData.create(
      initialTasks: [
        Task(
          id: 12,
          title: 'Tugas hari ini',
          course: 'Basis Data',
          deadline: DateTime(now.year, now.month, now.day, 23, 59),
          priority: TaskPriority.high,
        ),
      ],
      initialCourses: const [Course(id: 'db', name: 'Basis Data', semester: 5)],
    );
    addTearDown(appData.dispose);
    final reminders = FakeTaskReminderService();
    await tester.pumpWidget(
      OnTimeInApp(
        dataRepository: appData.repository,
        reminderService: reminders,
      ),
    );
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

    await tester.drag(find.byType(ListView).first, const Offset(0, -350));
    await tester.pumpAndSettle();
    expect(find.text('Hari ini · 1'), findsOneWidget);
    expect(find.text('• Tugas hari ini — Basis Data'), findsOneWidget);
    await tester.drag(find.byType(ListView).first, const Offset(0, -500));
    await tester.pumpAndSettle();
    final card = tester
        .widgetList<TaskCard>(find.byType(TaskCard))
        .singleWhere((item) => item.task.id == 12);
    final checkbox = find.descendant(
      of: find.byWidget(card),
      matching: find.byType(Checkbox),
    );
    await tester.ensureVisible(checkbox);
    await tester.pumpAndSettle();
    await tester.tap(checkbox);
    await tester.pumpAndSettle();

    expect((await appData.repository.fetchTasks()).single.isCompleted, isTrue);
    expect(reminders.cancelledTaskIds, contains(12));
    expect(find.text('Hari ini · 0'), findsOneWidget);
    expect(find.text('Tidak ada tugas aktif hari ini.'), findsOneWidget);
  });
}
