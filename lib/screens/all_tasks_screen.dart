import 'package:flutter/material.dart';

import '../models/task.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/task_management.dart';
import '../widgets/task_card.dart';
import 'add_task_screen.dart';

class AllTasksScreen extends StatefulWidget {
  const AllTasksScreen({
    super.key,
    required this.tasks,
    required this.onTaskChanged,
    required this.onTaskTap,
    required this.onTaskDeleted,
    required this.courseNames,
  });

  final List<Task> tasks;
  final Future<void> Function(Task oldTask, Task updatedTask) onTaskChanged;
  final ValueChanged<Task> onTaskTap;
  final Future<void> Function(Task) onTaskDeleted;
  final List<String> courseNames;

  @override
  State<AllTasksScreen> createState() => _AllTasksScreenState();
}

class _AllTasksScreenState extends State<AllTasksScreen> {
  String _courseFilter = '';
  int _statusFilter = 0;

  Future<bool> _changeTask(Task oldTask, Task updatedTask) async {
    try {
      await widget.onTaskChanged(oldTask, updatedTask);
      if (mounted) setState(() {});
      return true;
    } on Exception catch (error) {
      if (!mounted) return false;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memperbarui task: $error')));
      return false;
    }
  }

  Future<void> _editTask(BuildContext context, Task task) async {
    final updatedTask = await Navigator.push<Task>(
      context,
      MaterialPageRoute<Task>(
        builder: (_) =>
            AddTaskScreen(initialTask: task, courseNames: widget.courseNames),
      ),
    );

    if (updatedTask == null || !context.mounted) return;

    if (!await _changeTask(task, updatedTask) || !context.mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Task berhasil diperbarui!')));
  }

  @override
  Widget build(BuildContext context) {
    final orderedTasks = TaskManagement.filterAndSort(
      widget.tasks,
      course: _courseFilter.isEmpty ? null : _courseFilter,
      isCompleted: switch (_statusFilter) {
        1 => false,
        2 => true,
        _ => null,
      },
    );

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('All Tasks'),
        backgroundColor: AppColors.canvas,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              AppSpacing.md,
              AppSpacing.page,
              0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _courseFilter,
                    decoration: const InputDecoration(
                      labelText: 'Mata kuliah',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: '',
                        child: Text('Semua mata kuliah'),
                      ),
                      ...widget.courseNames.map(
                        (name) => DropdownMenuItem(
                          value: name,
                          child: Text(name, overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => _courseFilter = value ?? ''),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: _statusFilter,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('Semua')),
                      DropdownMenuItem(value: 1, child: Text('Belum selesai')),
                      DropdownMenuItem(value: 2, child: Text('Selesai')),
                    ],
                    onChanged: (value) =>
                        setState(() => _statusFilter = value ?? 0),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: orderedTasks.isEmpty
                ? Center(
                    child: Text(
                      widget.tasks.isEmpty
                          ? 'Belum ada task.'
                          : 'Tidak ada task yang cocok dengan filter.',
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.page),
                    itemCount: orderedTasks.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final task = orderedTasks[index];

                      return TaskCard(
                        task: task,
                        onChanged: (value) {
                          if (value == null) return;

                          _changeTask(task, task.copyWith(isCompleted: value));
                        },
                        onTap: () => widget.onTaskTap(task),
                        onEdit: () => _editTask(context, task),
                        onDelete: () async {
                          await widget.onTaskDeleted(task);
                          if (mounted) setState(() {});
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
