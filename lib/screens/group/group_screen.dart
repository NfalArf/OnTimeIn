import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/group_repository.dart';
import '../../models/group_session.dart';
import '../../models/task.dart';
import '../../services/notification_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import 'create_session_screen.dart';
import 'group_detail_screen.dart';

class GroupScreen extends StatefulWidget {
  const GroupScreen({
    super.key,
    required this.tasks,
    this.repository,
  });

  final List<Task> tasks;
  final GroupRepository? repository;

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  late final GroupRepository _repository;
  int _selectedFilterIndex = 0; // 0: Semua, 1: Mendatang, 2: Selesai
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? GroupRepository.instance;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<GroupSession> _getFilteredSessions() {
    final all = _repository.getSessions();
    final now = DateTime.now();

    return all.where((session) {
      // Filter kategori
      if (_selectedFilterIndex == 1) {
        // Mendatang
        if (session.sessionDateTime.isBefore(now)) return false;
      } else if (_selectedFilterIndex == 2) {
        // Selesai
        if (session.sessionDateTime.isAfter(now)) return false;
      }

      // Filter pencarian
      if (_searchQuery.trim().isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchTitle = session.title.toLowerCase().contains(query);
        final matchTask = session.taskTitle.toLowerCase().contains(query);
        final matchLoc = session.location.toLowerCase().contains(query);
        return matchTitle || matchTask || matchLoc;
      }

      return true;
    }).toList();
  }

