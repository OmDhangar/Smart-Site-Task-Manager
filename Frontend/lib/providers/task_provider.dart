import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import 'package:flutter_riverpod_todo_app/features/tasks/data/repositories/task_providers.dart';
import 'package:flutter_riverpod_todo_app/features/tasks/domain/repositories/task_repository.dart';

/// Simple input sanitization for task-related free text.
String _sanitizeInput(String raw, {int maxLength = 500}) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return '';
  final normalizedWhitespace = trimmed.replaceAll(RegExp(r'\s+'), ' ');
  return normalizedWhitespace.length > maxLength
      ? normalizedWhitespace.substring(0, maxLength)
      : normalizedWhitespace;
}

class TasksState {
  final List<Task> tasks;
  final bool isLoading;
  final String? errorMessage;

  const TasksState({
    required this.tasks,
    this.isLoading = false,
    this.errorMessage,
  });

  TasksState copyWith({
    List<Task>? tasks,
    bool? isLoading,
    String? errorMessage,
  }) {
    return TasksState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

final tasksProvider =
    NotifierProvider<TasksNotifier, TasksState>(TasksNotifier.new);

class TasksNotifier extends Notifier<TasksState> {
  @override
  TasksState build() {
    return const TasksState(tasks: []);
  }

  // Use the repository provider to fetch/modify tasks
  TaskRepository get _taskRepository => ref.watch(taskRepositoryProvider);

  Future<void> fetchTasks({int limit = 20, int offset = 0}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final tasks = await _taskRepository.getTasks(limit, offset);
      state = state.copyWith(tasks: tasks, isLoading: false);
    } catch (e) {
      state =
          state.copyWith(isLoading: false, errorMessage: 'Failed to load tasks');
    }
  }

  Future<Task?> createTask(String title, String description, {bool confirm = true}) async {
    final sanitizedTitle = _sanitizeInput(title);
    final sanitizedDescription = _sanitizeInput(description, maxLength: 1000);
    
    if (sanitizedTitle.isEmpty) {
      state = state.copyWith(errorMessage: 'Task title cannot be empty.');
      return null;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final newTask = await _taskRepository.createTask(sanitizedTitle, sanitizedDescription, confirm: confirm);
      state = state.copyWith(
        tasks: [...state.tasks, newTask],
        isLoading: false,
      );
      return newTask;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to create task',
      );
      return null;
    }
  }

  Future<void> updateTask(String id, Map<String, dynamic> updates) async {
    final sanitizedUpdates = Map<String, dynamic>.from(updates);
    if (sanitizedUpdates.containsKey('title')) {
      sanitizedUpdates['title'] = _sanitizeInput(
        sanitizedUpdates['title']?.toString() ?? '',
      );
    }
    if (sanitizedUpdates.containsKey('description')) {
      sanitizedUpdates['description'] = _sanitizeInput(
        sanitizedUpdates['description']?.toString() ?? '',
        maxLength: 1000,
      );
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final updated = await _taskRepository.updateTask(id, sanitizedUpdates);
      state = state.copyWith(
        tasks: [
          for (final t in state.tasks) if (t.id == updated.id) updated else t,
        ],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to update task',
      );
    }
  }

  /// Deletes a task and returns the removed Task so callers can offer undo.
  Future<Task?> deleteTask(String id) async {
    final idx = state.tasks.indexWhere((t) => t.id == id);
    if (idx == -1) return null;
    final removed = state.tasks[idx];

    // Optimistically remove
    state = state.copyWith(
      tasks: state.tasks.where((task) => task.id != id).toList(),
      errorMessage: null,
    );

    try {
      await _taskRepository.deleteTask(id);
      return removed;
    } catch (e) {
      // Revert on error
      state = state.copyWith(
        tasks: [removed, ...state.tasks],
        errorMessage: 'Failed to delete task',
      );
      return null;
    }
  }

  /// Restores a previously removed task locally (used by Undo).
  void restoreTask(Task task) {
    state = state.copyWith(tasks: [task, ...state.tasks]);
  }
}
