import '../models/group_session.dart';

class GroupRepository {
  GroupRepository._internal();

  static final GroupRepository instance = GroupRepository._internal();

  factory GroupRepository() => instance;

  final List<GroupSession> _sessions = [
    GroupSession(
      id: 1,
      title: 'Diskusi & Integrasi Modul OnTimeIn',
      taskId: 1,
      taskTitle: 'Mobile Programming Assignment',
      date: DateTime.now().add(const Duration(days: 1)),
      startHour: 14,
      startMinute: 0,
      endHour: 16,
      endMinute: 30,
      location: 'Perpustakaan Pusat Unand',
      sessionLocation: const SessionLocation(
        name: 'Perpustakaan Pusat Unand',
        address: 'Gedung Perpustakaan Pusat Kampus Limau Manis',
        latitude: -0.9144,
        longitude: 100.4661,
        roomOrDetails: 'Lantai 2, Ruang Diskusi Mahasiswa B',
      ),
      description:
          'Membahas penyelarasan modul kolaborasi kelompok, reminder H-1, dan persiapan presentasi proyek TB.',
      members: [
        GroupMember(
          id: 'user-ghozi',
          name: 'Muhammad Ghozi Asshidiqi',
          email: 'ghozi@student.ac.id',
          role: 'Ketua Kelompok',
          rsvpStatus: RsvpStatus.attending,
          rsvpTime: DateTime.now().subtract(const Duration(hours: 3)),
          isCurrentUser: true,
        ),
        GroupMember(
          id: 'user-naufal',
          name: 'Naufal Arif',
          email: 'naufal@student.ac.id',
          role: 'Anggota',
          rsvpStatus: RsvpStatus.attending,
          rsvpTime: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        GroupMember(
          id: 'user-gazhy',
          name: 'Gazhy Andro Alfayed',
          email: 'gazhy@student.ac.id',
          role: 'Anggota',
          rsvpStatus: RsvpStatus.attending,
          rsvpTime: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        const GroupMember(
          id: 'user-tata',
          name: 'Tata Haryadi Jayamahe',
          email: 'tata@student.ac.id',
          role: 'Anggota',
          rsvpStatus: RsvpStatus.pending,
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    GroupSession(
      id: 2,
      title: 'Finalisasi Desain Relasi ERD & Skema',
      taskId: 2,
      taskTitle: 'Database Report',
      date: DateTime.now().add(const Duration(days: 3)),
      startHour: 10,
      startMinute: 0,
      endHour: 12,
      endMinute: 0,
      location: 'Gazebo Fakultas Teknik / TI',
      sessionLocation: const SessionLocation(
        name: 'Gazebo Fakultas Teknik / TI',
        address: 'Kompleks Fakultas Teknik & Teknologi Informasi',
        latitude: -0.9152,
        longitude: 100.4670,
        roomOrDetails: 'Gazebo Barat dekat taman jurusan',
      ),
      description:
          'Finalisasi normalisasi tabel basis data untuk sistem akademik dan skema tugas kelompok.',
      members: [
        GroupMember(
          id: 'user-ghozi',
          name: 'Muhammad Ghozi Asshidiqi',
          email: 'ghozi@student.ac.id',
          role: 'Anggota',
          rsvpStatus: RsvpStatus.attending,
          isCurrentUser: true,
        ),
        const GroupMember(
          id: 'user-naufal',
          name: 'Naufal Arif',
          email: 'naufal@student.ac.id',
          role: 'Ketua Kelompok',
          rsvpStatus: RsvpStatus.attending,
        ),
        const GroupMember(
          id: 'user-gazhy',
          name: 'Gazhy Andro Alfayed',
          email: 'gazhy@student.ac.id',
          role: 'Anggota',
          rsvpStatus: RsvpStatus.tentative,
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    GroupSession(
      id: 3,
      title: 'Review Evaluasi Heuristik UI & Prototipe',
      taskId: 3,
      taskTitle: 'Read Chapter 4 and make notes',
      date: DateTime.now().subtract(const Duration(days: 1)),
      startHour: 13,
      startMinute: 30,
      endHour: 15,
      endMinute: 0,
      location: 'Lab Komputer Gedung Perkuliahan B',
      sessionLocation: const SessionLocation(
        name: 'Lab Komputer Gedung Perkuliahan B',
        address: 'Gedung Perkuliahan B Lantai 2',
        latitude: -0.9138,
        longitude: 100.4655,
        roomOrDetails: 'Lab Komputasi 204',
      ),
      description:
          'Evaluasi kegunaan antarmuka pengguna bersama perwakilan pengguna mahasiswa.',
      members: [
        GroupMember(
          id: 'user-ghozi',
          name: 'Muhammad Ghozi Asshidiqi',
          email: 'ghozi@student.ac.id',
          role: 'Anggota',
          rsvpStatus: RsvpStatus.attending,
          isCurrentUser: true,
        ),
        const GroupMember(
          id: 'user-tata',
          name: 'Tata Haryadi Jayamahe',
          email: 'tata@student.ac.id',
          role: 'Ketua Kelompok',
          rsvpStatus: RsvpStatus.attending,
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  int _nextId = 4;

  List<GroupSession> getSessions() {
    return List<GroupSession>.unmodifiable(_sessions);
  }

  GroupSession? getSessionById(int id) {
    try {
      return _sessions.firstWhere((session) => session.id == id);
    } catch (_) {
      return null;
    }
  }

  void addSession(GroupSession session) {
    final newSession = session.id <= 0
        ? session.copyWith(id: _nextId++)
        : session;
    if (newSession.id >= _nextId) {
      _nextId = newSession.id + 1;
    }
    _sessions.add(newSession);
    _sortSessions();
  }

  void updateSession(GroupSession updatedSession) {
    final index = _sessions.indexWhere((s) => s.id == updatedSession.id);
    if (index != -1) {
      _sessions[index] = updatedSession;
      _sortSessions();
    }
  }

  void deleteSession(int id) {
    _sessions.removeWhere((session) => session.id == id);
  }

  void updateMemberRsvp({
    required int sessionId,
    required String memberId,
    required RsvpStatus newStatus,
  }) {
    final index = _sessions.indexWhere((s) => s.id == sessionId);
    if (index == -1) return;

    final session = _sessions[index];
    final memberIndex = session.members.indexWhere((m) => m.id == memberId);
    if (memberIndex == -1) return;

    final updatedMembers = List<GroupMember>.from(session.members);
    updatedMembers[memberIndex] = updatedMembers[memberIndex].copyWith(
      rsvpStatus: newStatus,
      rsvpTime: DateTime.now(),
    );

    _sessions[index] = session.copyWith(members: updatedMembers);
  }

  void addMember({
    required int sessionId,
    required GroupMember member,
  }) {
    final index = _sessions.indexWhere((s) => s.id == sessionId);
    if (index == -1) return;

    final session = _sessions[index];
    if (session.members.any((m) => m.id == member.id)) return;

    final updatedMembers = List<GroupMember>.from(session.members)..add(member);
    _sessions[index] = session.copyWith(members: updatedMembers);
  }

  void removeMember({
    required int sessionId,
    required String memberId,
  }) {
    final index = _sessions.indexWhere((s) => s.id == sessionId);
    if (index == -1) return;

    final session = _sessions[index];
    final updatedMembers =
        session.members.where((m) => m.id != memberId).toList();
    _sessions[index] = session.copyWith(members: updatedMembers);
  }

  void _sortSessions() {
    _sessions.sort((a, b) => a.sessionDateTime.compareTo(b.sessionDateTime));
  }
}
