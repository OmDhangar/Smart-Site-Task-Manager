import 'package:flutter_riverpod_todo_app/features/tasks/data/models/task_preview.dart';
import 'package:flutter_riverpod_todo_app/models/task.dart';

abstract class TaskRepository {
  Future<TaskPreview> getTaskPreview(String taskText);
    Future<Task> createTask(String taskText, bool confirm);
      Future<List<Task>> getTasks(int limit, int offset);
        Future<Task> getTaskById(String id);
          Future<Task> updateTask(String id, Map<String, dynamic> updates);
            Future<void> deleteTask(String id);
            }
            