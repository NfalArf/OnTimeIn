
import 'package:flutter/material.dart';

import '../models/task.dart';
import '../utils/validators.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({
    super.key,
    this.initialTask,
  });

  final Task? initialTask;

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _courseController = TextEditingController();

  DateTime? _deadline;
  TaskPriority _priority = TaskPriority.normal;

  bool get _isEditing => widget.initialTask != null;

  @override
  void initState() {
    super.initState();

    final task = widget.initialTask;

    if (task != null) {
      _titleController.text = task.title;
      _courseController.text = task.course;
      _deadline = task.deadline;
      _priority = task.priority;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _courseController.dispose();
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

  void _saveTask() {
    if (!_formKey.currentState!.validate()) return;

    if (_deadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih deadline terlebih dahulu.'),
        ),
      );
      return;
    }

    final task = Task(
      title: _titleController.text.trim(),
      course: _courseController.text.trim(),
      deadline: _deadline!,
      priority: _priority,
      isCompleted: widget.initialTask?.isCompleted ?? false,
    );

    Navigator.pop(context, task);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Task' : 'Tambah Task'),
      ),
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
              validator: (value) => Validators.minLength(
                value,
                3,
                fieldName: 'Nama tugas',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _courseController,
              decoration: const InputDecoration(
                labelText: 'Mata kuliah',
                border: OutlineInputBorder(),
              ),
              validator: (value) => Validators.required(
                value,
                fieldName: 'Mata kuliah',
              ),
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
            DropdownButtonFormField<TaskPriority>(
              initialValue: _priority,
              decoration: const InputDecoration(
                labelText: 'Prioritas',
                border: OutlineInputBorder(),
              ),
              items: TaskPriority.values.map((priority) {
                return DropdownMenuItem<TaskPriority>(
                  value: priority,
                  child: Text(priority.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _priority = value);
                }
              },
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _saveTask,
              icon: Icon(
                _isEditing ? Icons.save_as_outlined : Icons.save,
              ),
              label: Text(
                _isEditing ? 'Simpan Perubahan' : 'Simpan Task',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
