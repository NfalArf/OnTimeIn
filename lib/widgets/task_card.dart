import 'package:flutter/material.dart';

import '../models/task.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.onChanged,
    this.onTap,
    this.isFeatured = false,
  });

  final Task task;
  final ValueChanged<bool?> onChanged;
  final VoidCallback? onTap;
  final bool isFeatured;

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
                            task.deadline,
                            style: AppTextStyles.caption.copyWith(
                              color: priority.foreground,
                            ),
                          ),
                        ),
                        _PriorityPill(
                          label: priority.label,
                          color: priority.background,
                          textColor: priority.foreground,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _PriorityStyle _priorityStyle(TaskPriority value) {
    switch (value) {
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
