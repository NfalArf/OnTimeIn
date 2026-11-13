import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum RsvpStatus {
  attending,
  tentative,
  declined,
  pending;

  String get label {
    switch (this) {
      case RsvpStatus.attending:
        return 'Hadir';
      case RsvpStatus.tentative:
        return 'Ragu-ragu';
      case RsvpStatus.declined:
        return 'Tidak Hadir';
      case RsvpStatus.pending:
        return 'Menunggu';
    }
  }

  IconData get icon {
    switch (this) {
      case RsvpStatus.attending:
        return Icons.check_circle_rounded;
      case RsvpStatus.tentative:
        return Icons.help_outline_rounded;
      case RsvpStatus.declined:
        return Icons.cancel_outlined;
      case RsvpStatus.pending:
        return Icons.schedule_rounded;
    }
  }

  Color get color {
    switch (this) {
      case RsvpStatus.attending:
        return AppColors.success;
      case RsvpStatus.tentative:
        return AppColors.amber;
      case RsvpStatus.declined:
        return AppColors.coral;
      case RsvpStatus.pending:
        return AppColors.mutedInk;
    }
  }

  Color get softColor {
    switch (this) {
      case RsvpStatus.attending:
        return AppColors.successSoft;
      case RsvpStatus.tentative:
        return AppColors.amberSoft;
      case RsvpStatus.declined:
        return AppColors.coralSoft;
      case RsvpStatus.pending:
        return AppColors.canvas;
    }
  }
}

class GroupMember {
  const GroupMember({
    required this.id,
    required this.name,
    this.email = '',
    this.role = 'Anggota',
    this.rsvpStatus = RsvpStatus.pending,
    this.rsvpTime,
    this.isCurrentUser = false,
  });

  final String id;
  final String name;
  final String email;
  final String role;
  final RsvpStatus rsvpStatus;
  final DateTime? rsvpTime;
  final bool isCurrentUser;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  GroupMember copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    RsvpStatus? rsvpStatus,
    DateTime? rsvpTime,
    bool? isCurrentUser,
  }) {
    return GroupMember(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      rsvpStatus: rsvpStatus ?? this.rsvpStatus,
      rsvpTime: rsvpTime ?? this.rsvpTime,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
    );
  }
}

class SessionLocation {
  const SessionLocation({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.roomOrDetails = '',
  });

  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String roomOrDetails;

  String get coordinatesDisplay =>
      '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';

  String get mapsUrl =>
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

  SessionLocation copyWith({
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    String? roomOrDetails,
  }) {
    return SessionLocation(
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      roomOrDetails: roomOrDetails ?? this.roomOrDetails,
    );
  }

  static const List<SessionLocation> campusPresets = [
    SessionLocation(
      name: 'Perpustakaan Pusat Unand',
      address: 'Gedung Perpustakaan Pusat Kampus Limau Manis',
      latitude: -0.9144,
      longitude: 100.4661,
      roomOrDetails: 'Lantai 2, Ruang Diskusi Mahasiswa B',
    ),
    SessionLocation(
      name: 'Gazebo Fakultas Teknik / TI',
      address: 'Kompleks Fakultas Teknik & Teknologi Informasi',
      latitude: -0.9152,
      longitude: 100.4670,
      roomOrDetails: 'Gazebo Barat dekat taman jurusan',
    ),
    SessionLocation(
      name: 'Lab Komputer Gedung Perkuliahan B',
      address: 'Gedung Perkuliahan B Lantai 2',
      latitude: -0.9138,
      longitude: 100.4655,
      roomOrDetails: 'Lab Komputasi 204',
    ),
    SessionLocation(
      name: 'Student Center & Kantin Mahasiswa',
      address: 'Area Pusat Kegiatan Mahasiswa (PKM)',
      latitude: -0.9160,
      longitude: 100.4645,
      roomOrDetails: 'Lantai 1 meja panjang dekat pojok literasi',
    ),
    SessionLocation(
      name: 'Co-Working Space Kampus Digital',
      address: 'Gedung Inovasi & Kewirausahaan Mahasiswa',
      latitude: -0.9125,
      longitude: 100.4680,
      roomOrDetails: 'Ruang Kolaborasi Tim 3',
    ),
  ];
}

