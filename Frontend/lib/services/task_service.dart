import 'package:flutter_riverpod_todo_app/core/network/dio_client.dart';
import '../models/task.dart';

/// Backwards-compatible wrapper (not used by default) that delegates to `DioClient`.
/// This avoids duplicated hardcoded URLs and keys.
class TaskService {
  final DioClient _dioClient = DioClient();

  Future<List<Task>> fetchTasks() async {
    final response = await _dioClient.get('/api/tasks');
    final body = response.data;

    if (body == null || body['success'] != true) {
      throw Exception(body != null && body['message'] != null ? body['message'] : 'Failed to load tasks');
    }

    return (body['data']?['tasks'] as List? ?? [])
        .map((t) => Task.fromJson(t as Map<String, dynamic>))
        .toList();
  }

  Future<Task> createTask(Task task) async {
    try {
      final response = await _dioClient.post(
        '/api/tasks',
        data: task.toJson(),
      );

      final body = response.data;

      if (body == null || body['success'] != true) {
        throw Exception(body != null && body['message'] != null ? body['message'] : 'Failed to create task');
      }
      return Task.fromJson(body['data']?['task'] ?? {});
    } catch (e) {
      throw Exception('Failed to connect to the server');
    }
  }


  Future<Task> updateTask(Task task) async {
    final response = await _dioClient.patch('/api/tasks/${task.id}', data: task.toJson());
    final body = response.data;
    if (body == null || body['success'] != true) {
      throw Exception(body != null && body['message'] != null ? body['message'] : 'Failed to update task');
    }
    return Task.fromJson(body['data']?['task'] ?? {});
  }

  Future<void> deleteTask(String id) async {
    final response = await _dioClient.delete('/api/tasks/$id');
    final body = response.data;
    if (body == null || body['success'] != true) {
      throw Exception(body != null && body['message'] != null ? body['message'] : 'Failed to delete task');
    }
  }
}
