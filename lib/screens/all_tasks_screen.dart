
import 'package:flutter/material.dart';

import '../models/task.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/task_card.dart';
import 'add_task_screen.dart';

class AllTasksScreen extends StatelessWidget {
  const AllTasksScreen({
    super.key,
    required this.tasks,
    required this.onTaskChanged,
    required this.onTaskTap,
    required this.onTaskDeleted,
  });

  final List<Task> tasks;
  final void Function(Task oldTask, Task updatedTask) onTaskChanged;
  final ValueChanged<Task> onTaskTap;
  final ValueChanged<Task> onTaskDeleted;

  Future<void> _editTask(
    BuildContext context,
    Task task,
  ) async {
    final updatedTask = await Navigator.push<Task>(
      context,
      MaterialPageRoute<Task>(
        builder: (_) => AddTaskScreen(initialTask: task),
      ),
    );

    if (updatedTask == null || !context.mounted) return;

    onTaskChanged(task, updatedTask);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Task berhasil diperbarui!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderedTasks = List<Task>.of(tasks)
      ..sort((a, b) => a.deadline.compareTo(b.deadline));

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('All Tasks'),
        backgroundColor: AppColors.canvas,
      ),
      body: orderedTasks.isEmpty
          ? const Center(
              child: Text('Belum ada task.'),
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

                    onTaskChanged(
                      task,
                      task.copyWith(isCompleted: value),
                    );
                  },
                  onTap: () => onTaskTap(task),
                  onEdit: () => _editTask(context, task),
                );
              },
            ),
    );
  }
}
