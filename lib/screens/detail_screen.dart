import 'package:flutter/material.dart';

import '../models/scratchpad.dart';
import '../models/task.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/date_formatter.dart';
import '../widgets/scratchpad_sketch.dart';
import 'focus_timer_screen.dart';
import 'scratchpad_screen.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.task});

  final Task task;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  String? _catatan;
  late Task _task = widget.task;

  void _close() => Navigator.pop(context, _task);

  Future<void> _bukaScratchpad() async {
    final result = await Navigator.push<ScratchpadEditResult>(
      context,
      MaterialPageRoute<ScratchpadEditResult>(
        builder: (_) => ScratchpadScreen(
          initialScratchpad: _task.scratchpad,
          taskTitle: _task.title,
        ),
      ),
    );
    if (!mounted || result == null) return;

    setState(
      () => _task = _task.copyWith(
        scratchpad: result.scratchpad,
        clearScratchpad: result.isDeleted,
      ),
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            result.isDeleted
                ? 'Scratchpad berhasil dihapus'
                : 'Scratchpad berhasil disimpan',
          ),
        ),
      );
  }

  Future<void> _mulaiFocus() async {
    final updatedTask = await Navigator.push<Task>(
      context,
      MaterialPageRoute<Task>(builder: (_) => FocusTimerScreen(task: _task)),
    );
    if (!mounted || updatedTask == null) return;

    setState(() => _task = updatedTask);
  }

  String _formatFocusTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    if (hours > 0) return '$hours jam $minutes menit';
    return '$minutes menit';
  }

  Future<void> _bukaFormCatatan() async {
    final hasil = await Navigator.pushNamed<String>(
      context,
      AppRoutes.catatanForm,
    );

    if (!mounted || hasil == null) return;

    setState(() => _catatan = hasil);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Catatan berhasil disimpan')));
  }

  @override
  Widget build(BuildContext context) {
    final scratchpad = _task.scratchpad;
    final totalFocusSeconds = _task.focusLogs.fold<int>(
      0,
      (total, log) => total + log.durationSeconds,
    );

    return PopScope<Task>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: Scaffold(
        backgroundColor: AppColors.canvas,
        appBar: AppBar(
          title: const Text('Task Detail'),
          leading: IconButton(
            onPressed: _close,
            tooltip: 'Kembali',
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.page),
          children: [
            Text(_task.title, style: AppTextStyles.heading),
            const SizedBox(height: AppSpacing.xl),
            _DetailRow(label: 'Course', value: _task.course),
            const SizedBox(height: AppSpacing.lg),
            _DetailRow(
              label: 'Deadline',
              value: formatTaskDeadline(_task.deadline),
            ),
            const SizedBox(height: AppSpacing.lg),
            _DetailRow(label: 'Priority', value: _task.priority.name),
            const SizedBox(height: AppSpacing.lg),
            _DetailRow(
              label: 'Status',
              value: _task.isCompleted ? 'Completed' : 'Not completed',
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Catatan: ${_catatan ?? 'Belum ada catatan.'}',
              style: AppTextStyles.body,
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Scratchpad', style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.sm),
            if (scratchpad?.hasContent == true) ...[
              if (scratchpad!.idea.trim().isNotEmpty)
                Text(scratchpad.idea, style: AppTextStyles.body),
              if (scratchpad.reference.trim().isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                SelectableText(
                  'Referensi: ${scratchpad.reference}',
                  style: AppTextStyles.body,
                ),
              ],
              if (scratchpad.referenceUrl.trim().isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.link_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: SelectableText(
                        scratchpad.referenceUrl,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (scratchpad.strokes.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                ScratchpadSketch(
                  strokes: scratchpad.strokes,
                  width: double.infinity,
                  height: 160,
                ),
              ],
            ] else
              const Text(
                'Belum ada ide, referensi, atau sketsa.',
                style: AppTextStyles.caption,
              ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: _bukaScratchpad,
              icon: const Icon(Icons.draw_outlined),
              label: Text(
                scratchpad?.hasContent == true
                    ? 'Edit Scratchpad'
                    : 'Tambah Scratchpad',
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Focus', style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${_formatFocusTime(totalFocusSeconds)} tercatat '
              'dalam ${_task.focusLogs.length} sesi.',
              style: AppTextStyles.body,
            ),
            const SizedBox(height: AppSpacing.sm),
            FilledButton.icon(
              onPressed: _mulaiFocus,
              icon: const Icon(Icons.timer_outlined),
              label: const Text('Mulai Focus Timer'),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.tonalIcon(
              onPressed: _bukaFormCatatan,
              icon: const Icon(Icons.edit_note),
              label: const Text('Tulis Catatan'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: AppSpacing.xs),
        Text(value, style: AppTextStyles.body),
      ],
    );
  }
}
