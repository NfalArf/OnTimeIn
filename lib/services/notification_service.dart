
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  
Future<void> initialize() async {
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

  const androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const settings = InitializationSettings(
    android: androidSettings,
  );

  await _plugin.initialize(settings: settings);

  final androidPlugin = _plugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  // Meminta izin notifikasi biasa.
  await androidPlugin?.requestNotificationsPermission();

  // Memeriksa akses alarm exact.
  final canScheduleExact =
      await androidPlugin?.canScheduleExactNotifications();

  print('Izin alarm exact aktif: $canScheduleExact');

  if (canScheduleExact != true) {
    print('Akses alarm exact belum aktif. Membuka pengaturan izin.');

    await androidPlugin?.requestExactAlarmsPermission();
  }
}


  Future<void> scheduleDeadlineReminders({
    required int taskId,
    required String taskTitle,
    required DateTime deadline,
  }) async {
    // Hapus jadwal lama sebelum membuat jadwal baru.
    await cancelReminders(taskId);

    final deadlineDate = DateTime(
      deadline.year,
      deadline.month,
      deadline.day,
    );

    final reminders = [
      {
        'days': 3,
        'id': taskId * 10 + 1,
        'title': 'Deadline 3 hari lagi!',
        'body': 'Tugas "$taskTitle" harus segera disiapkan.',
      },
      {
        'days': 1,
        'id': taskId * 10 + 2,
        'title': 'Deadline besok!',
        'body': 'Jangan lupa menyelesaikan tugas "$taskTitle".',
      },
      {
        'days': 0,
        'id': taskId * 10 + 3,
        'title': 'Deadline hari ini!',
        'body': 'Hari ini batas pengumpulan tugas "$taskTitle".',
      },
    ];

    for (final reminder in reminders) {
      final reminderDate = deadlineDate.subtract(
        Duration(days: reminder['days'] as int),
      );

      // Notifikasi dijadwalkan pukul 09.00 WIB.
      final scheduledDate = tz.TZDateTime(
        tz.local,
        reminderDate.year,
        reminderDate.month,
        reminderDate.day,
        9,
      );

      if (!scheduledDate.isAfter(tz.TZDateTime.now(tz.local))) {
        continue;
      }

      await _plugin.zonedSchedule(
        id: reminder['id'] as int,
        title: reminder['title'] as String,
        body: reminder['body'] as String,
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

  Future<void> cancelReminders(int taskId) async {
    await _plugin.cancel(id: taskId * 10 + 1);
    await _plugin.cancel(id: taskId * 10 + 2);
    await _plugin.cancel(id: taskId * 10 + 3);
  }
}
