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

  Future<void> _tulisCatatan() async {
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
          _TaskInformation(label: 'Mata kuliah', value: task.course),
          _TaskInformation(label: 'Deadline', value: task.deadline),
          _TaskInformation(label: 'Prioritas', value: task.priority.name),
          _TaskInformation(
            label: 'Status',
            value: task.isCompleted ? 'Selesai' : 'Belum selesai',
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Catatan', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.sm),
          if (_catatan == null)
            const Text('Belum ada catatan.', style: AppTextStyles.body)
          else
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.line),
                borderRadius: BorderRadius.circular(AppSpacing.smallRadius),
              ),
              child: Text(_catatan!, style: AppTextStyles.body),
            ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: _tulisCatatan,
            icon: const Icon(Icons.edit_note_rounded),
            label: Text(_catatan == null ? 'Tulis Catatan' : 'Edit Catatan'),
          ),
        ],
      ),
    );
  }
}

class _TaskInformation extends StatelessWidget {
  const _TaskInformation({required this.label, required this.value});

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
