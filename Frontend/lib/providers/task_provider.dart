import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import 'package:flutter_riverpod_todo_app/features/tasks/data/repositories/task_providers.dart';
import 'package:flutter_riverpod_todo_app/features/tasks/domain/repositories/task_repository.dart';

final tasksProvider = NotifierProvider<TasksNotifier, List<Task>>(TasksNotifier.new);

class TasksNotifier extends Notifier<List<Task>> {
  @override
  List<Task> build() {
    return []; // Initial state is an empty list
  }

  // Use the repository provider to fetch/modify tasks
  TaskRepository get _taskRepository => ref.watch(taskRepositoryProvider);

  Future<void> fetchTasks({int limit = 20, int offset = 0}) async {
    try {
      state = await _taskRepository.getTasks(limit, offset);
    } catch (e) {
      // Handle error
    }
  }

  Future<Task?> createTask(String title, {bool confirm = true}) async {
    try {
      final newTask = await _taskRepository.createTask(title, confirm);
      state = [...state, newTask]; // optimistic update done by inserting returned task
      return newTask;
    } catch (e) {
      // Handle error
      return null;
    }
  }

  Future<void> updateTask(String id, Map<String, dynamic> updates) async {
    try {
      final updated = await _taskRepository.updateTask(id, updates);
      state = [
        for (final t in state)
          if (t.id == updated.id) updated else t,
      ];
    } catch (e) {
      // Handle error
    }
  }

  /// Deletes a task and returns the removed Task so callers can offer undo.
  Future<Task?> deleteTask(String id) async {
    final idx = state.indexWhere((t) => t.id == id);
    if (idx == -1) return null;
    final removed = state[idx];

    // Optimistically remove
    state = state.where((task) => task.id != id).toList();

    try {
      await _taskRepository.deleteTask(id);
      return removed;
    } catch (e) {
      // Revert on error
      state = [removed, ...state];
      return null;
    }
  }

  /// Restores a previously removed task locally (used by Undo).
  void restoreTask(Task task) {
    state = [task, ...state];
  }
}
