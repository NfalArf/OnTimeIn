import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/task.dart';
import '../utils/reminder_planner.dart';

abstract interface class TaskReminderService {
  bool get notificationsEnabled;

  Future<void> syncTaskReminders(Task task);
  Future<void> refreshDailyReminders(List<Task> tasks);
  Future<void> cancelReminders(int taskId);
}

class NotificationService implements TaskReminderService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _notificationsEnabled = true;

  @override
  bool get notificationsEnabled => _notificationsEnabled;

  Future<void> initialize() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    if (kIsWeb) {
      _notificationsEnabled = false;
      return;
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const darwinSettings = DarwinInitializationSettings();

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _plugin.initialize(settings: settings);

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    final permissionGranted = await androidPlugin
        ?.requestNotificationsPermission();
    final iosPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    final iosPermissionGranted = await iosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    _notificationsEnabled =
        (permissionGranted ?? true) && (iosPermissionGranted ?? true);
  }

  // ===================== FR-05: PENGINGAT DEADLINE TUGAS =====================

  Future<void> scheduleDeadlineReminders({
    required int taskId,
    required String taskTitle,
    required DateTime deadline,
  }) async {
    if (kIsWeb) return;

    // Hapus jadwal lama sebelum membuat jadwal baru.
    await cancelReminders(taskId);

    final now = tz.TZDateTime.now(tz.local);
    final reminderTimes = ReminderPlanner.deadlineReminderTimes(
      deadline,
      now: DateTime(now.year, now.month, now.day, now.hour, now.minute),
    );
    final reminderTypes = [
      (
        days: 3,
        title: 'Deadline 3 hari lagi!',
        body: 'Tugas "$taskTitle" harus segera disiapkan.',
      ),
      (
        days: 1,
        title: 'Deadline besok!',
        body: 'Jangan lupa menyelesaikan tugas "$taskTitle".',
      ),
      (
        days: 0,
        title: 'Deadline hari ini!',
        body: 'Hari ini batas pengumpulan tugas akademik.',
      ),
    ];

    for (final reminder in reminderTypes) {
      final reminderDate = DateTime(
        deadline.year,
        deadline.month,
        deadline.day,
      ).subtract(Duration(days: reminder.days));
      final scheduledLocal = DateTime(
        reminderDate.year,
        reminderDate.month,
        reminderDate.day,
        9,
      );
      if (!reminderTimes.contains(scheduledLocal)) continue;
      final scheduledDate = tz.TZDateTime(
        tz.local,
        scheduledLocal.year,
        scheduledLocal.month,
        scheduledLocal.day,
        scheduledLocal.hour,
      );

      await _plugin.zonedSchedule(
        id:
            taskId * 10 +
            (reminder.days == 3
                ? 1
                : reminder.days == 1
                ? 2
                : 3),
        title: reminder.title,
        body: reminder.body,
        scheduledDate: scheduledDate,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'deadline_reminders',
            'Pengingat Deadline',
            channelDescription: 'Pengingat deadline tugas akademik',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  @override
  Future<void> syncTaskReminders(Task task) async {
    if (task.isCompleted) {
      await cancelReminders(task.id);
      return;
    }
    await scheduleDeadlineReminders(
      taskId: task.id,
      taskTitle: task.title,
      deadline: task.deadline,
    );
  }

  @override
  Future<void> refreshDailyReminders(List<Task> tasks) async {
    if (kIsWeb) return;

    final now = tz.TZDateTime.now(tz.local);
    final today = DateTime(now.year, now.month, now.day);
    for (var offset = -14; offset <= 14; offset++) {
      final date = today.add(Duration(days: offset));
      await _plugin.cancel(id: _dailyReminderId(date));
    }

    final plans = ReminderPlanner.dailyPlans(
      tasks,
      now: DateTime(now.year, now.month, now.day, now.hour, now.minute),
    );
    for (final plan in plans) {
      final scheduledDate = tz.TZDateTime(
        tz.local,
        plan.date.year,
        plan.date.month,
        plan.date.day,
        9,
      );
      await _plugin.zonedSchedule(
        id: _dailyReminderId(plan.date),
        title: 'Pengingat tugas hari ini dan minggu ini',
        body:
            'Hari ini: ${plan.tasksDueToday} tugas. Minggu ini: ${plan.tasksDueThisWeek} tugas aktif. Buka OnTimeIn untuk rinciannya.',
        scheduledDate: scheduledDate,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_task_reminders',
            'Pengingat Harian Tugas',
            channelDescription: 'Ringkasan tugas aktif hari ini dan minggu ini',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  int _dailyReminderId(DateTime date) =>
      80000000 + date.year * 10000 + date.month * 100 + date.day;

  @override
  Future<void> cancelReminders(int taskId) async {
    if (kIsWeb) return;

    await _plugin.cancel(id: taskId * 10 + 1);
    await _plugin.cancel(id: taskId * 10 + 2);
    await _plugin.cancel(id: taskId * 10 + 3);
  }

  // ===================== FR-12: NOTIFIKASI KELOMPOK (MODUL 3) =====================

  /// Menjadwalkan pengingat H-1 untuk sesi kumpul kelompok.
  Future<void> scheduleGroupSessionReminder({
    required int sessionId,
    required String sessionTitle,
    required DateTime sessionDateTime,
    required String location,
  }) async {
    if (kIsWeb) return;

    await cancelGroupSessionReminder(sessionId);

    // H-1 sesi kumpul pada pukul 09.00 WIB
    final sessionDate = DateTime(
      sessionDateTime.year,
      sessionDateTime.month,
      sessionDateTime.day,
    );
    final reminderDate = sessionDate.subtract(const Duration(days: 1));

    var scheduledDate = tz.TZDateTime(
      tz.local,
      reminderDate.year,
      reminderDate.month,
      reminderDate.day,
      9,
    );

    final now = tz.TZDateTime.now(tz.local);

    // Jika H-1 pukul 09.00 sudah lewat, tetapi waktu sesi masih di masa depan:
    // jadwalkan 2 jam sebelum pertemuan dimulai
    if (!scheduledDate.isAfter(now)) {
      final sessionTZ = tz.TZDateTime(
        tz.local,
        sessionDateTime.year,
        sessionDateTime.month,
        sessionDateTime.day,
        sessionDateTime.hour,
        sessionDateTime.minute,
      );

      if (sessionTZ.isAfter(now.add(const Duration(minutes: 10)))) {
        scheduledDate = sessionTZ.subtract(const Duration(hours: 2));
        if (!scheduledDate.isAfter(now)) {
          scheduledDate = now.add(const Duration(minutes: 5));
        }
      } else {
        return;
      }
    }

    final hourStr = sessionDateTime.hour.toString().padLeft(2, '0');
    final minuteStr = sessionDateTime.minute.toString().padLeft(2, '0');

    await _plugin.zonedSchedule(
      id: 50000 + sessionId,
      title: 'Pengingat H-1 Sesi Kumpul Kelompok',
      body: 'Besok: "$sessionTitle" pukul $hourStr:$minuteStr di $location.',
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'group_reminders',
          'Pengingat Sesi Kumpul',
          channelDescription: 'Pengingat jadwal dan pertemuan kelompok',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  /// Menampilkan notifikasi instan ketika lokasi pertemuan kelompok diubah.
  Future<void> showLocationChangeNotification({
    required int sessionId,
    required String sessionTitle,
    required String oldLocation,
    required String newLocation,
  }) async {
    if (kIsWeb) return;

    await _plugin.show(
      id: 60000 + sessionId,
      title: 'Perubahan Lokasi Sesi Kumpul!',
      body:
          'Lokasi "$sessionTitle" dipindahkan dari "$oldLocation" ke "$newLocation".',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'group_location_change',
          'Perubahan Lokasi Pertemuan',
          channelDescription: 'Pemberitahuan perubahan tempat dan waktu kumpul',
          importance: Importance.max,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(''),
        ),
      ),
    );
  }

  /// Membatalkan pengingat sesi kumpul kelompok.
  Future<void> cancelGroupSessionReminder(int sessionId) async {
    if (kIsWeb) return;

    await _plugin.cancel(id: 50000 + sessionId);
  }

  /// Menampilkan notifikasi simulasi untuk demonstrasi pengingat H-1.
  Future<void> showSimulatedH1Reminder({
    required int sessionId,
    required String sessionTitle,
    required String formattedTime,
    required String location,
  }) async {
    if (kIsWeb) return;

    await _plugin.show(
      id: 70000 + sessionId,
      title: 'Pengingat H-1 Sesi Kumpul Kelompok',
      body:
          'Besok ada sesi kumpul "$sessionTitle" pukul $formattedTime di $location.',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'group_reminders',
          'Pengingat Sesi Kumpul',
          channelDescription: 'Pengingat jadwal dan pertemuan kelompok',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }
}
