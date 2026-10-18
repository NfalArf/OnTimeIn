import 'package:flutter/material.dart';

import '../models/task.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'scratchpad_sketch.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.onChanged,
    this.onTap,
    this.isFeatured = false,
    this.onEdit,
    this.onDelete,
    this.onScratchpadTap,
    this.onScratchpadDelete,
    this.onFocusTap,
  });

  final Task task;
  final ValueChanged<bool?> onChanged;
  final VoidCallback? onTap;
  final bool isFeatured;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onScratchpadTap;
  final VoidCallback? onScratchpadDelete;
  final VoidCallback? onFocusTap;

  String _formatDeadline(DateTime deadline) {
    final day = deadline.day.toString().padLeft(2, '0');
    final month = deadline.month.toString().padLeft(2, '0');
    final year = deadline.year;
    final hour = deadline.hour.toString().padLeft(2, '0');
    final minute = deadline.minute.toString().padLeft(2, '0');

    return '$day/$month/$year, $hour:$minute';
  }

  _PriorityStyle _priorityStyle(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return const _PriorityStyle(
          'Urgent',
          AppColors.coralSoft,
          AppColors.coral,
        );
      case TaskPriority.medium:
        return const _PriorityStyle(
          'Medium',
          AppColors.amberSoft,
          Color(0xFF9B6A00),
        );
      case TaskPriority.normal:
        return const _PriorityStyle(
          'Normal',
          AppColors.primarySoft,
          AppColors.primary,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final priority = _priorityStyle(task.priority);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: task.isCompleted ? 0.64 : 1,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isFeatured ? AppColors.coralSoft : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          border: Border.all(
            color: isFeatured
                ? AppColors.coral.withValues(alpha: 0.35)
                : AppColors.line,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: task.isCompleted,
              onChanged: onChanged,
              activeColor: AppColors.success,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(AppSpacing.smallRadius),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w700,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(task.course, style: AppTextStyles.caption),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 15,
                            color: priority.foreground,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              _formatDeadline(task.deadline),
                              style: AppTextStyles.caption.copyWith(
                                color: priority.foreground,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          _PriorityPill(
                            label: priority.label,
                            color: priority.background,
                            textColor: priority.foreground,
                          ),
                        ],
                      ),
                      if (task.scratchpad case final scratchpad?
                          when scratchpad.hasContent) ...[
                        const SizedBox(height: AppSpacing.md),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft.withValues(
                              alpha: 0.55,
                            ),
                            borderRadius: BorderRadius.circular(
                              AppSpacing.smallRadius,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Scratchpad',
                                style: AppTextStyles.overline.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                              if (scratchpad.idea.trim().isNotEmpty) ...[
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  scratchpad.idea.trim(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.ink,
                                  ),
                                ),
                              ],
                              if (scratchpad.strokes.isNotEmpty) ...[
                                const SizedBox(height: AppSpacing.sm),
                                ScratchpadSketch(
                                  strokes: scratchpad.strokes,
                                  width: double.infinity,
                                  height: 88,
                                ),
                              ],
                              if (scratchpad.reference.trim().isNotEmpty ||
                                  scratchpad.referenceUrl.trim().isNotEmpty ||
                                  scratchpad.strokes.isNotEmpty) ...[
                                const SizedBox(height: AppSpacing.xs),
                                Wrap(
                                  spacing: AppSpacing.md,
                                  children: [
                                    if (scratchpad.reference.trim().isNotEmpty)
                                      const _ScratchpadDetail(
                                        icon: Icons.notes_rounded,
                                        label: 'Referensi',
                                      ),
                                    if (scratchpad.referenceUrl
                                        .trim()
                                        .isNotEmpty)
                                      const _ScratchpadDetail(
                                        icon: Icons.link_rounded,
                                        label: 'Tautan',
                                      ),
                                    if (scratchpad.strokes.isNotEmpty)
                                      _ScratchpadDetail(
                                        icon: Icons.draw_outlined,
                                        label:
                                            '${scratchpad.strokes.length} sketsa',
                                      ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                      if (onScratchpadTap != null ||
                          onScratchpadDelete != null ||
                          onFocusTap != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Wrap(
                          spacing: AppSpacing.xs,
                          children: [
                            if (onScratchpadTap != null)
                              TextButton.icon(
                                onPressed: onScratchpadTap,
                                icon: const Icon(
                                  Icons.edit_note_rounded,
                                  size: 18,
                                ),
                                label: Text(
                                  task.scratchpad?.hasContent == true
                                      ? 'Edit Scratchpad'
                                      : 'Scratchpad',
                                ),
                                style: TextButton.styleFrom(
                                  visualDensity: VisualDensity.compact,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                  ),
                                ),
                              ),
                            if (onScratchpadDelete != null &&
                                task.scratchpad?.hasContent == true)
                              TextButton.icon(
                                onPressed: onScratchpadDelete,
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  size: 18,
                                ),
                                label: const Text('Hapus Scratchpad'),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.coral,
                                  visualDensity: VisualDensity.compact,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                  ),
                                ),
                              ),
                            if (onFocusTap != null)
                              TextButton.icon(
                                onPressed: onFocusTap,
                                icon: const Icon(
                                  Icons.timer_outlined,
                                  size: 18,
                                ),
                                label: const Text('Focus'),
                                style: TextButton.styleFrom(
                                  visualDensity: VisualDensity.compact,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: onEdit,
              tooltip: 'Edit tugas',
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              onPressed: onDelete,
              tooltip: 'Hapus tugas',
              icon: const Icon(Icons.delete_outline_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScratchpadDetail extends StatelessWidget {
  const _ScratchpadDetail({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.primary),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: AppColors.primary),
        ),
      ],
    );
  }
}

class _PriorityStyle {
  const _PriorityStyle(this.label, this.background, this.foreground);

  final String label;
  final Color background;
  final Color foreground;
}

class _PriorityPill extends StatelessWidget {
  const _PriorityPill({
    required this.label,
    required this.color,
    required this.textColor,
  });

  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.overline.copyWith(
          color: textColor,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