  Future<void> _openCreateSession() async {
    if (widget.tasks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tambahkan tugas akademik terlebih dahulu di menu Home.'),
        ),
      );
      return;
    }

    final newSession = await Navigator.push<GroupSession>(
      context,
      MaterialPageRoute<GroupSession>(
        builder: (_) => CreateSessionScreen(tasks: widget.tasks),
      ),
    );

    if (newSession != null && mounted) {
      setState(() {
        _repository.addSession(newSession);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Sesi "${newSession.title}" berhasil dibuat & pengingat H-1 aktif!',
          ),
        ),
      );
    }
  }

  Future<void> _openDetailSession(GroupSession session) async {
    final result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute<dynamic>(
        builder: (_) => GroupDetailScreen(
          session: session,
          tasks: widget.tasks,
        ),
      ),
    );

    if (mounted) {
      setState(() {});
      if (result == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sesi kumpul berhasil dihapus.')),
        );
      }
    }
  }

  Future<void> _editSession(GroupSession session) async {
    final updated = await Navigator.push<GroupSession>(
      context,
      MaterialPageRoute<GroupSession>(
        builder: (_) => CreateSessionScreen(
          tasks: widget.tasks,
          existingSession: session,
        ),
      ),
    );

    if (updated != null && mounted) {
      setState(() {
        _repository.updateSession(updated);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sesi kumpul berhasil diperbarui!')),
      );
    }
  }

  Future<void> _deleteSession(GroupSession session) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Hapus Sesi Kumpul?'),
        content: Text('Apakah Anda yakin ingin menghapus "${session.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.coral),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await NotificationService.instance.cancelGroupSessionReminder(session.id);
      setState(() {
        _repository.deleteSession(session.id);
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sesi kumpul berhasil dihapus.')),
      );
    }
  }

  void _shareSession(GroupSession session) {
    Clipboard.setData(ClipboardData(text: session.shareableInvitationText));

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Undangan disalin! Siap dikirim ke WhatsApp / grup kelompok.',
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _quickRsvp(GroupSession session, RsvpStatus status) {
    final currentMember = session.currentUserMember;
    if (currentMember == null) return;

    setState(() {
      _repository.updateMemberRsvp(
        sessionId: session.id,
        memberId: currentMember.id,
        newStatus: status,
      );
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('RSVP Anda untuk "${session.title}": ${status.label}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredSessions = _getFilteredSessions();
    final allSessions = _repository.getSessions();
    final upcomingCount = allSessions.where((s) => s.isUpcoming).length;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Pertemuan Kelompok'),
        actions: [
          IconButton(
            onPressed: _openCreateSession,
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Buat Sesi Baru',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateSession,
        backgroundColor: AppColors.ink,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Buat Sesi Kumpul'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.sm,
          AppSpacing.page,
          AppSpacing.xxl + 40,
        ),
        children: [
          // Banner Ringkasan Modul 3
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, Color(0xFF144D4B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radius),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Kolaborasi & Titik Kumpul',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Modul 3',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Koordinasi jadwal diskusi, lokasi kumpul via GPS/Maps, RSVP anggota, dan reminder H-1 otomatis.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    _buildStatPill(
                      label: 'Total Sesi',
                      value: '${allSessions.length}',
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _buildStatPill(
                      label: 'Mendatang',
                      value: '$upcomingCount',
                      highlight: true,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Search Bar
          TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: 'Cari sesi, tugas, atau lokasi kumpul...',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 12,
              ),
              fillColor: AppColors.surface,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.smallRadius),
                borderSide: const BorderSide(color: AppColors.line),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.smallRadius),
                borderSide: const BorderSide(color: AppColors.line),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Filter Segmented Chips (Semua, Mendatang, Selesai)
          Row(
            children: [
              _buildFilterChip('Semua Sesi', 0),
              const SizedBox(width: AppSpacing.sm),
              _buildFilterChip('Mendatang', 1),
              const SizedBox(width: AppSpacing.sm),
              _buildFilterChip('Selesai', 2),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Sesi List / Empty State
          if (filteredSessions.isEmpty) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radius),
                border: Border.all(color: AppColors.line),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.groups_outlined,
                    size: 56,
                    color: AppColors.mutedInk,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    _searchQuery.isNotEmpty
                        ? 'Tidak ada sesi yang cocok'
                        : 'Belum ada sesi kumpul',
                    style: AppTextStyles.title,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _searchQuery.isNotEmpty
                        ? 'Coba kata kunci pencarian yang lain.'
                        : 'Rencanakan jadwal kumpul kelompok bersama teman tugasmu!',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  FilledButton.icon(
                    onPressed: _openCreateSession,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Buat Sesi Pertama'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            ...filteredSessions.map((session) {
              return _buildSessionCard(session);
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildStatPill({
    required String label,
    required String value,
    bool highlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.amber.withOpacity(0.3)
            : Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int index) {
    final isSelected = _selectedFilterIndex == index;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primarySoft,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.ink,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      onSelected: (_) {
        setState(() => _selectedFilterIndex = index);
      },
    );
  }

  Widget _buildSessionCard(GroupSession session) {
    final currentUser = session.currentUserMember;
    final locationName = session.sessionLocation?.name ?? session.location;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openDetailSession(session),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Task chip, status badge, popup menu
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.school_outlined,
                            size: 12,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 140),
                            child: Text(
                              session.taskTitle,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: session.isUpcoming
                            ? AppColors.successSoft
                            : AppColors.canvas,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        session.isUpcoming ? 'Mendatang' : 'Selesai',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: session.isUpcoming
                              ? AppColors.success
                              : AppColors.mutedInk,
                        ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert_rounded,
                        size: 20,
                        color: AppColors.mutedInk,
                      ),
                      padding: EdgeInsets.zero,
                      onSelected: (val) {
                        if (val == 'detail') {
                          _openDetailSession(session);
                        } else if (val == 'edit') {
                          _editSession(session);
                        } else if (val == 'share') {
                          _shareSession(session);
                        } else if (val == 'delete') {
                          _deleteSession(session);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'detail',
                          child: Text('Lihat Detail & Peta'),
                        ),
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit Sesi'),
                        ),
                        const PopupMenuItem(
                          value: 'share',
                          child: Text('Bagikan Undangan'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            'Hapus',
                            style: TextStyle(color: AppColors.coral),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.sm),

                // Title
                Text(
                  session.title,
                  style: AppTextStyles.title.copyWith(fontSize: 16),
                ),

                const SizedBox(height: AppSpacing.sm),

                // Date & Time
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      session.formattedDate,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    const Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: AppColors.coral,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      session.timeRange,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Location with GPS Badge
                Row(
                  children: [
                    const Icon(
                      Icons.place_rounded,
                      size: 14,
                      color: AppColors.coral,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        locationName,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (session.sessionLocation != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.canvas,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.line),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.gps_fixed_rounded,
                              size: 10,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'GPS',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                const Divider(height: 20),

                // RSVP Section on Card
                Row(
                  children: [
                    // Member count badge
                    Row(
                      children: [
                        const Icon(
                          Icons.how_to_reg_rounded,
                          size: 15,
                          color: AppColors.mutedInk,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${session.attendingCount} Hadir'
                          '${session.pendingCount > 0 ? ' • ${session.pendingCount} Menunggu' : ''}',
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Current user RSVP Quick Selector
                    if (currentUser != null) ...[
                      Text(
                        'RSVP Saya: ',
                        style: AppTextStyles.caption.copyWith(fontSize: 11),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: currentUser.rsvpStatus.softColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: currentUser.rsvpStatus.color.withOpacity(0.3),
                          ),
                        ),
                        child: PopupMenuButton<RsvpStatus>(
                          initialValue: currentUser.rsvpStatus,
                          tooltip: 'Ubah RSVP Saya',
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                currentUser.rsvpStatus.label,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: currentUser.rsvpStatus.color,
                                ),
                              ),
                              Icon(
                                Icons.arrow_drop_down,
                                size: 16,
                                color: currentUser.rsvpStatus.color,
                              ),
                            ],
                          ),
                          onSelected: (newStatus) =>
                              _quickRsvp(session, newStatus),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: RsvpStatus.attending,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle_rounded,
                                    size: 16,
                                    color: AppColors.success,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Hadir'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: RsvpStatus.tentative,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.help_outline_rounded,
                                    size: 16,
                                    color: AppColors.amber,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Ragu-ragu'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: RsvpStatus.declined,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.cancel_outlined,
                                    size: 16,
                                    color: AppColors.coral,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Tidak Hadir'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
