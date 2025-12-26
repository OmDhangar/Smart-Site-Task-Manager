import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_todo_app/features/tasks/presentation/widgets/audit_history_timeline.dart';
import 'package:flutter_riverpod_todo_app/features/tasks/presentation/edit_task_screen.dart';
import 'package:flutter_riverpod_todo_app/models/task.dart';
import 'package:flutter_riverpod_todo_app/providers/task_provider.dart';

class TaskDetailScreen extends ConsumerWidget {
  final Task task;
  const TaskDetailScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: const Text('Task overview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Theme.of(context).cardColor,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
                builder: (ctx) {
                  return SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        ListTile(
                          leading: const Icon(Icons.edit, color: Colors.white),
                          title: const Text('Edit task', style: TextStyle(color: Colors.white)),
                          onTap: () {
                            Navigator.pop(ctx);
                            Navigator.push(ctx, MaterialPageRoute(builder: (_) => EditTaskScreen(task: task)));
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.delete, color: Color(0xFFFF8A80)),
                          title: const Text('Delete task', style: TextStyle(color: Colors.white)),
                          onTap: () async {
                            Navigator.pop(ctx);
                            final removed = await ref.read(tasksProvider.notifier).deleteTask(task.id);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: const Text('Task deleted'),
                              backgroundColor: Theme.of(context).cardColor,
                              action: SnackBarAction(
                                label: 'Undo',
                                textColor: Theme.of(context).colorScheme.secondary,
                                onPressed: () {
                                  if (removed != null) ref.read(tasksProvider.notifier).restoreTask(removed);
                                },
                              ),
                            ));
                          },
                        ),
                      ]),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (task.description != null && task.description!.isNotEmpty) ...[
              Text(task.description!, style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 16),
            ],
            _buildMetadataSection(context),
            const SizedBox(height: 24),
            _buildChipsSection('Extracted entities', _entitiesList()),
            const SizedBox(height: 24),
            _buildChipsSection('Suggested actions', task.suggestedActions ?? []),
            const SizedBox(height: 24),
            const Text('Audit History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const AuditHistoryTimeline(),
          ],
        ),
      ),
    );
  }

  List<String> _entitiesList() {
    final map = task.extractedEntities ?? {};
    final List<String> items = [];
    void addList(String key) {
      final list = (map[key] as List?)?.map((e) => e.toString()).toList() ?? [];
      items.addAll(list);
    }

    addList('dates');
    addList('people');
    addList('locations');
    addList('keywords');

    return items;
  }

  Color _priorityColor(Priority priority) {
    switch (priority) {
      case Priority.high:
        return Colors.red;
      case Priority.medium:
        return Colors.yellow;
      case Priority.low:
      default:
        return Colors.green;
    }
  }

  String _formatDate(DateTime date) {
    final month = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][date.month - 1];
    return '$month ${date.day}';
  }

  Widget _buildMetadataSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Metadata', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildMetadataRow('Category', task.category.toUpperCase(), chipColor: Theme.of(context).colorScheme.secondary),
        const SizedBox(height: 12),
        _buildMetadataRow('Priority', task.priority.name.toUpperCase(), icon: Icons.circle, iconColor: _priorityColor(task.priority)),
        const SizedBox(height: 12),
        _buildMetadataRow('Due Date', task.dueDate != null ? _formatDate(task.dueDate!) : '—'),
      ],
    );
  }

  Widget _buildMetadataRow(String title, String value, {IconData? icon, Color? iconColor, Color? chipColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: Colors.white70, fontSize: 16)),
        Row(
          children: [
            if (icon != null)
              Icon(icon, color: iconColor ?? Colors.white, size: 12),
            if (icon != null)
              const SizedBox(width: 8),
            if (chipColor != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: chipColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(value, style: TextStyle(color: chipColor, fontSize: 12, fontWeight: FontWeight.bold)),
              )
            else
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildChipsSection(String title, List<String> chips) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: chips.map((chip) {
            return Chip(
              label: Text(chip),
              backgroundColor: const Color(0xFF16161A),
              labelStyle: const TextStyle(color: Colors.white),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Colors.grey),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
