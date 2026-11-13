# OnTimeIn

OnTimeIn is a Flutter task manager for academic assignments, courses, deadlines,
and study progress.

## Run and test

```shell
flutter pub get
flutter analyze
flutter test
flutter run
```

## Local data

Tasks and courses are stored together as JSON. Native apps use the application's
support directory; the Web app uses browser `localStorage`, scoped to the
current browser origin and not synced with native app data. The repository
loads this data when the app starts and preserves task IDs, completion status,
deadline, course, attachment path, scratchpad, and focus logs. Task photos are
stored separately in the app's private directory on native platforms; the saved
path is kept with the task.

The initial sample tasks use deadlines relative to the first app launch. Course
deletion is prevented while a task still refers to that course. Renaming a
course updates the linked tasks.

## Deadline and daily reminders

Deadline reminders are scheduled for H-3, H-1, and the deadline day at 09.00
Asia/Jakarta. Past reminder times are skipped. Completed or deleted tasks have
their deadline reminders cancelled.

The daily reminder is a single summary for incomplete tasks due today and in
the current week (Monday-Sunday). It is scheduled for each remaining day in the
current and next week, and refreshed when data is loaded or changed and when
the app resumes. On Android, notifications must be allowed in system settings.

The Home screen shows today's and this week's active tasks alongside completion
progress. The displayed progress is based on the same persisted task list used
by the task screens and reminder scheduling.

The `flutter_local_notifications` scheduling API is not supported on Web, so
native notifications are skipped in the browser. Deadline and daily reminders
remain enabled on supported native platforms.
