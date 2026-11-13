import 'package:flutter/material.dart';

import '../../models/group_session.dart';
import '../../models/task.dart';
import '../../services/notification_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

class CreateSessionScreen extends StatefulWidget {
  const CreateSessionScreen({
    super.key,
    required this.tasks,
    this.existingSession,
  });

  final List<Task> tasks;
  final GroupSession? existingSession;

  bool get isEditing => existingSession != null;

  @override
  State<CreateSessionScreen> createState() => _CreateSessionScreenState();
}

class _CreateSessionScreenState extends State<CreateSessionScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _locationNameController;
  late TextEditingController _addressController;
  late TextEditingController _roomDetailsController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;
  late TextEditingController _descriptionController;

  Task? _selectedTask;
  late DateTime _selectedDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late List<GroupMember> _members;
  bool _isGettingGps = false;

  @override
  void initState() {
    super.initState();

    final session = widget.existingSession;
    if (session != null) {
      _titleController = TextEditingController(text: session.title);
      _locationNameController = TextEditingController(
        text: session.sessionLocation?.name ?? session.location,
      );
      _addressController = TextEditingController(
        text: session.sessionLocation?.address ?? '',
      );
      _roomDetailsController = TextEditingController(
        text: session.sessionLocation?.roomOrDetails ?? '',
      );
      _latitudeController = TextEditingController(
        text: (session.sessionLocation?.latitude ?? -0.9144).toString(),
      );
      _longitudeController = TextEditingController(
        text: (session.sessionLocation?.longitude ?? 100.4661).toString(),
      );
      _descriptionController =
          TextEditingController(text: session.description);

      _selectedDate = session.date;
      _startTime =
          TimeOfDay(hour: session.startHour, minute: session.startMinute);
      _endTime = TimeOfDay(
        hour: session.endHour > 0 ? session.endHour : (session.startHour + 2) % 24,
        minute: session.endMinute > 0 ? session.endMinute : session.startMinute,
      );
      _members = List<GroupMember>.from(session.members);

      if (widget.tasks.isNotEmpty) {
        _selectedTask = widget.tasks.firstWhere(
          (t) => t.id == session.taskId,
          orElse: () => widget.tasks.first,
        );
      }
    } else {
      _titleController = TextEditingController();
      _locationNameController =
          TextEditingController(text: 'Perpustakaan Pusat Unand');
      _addressController = TextEditingController(
        text: 'Gedung Perpustakaan Pusat Kampus Limau Manis',
      );
      _roomDetailsController = TextEditingController(
        text: 'Lantai 2, Ruang Diskusi Mahasiswa B',
      );
      _latitudeController = TextEditingController(text: '-0.9144');
      _longitudeController = TextEditingController(text: '100.4661');
      _descriptionController = TextEditingController();

      _selectedDate = DateTime.now().add(const Duration(days: 1));
      _startTime = const TimeOfDay(hour: 14, minute: 0);
      _endTime = const TimeOfDay(hour: 16, minute: 0);

      _members = [
        GroupMember(
          id: 'user-ghozi',
          name: 'Muhammad Ghozi Asshidiqi',
          email: 'ghozi@student.ac.id',
          role: 'Ketua Kelompok',
          rsvpStatus: RsvpStatus.attending,
          rsvpTime: DateTime.now(),
          isCurrentUser: true,
        ),
        const GroupMember(
          id: 'user-naufal',
          name: 'Naufal Arif',
          email: 'naufal@student.ac.id',
          role: 'Anggota',
          rsvpStatus: RsvpStatus.attending,
        ),
        const GroupMember(
          id: 'user-gazhy',
          name: 'Gazhy Andro Alfayed',
          email: 'gazhy@student.ac.id',
          role: 'Anggota',
          rsvpStatus: RsvpStatus.pending,
        ),
        const GroupMember(
          id: 'user-tata',
          name: 'Tata Haryadi Jayamahe',
          email: 'tata@student.ac.id',
          role: 'Anggota',
          rsvpStatus: RsvpStatus.pending,
        ),
      ];

      if (widget.tasks.isNotEmpty) {
        _selectedTask = widget.tasks.first;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationNameController.dispose();
    _addressController.dispose();
    _roomDetailsController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _applyPresetLocation(SessionLocation preset) {
    setState(() {
      _locationNameController.text = preset.name;
      _addressController.text = preset.address;
      _roomDetailsController.text = preset.roomOrDetails;
      _latitudeController.text = preset.latitude.toString();
      _longitudeController.text = preset.longitude.toString();
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Lokasi dipilih: ${preset.name}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _getCurrentGpsLocation() async {
    setState(() => _isGettingGps = true);
    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    // Koordinat simulasi GPS kampus (Universitas Andalas)
    setState(() {
      _latitudeController.text = '-0.9144';
      _longitudeController.text = '100.4661';
      _addressController.text = 'Kampus Limau Manis, Padang (Sinyal GPS Akurat)';
      _isGettingGps = false;
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Titik GPS berhasil diperbarui via sensor perangkat!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null) {
      setState(() => _startTime = picked);
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (picked != null) {
      setState(() => _endTime = picked);
    }
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
              title: const Text('Undang Anggota Kelompok'),
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
                      hintText: 'Contoh: 2411520000 / email@student.ac.id',
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

                    setState(() {
                      _members.add(newMember);
                    });

                    Navigator.pop(dialogCtx);
                  },
                  child: const Text('Tambah'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _removeMember(int index) {
    setState(() {
      _members.removeAt(index);
    });
  }

  Future<void> _saveSession() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedTask == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tugas akademik terkait')),
      );
      return;
    }

    final lat = double.tryParse(_latitudeController.text.trim()) ?? -0.9144;
    final lng = double.tryParse(_longitudeController.text.trim()) ?? 100.4661;

    final sessionLocation = SessionLocation(
      name: _locationNameController.text.trim(),
      address: _addressController.text.trim(),
      latitude: lat,
      longitude: lng,
      roomOrDetails: _roomDetailsController.text.trim(),
    );

    final sessionId = widget.existingSession?.id ?? 0;
    final title = _titleController.text.trim();
    final newLocationName = sessionLocation.name;

    final session = GroupSession(
      id: sessionId,
      title: title,
      taskId: _selectedTask!.id,
      taskTitle: _selectedTask!.title,
      date: DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
      ),
      startHour: _startTime.hour,
      startMinute: _startTime.minute,
      endHour: _endTime.hour,
      endMinute: _endTime.minute,
      location: newLocationName,
      sessionLocation: sessionLocation,
      description: _descriptionController.text.trim(),
      members: _members,
      createdAt: widget.existingSession?.createdAt ?? DateTime.now(),
    );

    // ================= FR-12: NOTIFIKASI REMINDER & PERUBAHAN =================
    // 1. Cek apakah ini mode edit dan lokasi berubah
    if (widget.isEditing) {
      final oldLocation = widget.existingSession!.sessionLocation?.name ??
          widget.existingSession!.location;

      if (oldLocation.trim().toLowerCase() !=
          newLocationName.trim().toLowerCase()) {
        // Memicu notifikasi perubahan lokasi (FR-12)
        await NotificationService.instance.showLocationChangeNotification(
          sessionId: session.id,
          sessionTitle: session.title,
          oldLocation: oldLocation,
          newLocation: newLocationName,
        );
      }
    }

    // 2. Jadwalkan Reminder H-1 (FR-12)
    await NotificationService.instance.scheduleGroupSessionReminder(
      sessionId: session.id,
      sessionTitle: session.title,
      sessionDateTime: session.sessionDateTime,
      location: newLocationName,
    );

    if (!mounted) return;
    Navigator.pop(context, session);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Sesi Kumpul' : 'Buat Sesi Kumpul'),
        actions: [
          TextButton.icon(
            onPressed: _saveSession,
            icon: const Icon(Icons.check_rounded, color: AppColors.primary),
            label: const Text(
              'Simpan',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.page),
          children: [
            // ================= DETAIL UTAMA SESI (FR-09) =================
            _buildSectionCard(
              title: 'Informasi Sesi Pertemuan',
              icon: Icons.event_note_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Nama / Topik Sesi',
                      hintText: 'Contoh: Diskusi Perancangan Arsitektur TB',
                      prefixIcon: Icon(Icons.title_rounded),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Nama sesi wajib diisi';
                      }
                      if (val.trim().length < 3) {
                        return 'Nama sesi minimal 3 karakter';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  DropdownButtonFormField<Task>(
                    value: _selectedTask,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Tugas Terkait',
                      prefixIcon: Icon(Icons.assignment_outlined),
                    ),
                    items: widget.tasks.map((task) {
                      return DropdownMenuItem<Task>(
                        value: task,
                        child: Text(
                          task.title,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (task) {
                      if (task != null) {
                        setState(() => _selectedTask = task);
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Date Picker Row
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(AppSpacing.smallRadius),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.canvas,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.smallRadius),
                        border: Border.all(color: AppColors.line),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_month_rounded,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Tanggal Pertemuan',
                                  style: AppTextStyles.caption),
                              Text(
                                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                style: AppTextStyles.body.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          const Icon(Icons.arrow_drop_down,
                              color: AppColors.mutedInk),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Time Picker Row
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: _pickStartTime,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.smallRadius),
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: AppColors.canvas,
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.smallRadius),
                              border: Border.all(color: AppColors.line),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Jam Mulai',
                                    style: AppTextStyles.caption),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time_rounded,
                                        size: 16, color: AppColors.primary),
                                    const SizedBox(width: 6),
                                    Text(
                                      _startTime.format(context),
                                      style: AppTextStyles.body.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: InkWell(
                          onTap: _pickEndTime,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.smallRadius),
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: AppColors.canvas,
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.smallRadius),
                              border: Border.all(color: AppColors.line),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Jam Selesai',
                                    style: AppTextStyles.caption),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Icon(Icons.timer_off_outlined,
                                        size: 16, color: AppColors.coral),
                                    const SizedBox(width: 6),
                                    Text(
                                      _endTime.format(context),
                                      style: AppTextStyles.body.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Agenda / Catatan Pembahasan',
                      hintText:
                          'Tuliskan hal-hal yang perlu disiapkan atau dibahas...',
                      alignLabelWithHint: true,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // ================= TITIK KUMPUL & GPS / MAPS (FR-10) =================
            _buildSectionCard(
              title: 'Lokasi Titik Kumpul & Maps (FR-10)',
              icon: Icons.location_on_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pilihan Titik Kumpul Kampus Populer:',
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: SessionLocation.campusPresets.map((preset) {
                        final isSelected =
                            _locationNameController.text.trim() == preset.name;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(preset.name),
                            selected: isSelected,
                            selectedColor: AppColors.primarySoft,
                            checkmarkColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.ink,
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            onSelected: (_) => _applyPresetLocation(preset),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Button Deteksi GPS Perangkat
                  OutlinedButton.icon(
                    onPressed: _isGettingGps ? null : _getCurrentGpsLocation,
                    icon: _isGettingGps
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location_rounded),
                    label: Text(
                      _isGettingGps
                          ? 'Mendeteksi Titik GPS...'
                          : 'Gunakan Titik GPS Kampus Saat Ini',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      minimumSize: const Size.fromHeight(42),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  TextFormField(
                    controller: _locationNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Tempat / Gedung',
                      hintText: 'Contoh: Perpustakaan Pusat Unand',
                      prefixIcon: Icon(Icons.place_outlined),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Nama lokasi wajib diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Alamat Lengkap / Kompleks',
                      hintText: 'Contoh: Kampus Limau Manis, Gedung Utama',
                      prefixIcon: Icon(Icons.map_outlined),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _roomDetailsController,
                    decoration: const InputDecoration(
                      labelText: 'Detail Ruangan / Meja Kumpul',
                      hintText: 'Contoh: Lantai 2, Ruang Diskusi B',
                      prefixIcon: Icon(Icons.meeting_room_outlined),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _latitudeController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Latitude GPS',
                            hintText: '-0.9144',
                            prefixIcon: Icon(Icons.north_rounded, size: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: TextFormField(
                          controller: _longitudeController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Longitude GPS',
                            hintText: '100.4661',
                            prefixIcon: Icon(Icons.east_rounded, size: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // ================= UNDANGAN & ANGGOTA (FR-11) =================
            _buildSectionCard(
              title: 'Anggota Kelompok & Undangan (FR-11)',
              icon: Icons.groups_rounded,
              action: TextButton.icon(
                onPressed: _showAddMemberDialog,
                icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
                label: const Text('Undang'),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_members.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'Belum ada anggota yang diundang. Klik tombol "Undang" untuk menambahkan.',
                        style: AppTextStyles.caption,
                      ),
                    )
                  else
                    ..._members.asMap().entries.map((entry) {
                      final index = entry.key;
                      final member = entry.value;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.canvas,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.smallRadius),
                          border: Border.all(color: AppColors.line),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: AppColors.primarySoft,
                              child: Text(
                                member.initials,
                                style: const TextStyle(
                                  color: AppColors.primary,
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
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.primarySoft,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: const Text(
                                            'Anda',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.bold,
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
                              child: Text(
                                member.rsvpStatus.label,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: member.rsvpStatus.color,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (!member.isCurrentUser)
                              IconButton(
                                icon: const Icon(
                                  Icons.close_rounded,
                                  size: 16,
                                  color: AppColors.mutedInk,
                                ),
                                onPressed: () => _removeMember(index),
                              ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Tombol Simpan
            FilledButton.icon(
              onPressed: _saveSession,
              icon: const Icon(Icons.check_circle_rounded),
              label: Text(
                widget.isEditing
                    ? 'Perbarui Sesi Kumpul'
                    : 'Simpan & Jadwalkan Sesi Kumpul',
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.ink,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.smallRadius),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
    Widget? action,
  }) {
    return Container(
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
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(title, style: AppTextStyles.title)),
              if (action != null) action,
            ],
          ),
          const Divider(height: 24),
          child,
        ],
      ),
    );
  }
}
