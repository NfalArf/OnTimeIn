import 'package:flutter_test/flutter_test.dart';
import 'package:nama_project/data/group_repository.dart';
import 'package:nama_project/models/group_session.dart';

void main() {
  group('Modul 3 - Kolaborasi dan Pertemuan Kelompok Unit Tests', () {
    late GroupRepository repository;

    setUp(() {
      repository = GroupRepository.instance;
    });

    test('FR-09: Dapat membuat sesi kumpul dan menghitung waktu pertemuan', () {
      final initialCount = repository.getSessions().length;

      final newSession = GroupSession(
        id: 99,
        title: 'Diskusi Modul Kolaborasi Flutter',
        taskId: 1,
        taskTitle: 'Mobile Programming Assignment',
        date: DateTime(2026, 11, 20),
        startHour: 13,
        startMinute: 30,
        endHour: 15,
        endMinute: 30,
        location: 'Perpustakaan Pusat Unand',
        description: 'Membahas pembagian tugas FR-09 sampai FR-12',
      );

      repository.addSession(newSession);

      expect(repository.getSessions().length, initialCount + 1);
      final saved = repository.getSessionById(99);
      expect(saved, isNotNull);
      expect(saved!.title, 'Diskusi Modul Kolaborasi Flutter');
      expect(saved.formattedTime, '13:30');
      expect(saved.formattedEndTime, '15:30');
      expect(saved.timeRange, '13:30 - 15:30 WIB');
    });

    test('FR-10: Lokasi memiliki preset kampus, koordinat GPS, dan URL Maps', () {
      expect(SessionLocation.campusPresets.isNotEmpty, isTrue);

      final perpus = SessionLocation.campusPresets.first;
      expect(perpus.name, 'Perpustakaan Pusat Unand');
      expect(perpus.latitude, -0.9144);
      expect(perpus.longitude, 100.4661);
      expect(perpus.coordinatesDisplay, '-0.9144, 100.4661');
      expect(
        perpus.mapsUrl,
        'https://www.google.com/maps/search/?api=1&query=-0.9144,100.4661',
      );
    });

    test('FR-11: Mengundang anggota dan mengelola RSVP konfirmasi kehadiran', () {
      final session = repository.getSessionById(1);
      expect(session, isNotNull);

      final initialMembersCount = session!.totalMembers;

      // 1. Tambah anggota baru
      final newMember = GroupMember(
        id: 'user-test-${DateTime.now().millisecondsSinceEpoch}',
        name: 'Mahasiswa Baru',
        email: 'baru@student.ac.id',
        role: 'Anggota',
        rsvpStatus: RsvpStatus.pending,
      );

      repository.addMember(sessionId: session.id, member: newMember);
      var updated = repository.getSessionById(session.id);
      expect(updated!.totalMembers, initialMembersCount + 1);

      // 2. Ubah status RSVP anggota
      repository.updateMemberRsvp(
        sessionId: session.id,
        memberId: newMember.id,
        newStatus: RsvpStatus.attending,
      );

      updated = repository.getSessionById(session.id);
      final memberInSession =
          updated!.members.firstWhere((m) => m.id == newMember.id);
      expect(memberInSession.rsvpStatus, RsvpStatus.attending);
      expect(updated.attendingCount, greaterThan(0));

      // 3. Format teks share undangan
      final invitation = updated.shareableInvitationText;
      expect(invitation.contains('UNDANGAN SESI KUMPUL KELOMPOK'), isTrue);
      expect(invitation.contains(updated.title), isTrue);
      expect(invitation.contains(updated.timeRange), isTrue);
    });

    test('FR-12: Deteksi perubahan lokasi untuk notifikasi pemindahan tempat', () {
      final session = repository.getSessionById(1);
      expect(session, isNotNull);

      const oldLoc = 'Perpustakaan Pusat Unand';
      const newLoc = 'Gazebo Fakultas Teknik';

      // Pastikan lokasi lama berbeda dengan baru
      expect(oldLoc != newLoc, isTrue);

      final updatedSession = session!.copyWith(
        location: newLoc,
        sessionLocation: const SessionLocation(
          name: newLoc,
          address: 'Kampus Limau Manis',
          latitude: -0.9152,
          longitude: 100.4670,
        ),
      );

      repository.updateSession(updatedSession);

      final retrieved = repository.getSessionById(session.id);
      expect(retrieved!.location, newLoc);
      expect(retrieved.sessionLocation?.name, newLoc);
    });
  });
}
