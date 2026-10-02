import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/routine_task.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';
import 'edit_task_sheet.dart';

class TaskCard extends StatefulWidget {
  final RoutineTask task;
  final int index;

  const TaskCard({
    super.key,
    required this.task,
    required this.index,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _checkController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.elasticOut),
    );

    if (widget.task.isCompletedToday) {
      _checkController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant TaskCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.task.isCompletedToday != oldWidget.task.isCompletedToday) {
      if (widget.task.isCompletedToday) {
        _checkController.forward(from: 0.0);
      } else {
        _checkController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _checkController.dispose();
    super.dispose();
  }

  void _openEditModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      builder: (context) => EditTaskSheet(task: widget.task),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context, listen: false);
    final isDone = widget.task.isCompletedToday;
    final streak = widget.task.effectiveStreak;

    return Dismissible(
      key: Key(widget.task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.danger.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
          ],
        ),
      ),
      onDismissed: (direction) {
        final deletedTask = widget.task;
        final deletedIndex = widget.index;

        provider.deleteTask(deletedTask.id);

        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.surfaceLight,
            content: Text(
              '"${deletedTask.title}" deleted',
              style: const TextStyle(color: AppTheme.textPrimary),
            ),
            action: SnackBarAction(
              label: 'Undo',
              textColor: AppTheme.primary,
              onPressed: () {
                provider.reinsertTask(deletedTask, deletedIndex);
              },
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
      child: GestureDetector(
        onLongPress: () => _openEditModal(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isDone
                ? AppTheme.surface.withOpacity(0.6)
                : AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDone
                  ? AppTheme.primary.withOpacity(0.3)
                  : AppTheme.border,
              width: isDone ? 1.5 : 1.0,
            ),
            boxShadow: isDone
                ? [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: Row(
            children: [
              // Emoji Icon Badge
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDone
                      ? AppTheme.primary.withOpacity(0.12)
                      : AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  widget.task.icon.isNotEmpty ? widget.task.icon : '⭐',
                  style: const TextStyle(fontSize: 22),
                ),
              ),
              const SizedBox(width: 14),

              // Title & Category
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 250),
                      style: TextStyle(
                        color: isDone
                            ? AppTheme.textMuted
                            : AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        decoration: isDone
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        decorationColor: AppTheme.textMuted,
                        decorationThickness: 2,
                      ),
                      child: Text(
                        widget.task.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          widget.task.category,
                          style: TextStyle(
                            color: isDone
                                ? AppTheme.textMuted
                                : AppTheme.indigo,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (streak > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: AppTheme.textMuted,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '🔥 $streak ${streak == 1 ? "day" : "days"}',
                            style: TextStyle(
                              color: isDone
                                  ? AppTheme.textMuted
                                  : AppTheme.streakOrange,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Edit Button
              IconButton(
                onPressed: () => _openEditModal(context),
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 20,
                  color: AppTheme.textMuted,
                ),
                tooltip: 'Edit routine',
              ),

              // Animated Glowing Checkbox Toggle
              GestureDetector(
                onTap: () {
                  provider.toggleTask(widget.task.id);
                },
                behavior: HitTestBehavior.opaque,
                child: AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: isDone ? _scaleAnimation.value : 1.0,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDone ? AppTheme.primary : Colors.transparent,
                          border: Border.all(
                            color: isDone
                                ? AppTheme.primary
                                : AppTheme.textSecondary.withOpacity(0.5),
                            width: 2,
                          ),
                          boxShadow: isDone
                              ? [
                                  BoxShadow(
                                    color: AppTheme.primary.withOpacity(0.5),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                        child: isDone
                            ? const Icon(
                                Icons.check_rounded,
                                size: 20,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
