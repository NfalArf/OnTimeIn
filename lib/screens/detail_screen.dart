
import 'package:flutter/material.dart';

import '../models/task.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/date_formatter.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.task});

  final Task task;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  String? _catatan;

  Future<void> _bukaFormCatatan() async {
    final hasil = await Navigator.pushNamed<String>(
      context,
      AppRoutes.catatanForm,
    );

    if (!mounted || hasil == null) return;

    setState(() => _catatan = hasil);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Catatan berhasil disimpan'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(title: const Text('Task Detail')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.page),
        children: [
          Text(
            widget.task.title,
            style: AppTextStyles.heading,
          ),
          const SizedBox(height: AppSpacing.xl),

          _DetailRow(
            label: 'Course',
            value: widget.task.course,
          ),
          const SizedBox(height: AppSpacing.lg),

          _DetailRow(
            label: 'Deadline',
            value: formatTaskDeadline(widget.task.deadline),
          ),
          const SizedBox(height: AppSpacing.lg),

          _DetailRow(
            label: 'Priority',
            value: widget.task.priority.name,
          ),
          const SizedBox(height: AppSpacing.lg),

          _DetailRow(
            label: 'Status',
            value: widget.task.isCompleted
                ? 'Completed'
                : 'Not completed',
          ),
          const SizedBox(height: AppSpacing.xl),

          Text(
            'Catatan: ${_catatan ?? 'Belum ada catatan.'}',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: AppSpacing.lg),

          FilledButton.icon(
            onPressed: _bukaFormCatatan,
            icon: const Icon(Icons.edit_note),
            label: const Text('Tulis Catatan'),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTextStyles.body,
        ),
      ],
    );
  }
}
