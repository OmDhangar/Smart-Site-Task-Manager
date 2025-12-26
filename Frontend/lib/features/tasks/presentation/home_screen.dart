import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_todo_app/features/tasks/presentation/create_task_screen.dart';
import 'package:flutter_riverpod_todo_app/models/task.dart';
import 'package:flutter_riverpod_todo_app/providers/task_provider.dart';
import 'package:flutter_riverpod_todo_app/features/tasks/presentation/task_detail_screen.dart';
import 'package:flutter_riverpod_todo_app/features/tasks/presentation/edit_task_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _activeFilter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tasksProvider.notifier).fetchTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tasksState = ref.watch(tasksProvider);
    final tasks = _filteredTasks(tasksState.tasks);
    final accent = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
        title: const Text('Tasks'),
        actions: [IconButton(icon: const Icon(Icons.notifications_none_outlined), onPressed: () {})],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16),
        child: Column(
          children: [
            _buildFilterChips(context),
            const SizedBox(height: 12),
            Expanded(
              child: Stack(
                children: [
                  if (tasks.isEmpty && !tasksState.isLoading)
                    const Center(
                      child: Text(
                        'No tasks yet.\nCreate your first task to get started.',
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    ListView.separated(
                      itemCount: tasks.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return Dismissible(
                          key: ValueKey(task.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            color: Colors.red.withOpacity(0.9),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (_) async {
                            final removed = await ref.read(tasksProvider.notifier).deleteTask(task.id);
                            if (!context.mounted) return;
                            final messenger = ScaffoldMessenger.of(context);
                            messenger.showSnackBar(SnackBar(
                              content: const Text('Task deleted'),
                              backgroundColor: Theme.of(context).cardColor,
                              action: SnackBarAction(
                                label: 'Undo',
                                textColor: Theme.of(context).colorScheme.secondary,
                                onPressed: () {
                                  if (removed != null) {
                                    ref.read(tasksProvider.notifier).restoreTask(removed);
                                  }
                                },
                              ),
                            ));
                          },
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TaskDetailScreen(task: task),
                                ),
                              );
                            },
                            onLongPress: () {
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: Theme.of(context).cardColor,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                ),
                                builder: (ctx) {
                                  return SafeArea(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ListTile(
                                            leading: const Icon(Icons.edit, color: Colors.white),
                                            title: const Text(
                                              'Edit task',
                                              style: TextStyle(color: Colors.white),
                                            ),
                                            onTap: () {
                                              Navigator.pop(ctx);
                                              Navigator.push(
                                                ctx,
                                                MaterialPageRoute(
                                                  builder: (_) => EditTaskScreen(task: task),
                                                ),
                                              );
                                            },
                                          ),
                                          ListTile(
                                            leading: const Icon(Icons.delete, color: Color(0xFFFF8A80)),
                                            title: const Text(
                                              'Delete task',
                                              style: TextStyle(color: Colors.white),
                                            ),
                                            onTap: () async {
                                              Navigator.pop(ctx);
                                              final removed =
                                                  await ref.read(tasksProvider.notifier).deleteTask(task.id);
                                              if (!context.mounted) return;
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: const Text('Task deleted'),
                                                  backgroundColor: Theme.of(context).cardColor,
                                                  action: SnackBarAction(
                                                    label: 'Undo',
                                                    textColor: Theme.of(context).colorScheme.secondary,
                                                    onPressed: () {
                                                      if (removed != null) {
                                                        ref.read(tasksProvider.notifier).restoreTask(removed);
                                                      }
                                                    },
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            child: PremiumTaskCard(task: task, accent: accent),
                          ),
                        );
                      },
                    ),
                  if (tasksState.isLoading)
                    const Positioned.fill(
                      child: IgnorePointer(
                        ignoring: true,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                  if (tasksState.errorMessage != null && !tasksState.isLoading)
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          tasksState.errorMessage!,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateTaskScreen()));
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    final accent = Theme.of(context).colorScheme.secondary;
    return Row(children: [
      ChoiceChip(
        label: const Text('All'),
        selected: _activeFilter == 'All',
        onSelected: (_) => setState(() => _activeFilter = 'All'),
        backgroundColor: Colors.transparent,
        selectedColor: accent,
        labelStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: accent)),
      ),
      const SizedBox(width: 8),
      ChoiceChip(
        label: const Text('Work'),
        selected: _activeFilter == 'Work',
        onSelected: (_) => setState(() => _activeFilter = 'Work'),
        backgroundColor: Colors.transparent,
        labelStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey)),
      ),
      const SizedBox(width: 8),
      ChoiceChip(
        label: const Text('Personal'),
        selected: _activeFilter == 'Personal',
        onSelected: (_) => setState(() => _activeFilter = 'Personal'),
        backgroundColor: Colors.transparent,
        labelStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey)),
      ),
    ]);
  }

  List<Task> _filteredTasks(List<Task> tasks) {
    if (_activeFilter == 'All') return tasks;
    return tasks.where((t) => t.category.toLowerCase() == _activeFilter.toLowerCase()).toList();
  }
}

class PremiumTaskCard extends StatelessWidget {
  final Task task;
  final Color accent;

  const PremiumTaskCard({super.key, required this.task, required this.accent});

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

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 16, fontWeight: FontWeight.w600);
    final metaStyle = Theme.of(context).textTheme.bodyLarge;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(task.title, style: titleStyle, maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 12),
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(task.category.toUpperCase(), style: TextStyle(color: accent)),
          ),
          const SizedBox(width: 12),
          Container(width: 8, height: 8, decoration: BoxDecoration(color: _priorityColor(task.priority), shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text('Priority', style: metaStyle),
          const Spacer(),
          Text(task.dueDate != null ? _formatDate(task.dueDate!) : '', style: Theme.of(context).textTheme.bodySmall),
        ])
      ]),
    );
  }

  String _formatDate(DateTime date) {
    final month = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][date.month - 1];
    return '$month ${date.day}';
  }
}
