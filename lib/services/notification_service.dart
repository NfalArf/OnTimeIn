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

    await androidPlugin?.requestNotificationsPermission();
  }

  // ===================== FR-05: PENGINGAT DEADLINE TUGAS =====================

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

  // ===================== FR-12: NOTIFIKASI KELOMPOK (MODUL 3) =====================

  /// Menjadwalkan pengingat H-1 untuk sesi kumpul kelompok.
  Future<void> scheduleGroupSessionReminder({
    required int sessionId,
    required String sessionTitle,
    required DateTime sessionDateTime,
    required String location,
  }) async {
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
    await _plugin.cancel(id: 50000 + sessionId);
  }

  /// Menampilkan notifikasi simulasi untuk demonstrasi pengingat H-1.
  Future<void> showSimulatedH1Reminder({
    required int sessionId,
    required String sessionTitle,
    required String formattedTime,
    required String location,
  }) async {
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
