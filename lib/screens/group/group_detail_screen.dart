import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/group_repository.dart';
import '../../models/group_session.dart';
import '../../models/task.dart';
import '../../services/notification_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/campus_map_preview.dart';
import 'create_session_screen.dart';

class GroupDetailScreen extends StatefulWidget {
  const GroupDetailScreen({
    super.key,
    required this.session,
    required this.tasks,
  });

  final GroupSession session;
  final List<Task> tasks;

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  late GroupSession _session;

  @override
  void initState() {
    super.initState();
    _session = widget.session;
  }

  void _updateMyRsvp(RsvpStatus newStatus) {
    final currentMember = _session.currentUserMember;
    if (currentMember == null) return;

    GroupRepository.instance.updateMemberRsvp(
      sessionId: _session.id,
      memberId: currentMember.id,
      newStatus: newStatus,
    );

    final updated = GroupRepository.instance.getSessionById(_session.id);
    if (updated != null) {
      setState(() => _session = updated);
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Status RSVP Anda diubah menjadi "${newStatus.label}"'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _editSession() async {
    final result = await Navigator.push<GroupSession>(
      context,
      MaterialPageRoute<GroupSession>(
        builder: (_) => CreateSessionScreen(
          tasks: widget.tasks,
          existingSession: _session,
        ),
      ),
    );

    if (result != null && mounted) {
      GroupRepository.instance.updateSession(result);
      setState(() => _session = result);

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesi kumpul berhasil diperbarui!'),
        ),
      );
    }
  }

  Future<void> _deleteSession() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Hapus Sesi Kumpul?'),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${_session.title}"? '
          'Pengingat H-1 juga akan dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.coral),
            child: const Text('Hapus Sesi'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await NotificationService.instance.cancelGroupSessionReminder(_session.id);
      GroupRepository.instance.deleteSession(_session.id);
      Navigator.pop(context, true);
    }
  }

  void _shareInvitation() {
    Clipboard.setData(ClipboardData(text: _session.shareableInvitationText));

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Teks undangan pertemuan disalin ke clipboard! Siap dibagikan ke WhatsApp / grup chat.',
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showAddMemberDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    String selectedRole = 'Anggota';

    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Undang Anggota Baru'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Lengkap Mahasiswa',
                      hintText: 'Contoh: Ahmad Fauzan',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'NIM / Email',
                      hintText: 'Contoh: 2411520000',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: const InputDecoration(labelText: 'Peran'),
                    items: const [
                      DropdownMenuItem(
                        value: 'Anggota',
                        child: Text('Anggota'),
                      ),
                      DropdownMenuItem(
                        value: 'Ketua Kelompok',
                        child: Text('Ketua Kelompok'),
                      ),
                      DropdownMenuItem(
                        value: 'Notulis',
                        child: Text('Notulis'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => selectedRole = val);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text('Batal'),
                ),
                FilledButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    if (name.isEmpty) return;

                    final newMember = GroupMember(
                      id: 'user-${DateTime.now().millisecondsSinceEpoch}',
                      name: name,
                      email: emailController.text.trim(),
                      role: selectedRole,
                      rsvpStatus: RsvpStatus.pending,
                    );

                    GroupRepository.instance.addMember(
                      sessionId: _session.id,
                      member: newMember,
                    );

                    final updated =
                        GroupRepository.instance.getSessionById(_session.id);
                    if (updated != null) {
                      setState(() => _session = updated);
                    }

                    Navigator.pop(dialogCtx);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$name berhasil diundang ke kelompok!'),
                      ),
                    );
                  },
                  child: const Text('Undang'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _simulateH1Notification() async {
    await NotificationService.instance.showSimulatedH1Reminder(
      sessionId: _session.id,
      sessionTitle: _session.title,
      formattedTime: _session.timeRange,
      location: _session.sessionLocation?.name ?? _session.location,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notifikasi pengingat H-1 berhasil disimulasikan!'),
      ),
    );
  }

  Future<void> _simulateLocationChangeNotification() async {
    const oldLoc = 'Perpustakaan Lantai 1';
    final newLoc = _session.sessionLocation?.name ?? _session.location;

    await NotificationService.instance.showLocationChangeNotification(
      sessionId: _session.id,
      sessionTitle: _session.title,
      oldLocation: oldLoc,
      newLocation: newLoc,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notifikasi perubahan lokasi berhasil disimulasikan!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveLocation = _session.sessionLocation ??
        SessionLocation(
          name: _session.location,
          address: 'Area Kampus Limau Manis',
          latitude: -0.9144,
          longitude: 100.4661,
          roomOrDetails: _session.location,
        );

    final currentUser = _session.currentUserMember;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Detail Sesi Kumpul'),
        actions: [
          IconButton(
            onPressed: _shareInvitation,
            icon: const Icon(Icons.share_rounded),
            tooltip: 'Bagikan Undangan',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                _editSession();
              } else if (value == 'delete') {
                _deleteSession();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('Edit Sesi'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline,
                        size: 18, color: AppColors.coral),
                    SizedBox(width: 8),
                    Text('Hapus Sesi', style: TextStyle(color: AppColors.coral)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.page),
        children: [
          // ================= HEADER CARD (FR-09) =================
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radius),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        _session.title,
                        style: AppTextStyles.heading.copyWith(fontSize: 22),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _session.isUpcoming
                            ? AppColors.primarySoft
                            : AppColors.canvas,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _session.isUpcoming ? 'Mendatang' : 'Selesai',
                        style: TextStyle(
                          color: _session.isUpcoming
                              ? AppColors.primary
                              : AppColors.mutedInk,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    const Icon(
                      Icons.assignment_outlined,
                      size: 15,
                      color: AppColors.mutedInk,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Tugas: ${_session.taskTitle}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_month_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _session.formattedDate,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.access_time_rounded,
                      size: 16,
                      color: AppColors.coral,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _session.timeRange,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (_session.description.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.canvas,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.smallRadius),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Agenda Pertemuan:',
                            style: AppTextStyles.caption),
                        const SizedBox(height: 4),
                        Text(_session.description, style: AppTextStyles.body),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // ================= LOKASI & PETA GPS (FR-10) =================
          _buildSectionHeader('Titik Kumpul & Lokasi Maps (FR-10)'),
          const SizedBox(height: AppSpacing.sm),
          CampusMapPreview(location: effectiveLocation),

          const SizedBox(height: AppSpacing.xl),

          // ================= KONFIRMASI KEHADIRAN / RSVP (FR-11) =================
          _buildSectionHeader('Konfirmasi Kehadiran / RSVP (FR-11)'),
          const SizedBox(height: AppSpacing.sm),

          // Card Konfirmasi Saya
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radius),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.how_to_reg_rounded,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    const Text('Status Kehadiran Saya',
                        style: AppTextStyles.title),
                    const Spacer(),
                    if (currentUser != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: currentUser.rsvpStatus.softColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          currentUser.rsvpStatus.label,
                          style: TextStyle(
                            color: currentUser.rsvpStatus.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'Konfirmasikan apakah Anda akan hadir di sesi kumpul ini:',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: _buildRsvpButton(
                        label: 'Hadir',
                        icon: Icons.check_circle_outline_rounded,
                        status: RsvpStatus.attending,
                        isSelected:
                            currentUser?.rsvpStatus == RsvpStatus.attending,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _buildRsvpButton(
                        label: 'Ragu-ragu',
                        icon: Icons.help_outline_rounded,
                        status: RsvpStatus.tentative,
                        isSelected:
                            currentUser?.rsvpStatus == RsvpStatus.tentative,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _buildRsvpButton(
                        label: 'Tidak Hadir',
                        icon: Icons.cancel_outlined,
                        status: RsvpStatus.declined,
                        isSelected:
                            currentUser?.rsvpStatus == RsvpStatus.declined,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // RSVP Overview Bar & Member List
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radius),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Anggota Kelompok (${_session.totalMembers})',
                      style: AppTextStyles.title,
                    ),
                    TextButton.icon(
                      onPressed: _showAddMemberDialog,
                      icon: const Icon(Icons.person_add_rounded, size: 16),
                      label: const Text('Undang'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),

                // Visual RSVP Progress Bar
                _buildRsvpProgressBar(),
                const SizedBox(height: AppSpacing.md),

                // RSVP Badge Counter
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    _buildCountChip(
                      label: 'Hadir',
                      count: _session.attendingCount,
                      color: AppColors.success,
                      softColor: AppColors.successSoft,
                    ),
                    _buildCountChip(
                      label: 'Ragu-ragu',
                      count: _session.tentativeCount,
                      color: AppColors.amber,
                      softColor: AppColors.amberSoft,
                    ),
                    _buildCountChip(
                      label: 'Tidak Hadir',
                      count: _session.declinedCount,
                      color: AppColors.coral,
                      softColor: AppColors.coralSoft,
                    ),
                    _buildCountChip(
                      label: 'Menunggu',
                      count: _session.pendingCount,
                      color: AppColors.mutedInk,
                      softColor: AppColors.canvas,
                    ),
                  ],
                ),

                const Divider(height: 24),

                // Member Items
                ..._session.members.map((member) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: member.isCurrentUser
                              ? AppColors.primary
                              : AppColors.primarySoft,
                          child: Text(
                            member.initials,
                            style: TextStyle(
                              color: member.isCurrentUser
                                  ? Colors.white
                                  : AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      member.name,
                                      style: AppTextStyles.body.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (member.isCurrentUser) ...[
                                    const SizedBox(width: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 1,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primarySoft,
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'Anda',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              Text(
                                '${member.role} • ${member.email}',
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: member.rsvpStatus.softColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                member.rsvpStatus.icon,
                                size: 12,
                                color: member.rsvpStatus.color,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                member.rsvpStatus.label,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: member.rsvpStatus.color,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // ================= PENGINGAT & NOTIFIKASI (FR-12) =================
          _buildSectionHeader('Notifikasi & Pengingat Sesi (FR-12)'),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radius),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.notifications_active_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    const Expanded(
                      child: Text(
                        'Reminder H-1 & Perubahan Lokasi',
                        style: AppTextStyles.title,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.successSoft,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Terjadwal',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  '• Notifikasi pengingat otomatis dijadwalkan H-1 sebelum pertemuan pukul 09.00 WIB.\n'
                  '• Jika lokasi sesi diperbarui melalui form edit, sistem akan mengirimkan notifikasi perubahan lokasi ke seluruh anggota.',
                  style: AppTextStyles.caption,
                ),
                const Divider(height: 24),
                const Text(
                  'Uji / Simulasi Notifikasi Langsung:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _simulateH1Notification,
                        icon: const Icon(Icons.alarm, size: 16),
                        label: const Text('Tes Pengingat H-1'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _simulateLocationChangeNotification,
                        icon: const Icon(Icons.wrong_location_outlined,
                            size: 16),
                        label: const Text('Tes Ganti Lokasi'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.coral,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTextStyles.title.copyWith(fontSize: 16),
    );
  }

  Widget _buildRsvpButton({
    required String label,
    required IconData icon,
    required RsvpStatus status,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => _updateMyRsvp(status),
      borderRadius: BorderRadius.circular(AppSpacing.smallRadius),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? status.softColor : AppColors.canvas,
          borderRadius: BorderRadius.circular(AppSpacing.smallRadius),
          border: Border.all(
            color: isSelected ? status.color : AppColors.line,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? status.color : AppColors.mutedInk,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? status.color : AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRsvpProgressBar() {
    final total = _session.totalMembers;
    if (total == 0) return const SizedBox.shrink();

    final attendingFlex = _session.attendingCount;
    final tentativeFlex = _session.tentativeCount;
    final declinedFlex = _session.declinedCount;
    final pendingFlex = _session.pendingCount;

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        height: 10,
        child: Row(
          children: [
            if (attendingFlex > 0)
              Expanded(
                flex: attendingFlex,
                child: Container(color: AppColors.success),
              ),
            if (tentativeFlex > 0)
              Expanded(
                flex: tentativeFlex,
                child: Container(color: AppColors.amber),
              ),
            if (declinedFlex > 0)
              Expanded(
                flex: declinedFlex,
                child: Container(color: AppColors.coral),
              ),
            if (pendingFlex > 0)
              Expanded(
                flex: pendingFlex,
                child: Container(color: const Color(0xFFD4D8E0)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountChip({
    required String label,
    required int count,
    required Color color,
    required Color softColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: softColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            '$count $label',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