class GroupSession {
  const GroupSession({
    required this.id,
    required this.title,
    required this.taskId,
    required this.taskTitle,
    required this.date,
    required this.startHour,
    required this.startMinute,
    required this.location,
    required this.description,
    this.endHour = 0,
    this.endMinute = 0,
    this.sessionLocation,
    this.members = const [],
    this.createdAt,
  });

  final int id;
  final String title;
  final int taskId;
  final String taskTitle;
  final DateTime date;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;
  final String location;
  final SessionLocation? sessionLocation;
  final String description;
  final List<GroupMember> members;
  final DateTime? createdAt;

  String get formattedTime {
    final hour = startHour.toString().padLeft(2, '0');
    final minute = startMinute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String get formattedEndTime {
    final hourToUse = endHour > 0 ? endHour : (startHour + 2) % 24;
    final minuteToUse = endHour > 0 ? endMinute : startMinute;
    final hour = hourToUse.toString().padLeft(2, '0');
    final minute = minuteToUse.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String get timeRange => '$formattedTime - $formattedEndTime WIB';

  String get formattedDate {
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  DateTime get sessionDateTime => DateTime(
        date.year,
        date.month,
        date.day,
        startHour,
        startMinute,
      );

  bool get isUpcoming => sessionDateTime.isAfter(DateTime.now());

  int get attendingCount =>
      members.where((m) => m.rsvpStatus == RsvpStatus.attending).length;

  int get tentativeCount =>
      members.where((m) => m.rsvpStatus == RsvpStatus.tentative).length;

  int get declinedCount =>
      members.where((m) => m.rsvpStatus == RsvpStatus.declined).length;

  int get pendingCount =>
      members.where((m) => m.rsvpStatus == RsvpStatus.pending).length;

  int get totalMembers => members.length;

  GroupMember? get currentUserMember {
    for (final member in members) {
      if (member.isCurrentUser) return member;
    }
    return null;
  }

  String get shareableInvitationText {
    final locName = sessionLocation?.name.isNotEmpty == true
        ? sessionLocation!.name
        : location;
    final addressText = sessionLocation?.address.isNotEmpty == true
        ? '\nAlamat: ${sessionLocation!.address}'
        : '';
    final roomText = sessionLocation?.roomOrDetails.isNotEmpty == true
        ? '\nRuangan: ${sessionLocation!.roomOrDetails}'
        : '';
    final mapLink = sessionLocation != null
        ? '\nMaps: ${sessionLocation!.mapsUrl}'
        : '';

    final memberSummary = members.isEmpty
        ? ''
        : '\n\nAnggota (${members.length}):\n' +
            members
                .map((m) => '• ${m.name} (${m.role}) - [${m.rsvpStatus.label}]')
                .join('\n');

    return '''
📌 UNDANGAN SESI KUMPUL KELOMPOK
---------------------------------
Judul: $title
Tugas Terkait: $taskTitle
📅 Tanggal: $formattedDate
⏰ Waktu: $timeRange
📍 Lokasi: $locName$addressText$roomText$mapLink

📝 Agenda:
${description.isNotEmpty ? description : 'Membahas progress pengerjaan tugas bersama.'}$memberSummary

Silakan konfirmasi kehadiran Anda di aplikasi OnTimeIn!
---------------------------------''';
  }

  GroupSession copyWith({
    int? id,
    String? title,
    int? taskId,
    String? taskTitle,
    DateTime? date,
    int? startHour,
    int? startMinute,
    int? endHour,
    int? endMinute,
    String? location,
    SessionLocation? sessionLocation,
    String? description,
    List<GroupMember>? members,
    DateTime? createdAt,
  }) {
    return GroupSession(
      id: id ?? this.id,
      title: title ?? this.title,
      taskId: taskId ?? this.taskId,
      taskTitle: taskTitle ?? this.taskTitle,
      date: date ?? this.date,
      startHour: startHour ?? this.startHour,
      startMinute: startMinute ?? this.startMinute,
      endHour: endHour ?? this.endHour,
      endMinute: endMinute ?? this.endMinute,
      location: location ?? this.location,
      sessionLocation: sessionLocation ?? this.sessionLocation,
      description: description ?? this.description,
      members: members ?? this.members,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
