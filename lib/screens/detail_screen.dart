import 'package:flutter/material.dart';

import '../models/task.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.task});

  final Task task;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  String? _catatan;

  Future<void> _writeNote() async {
    final hasil = await Navigator.pushNamed<String>(
      context,
      AppRoutes.catatanForm,
    );
    if (!mounted || hasil == null) return;

    setState(() => _catatan = hasil);
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Task')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.page),
        children: [
          Text(task.title, style: AppTextStyles.heading),
          const SizedBox(height: AppSpacing.xl),
          _DetailRow(label: 'Mata kuliah', value: task.course),
          _DetailRow(label: 'Deadline', value: task.deadline),
          _DetailRow(label: 'Prioritas', value: _priorityLabel(task.priority)),
          _DetailRow(
            label: 'Status',
            value: task.isCompleted ? 'Selesai' : 'Belum selesai',
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton.icon(
            onPressed: _writeNote,
            icon: const Icon(Icons.edit_note),
            label: const Text('Tulis Catatan'),
          ),
          if (_catatan != null) ...[
            const SizedBox(height: AppSpacing.xl),
            Text('Catatan', style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radius),
                border: Border.all(color: AppColors.line),
              ),
              child: Text(_catatan!, style: AppTextStyles.body),
            ),
          ],
        ],
      ),
    );
  }

  String _priorityLabel(TaskPriority priority) {
    return switch (priority) {
      TaskPriority.high => 'Urgent',
      TaskPriority.medium => 'Medium',
      TaskPriority.normal => 'Normal',
    };
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(label, style: AppTextStyles.caption),
          ),
          Expanded(child: Text(value, style: AppTextStyles.body)),
        ],
      ),
    );
  }
}
