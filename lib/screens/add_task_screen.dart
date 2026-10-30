import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../services/task_attachment_service.dart';
import '../models/task.dart';
import '../utils/validators.dart';
import '../widgets/task_attachment_image.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({
    super.key,
    this.initialTask,
    this.courseNames = const [],
  });

  final Task? initialTask;
  final List<String> courseNames;

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  String? _course;
  DateTime? _deadline;
  XFile? _pendingPhoto;
  bool _removePhoto = false;

  bool get _isEditing => widget.initialTask != null;

  @override
  void initState() {
    super.initState();

    final task = widget.initialTask;

    if (task != null) {
      _titleController.text = task.title;
      _course = task.course;
      _deadline = task.deadline;
    } else if (widget.courseNames.isNotEmpty) {
      _course = widget.courseNames.first;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _selectDeadline() async {
    final now = DateTime.now();

    final selected = await showDatePicker(
      context: context,
      initialDate: _deadline ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 5),
    );

    if (selected != null && mounted) {
      setState(() {
        _deadline = DateTime(
          selected.year,
          selected.month,
          selected.day,
          23,
          59,
        );
      });
    }
  }

  Future<void> _capturePhoto() async {
    try {
      final photo = await TaskAttachmentService.capturePhoto();
      if (!mounted || photo == null) return;
      setState(() {
        _pendingPhoto = photo;
        _removePhoto = false;
      });
    } on PlatformException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.code == 'camera_access_denied'
                ? 'Izin kamera ditolak. Aktifkan izin kamera di pengaturan.'
                : 'Kamera tidak dapat diakses: ${error.message ?? error.code}',
          ),
        ),
      );
    } on Exception catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengambil foto: $error')));
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    if (_deadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih deadline terlebih dahulu.'),
        ),
      );
      return;
    }

    String? attachmentPath = widget.initialTask?.attachmentPath;
    try {
      if (_pendingPhoto case final photo?) {
        attachmentPath = await TaskAttachmentService.savePhoto(photo);
      } else if (_removePhoto) {
        attachmentPath = null;
      }
    } on Exception catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan foto: $error')));
      }
      return;
    }

    final task =
        (widget.initialTask ??
                Task(
                  title: _titleController.text.trim(),
                  course: _course!,
                  deadline: _deadline!,
                  priority: TaskPriority.normal,
                ))
            .copyWith(
              title: _titleController.text.trim(),
              course: _course!,
              deadline: _deadline!,
              attachmentPath: attachmentPath,
              clearAttachment: attachmentPath == null,
            );

    if (!mounted) return;
    Navigator.pop(context, task);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Task' : 'Tambah Task')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Nama tugas',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  Validators.minLength(value, 3, fieldName: 'Nama tugas'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _course,
              decoration: const InputDecoration(
                labelText: 'Mata kuliah',
                border: OutlineInputBorder(),
              ),
              items:
                  {
                    ...widget.courseNames,
                    if (widget.initialTask case final task?) task.course,
                  }.map((name) {
                    return DropdownMenuItem<String>(
                      value: name,
                      child: Text(name),
                    );
                  }).toList(),
              validator: (value) =>
                  Validators.required(value, fieldName: 'Mata kuliah'),
              onChanged: (value) => setState(() => _course = value),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _selectDeadline,
              icon: const Icon(Icons.calendar_month),
              label: Text(
                _deadline == null
                    ? 'Pilih deadline'
                    : '${_deadline!.day.toString().padLeft(2, '0')}/'
                          '${_deadline!.month.toString().padLeft(2, '0')}/'
                          '${_deadline!.year}',
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _capturePhoto,
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text('Ambil foto soal'),
            ),
            if (_pendingPhoto != null ||
                (!_removePhoto && widget.initialTask?.attachmentPath != null))
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: TaskAttachmentImage(
                        photo: _pendingPhoto,
                        location: widget.initialTask?.attachmentPath,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            const Text('Foto lampiran tidak dapat dibuka.'),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => setState(() {
                        _pendingPhoto = null;
                        _removePhoto = true;
                      }),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Hapus foto'),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _saveTask,
              icon: Icon(_isEditing ? Icons.save_as_outlined : Icons.save),
              label: Text(_isEditing ? 'Simpan Perubahan' : 'Simpan Task'),
            ),
          ],
        ),
      ),
    );
  }
}
