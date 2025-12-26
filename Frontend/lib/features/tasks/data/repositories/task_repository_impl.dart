import 'package:flutter_riverpod_todo_app/core/network/dio_client.dart';
import 'package:flutter_riverpod_todo_app/features/tasks/data/models/task_entities.dart';
import 'package:flutter_riverpod_todo_app/features/tasks/data/models/task_preview.dart';
import 'package:flutter_riverpod_todo_app/features/tasks/domain/repositories/task_repository.dart';
import 'package:flutter_riverpod_todo_app/models/task.dart';

class TaskRepositoryImpl implements TaskRepository {
  final DioClient _dioClient;

  TaskRepositoryImpl(this._dioClient);

  @override
  Future<TaskPreview> getTaskPreview(String taskText) async {
    // Assuming backend supports a preview endpoint or reuse create with confirm=false
    final response = await _dioClient.post('/api/tasks/preview', data: {'title': taskText});

    final body = response.data;
    if (body == null || body['success'] != true) {
      throw Exception(body != null && body['message'] != null ? body['message'] : 'Preview failed');
    }

    final data = body['data'] ?? {};
    final preview = data['preview'] ?? {};

    return TaskPreview(
      category: preview['category'] ?? '',
      priority: preview['priority'] ?? 'low',
      entities: TaskEntities(
        dates: List<String>.from((preview['extracted_entities']?['dates'] ?? [])),
        people: List<String>.from((preview['extracted_entities']?['people'] ?? [])),
        locations: List<String>.from((preview['extracted_entities']?['locations'] ?? [])),
        topics: List<String>.from((preview['extracted_entities']?['keywords'] ?? [])),
      ),
      suggestedActions: List<String>.from(preview['suggested_actions'] ?? []),
    );
  }

  @override
  Future<Task> createTask(String title, String description, {bool confirm = true}) async {
    final response = await _dioClient.post('/api/tasks', data: {
      'title': title,
      'description': description,
      if (confirm) 'confirm': true,
    });

    final body = response.data;
    if (body == null || body['success'] != true) {
      throw Exception(body != null && body['message'] != null ? body['message'] : 'Create failed');
    }

    final taskJson = body['data']?['task'];
    if (taskJson == null) throw Exception('Task not returned');
    return Task.fromJson(taskJson);
  }

  @override
  Future<List<Task>> getTasks(int limit, int offset) async {
    final response = await _dioClient.get('/api/tasks', queryParameters: {
      'limit': limit,
      'offset': offset,
    });

    final body = response.data;
    if (body == null || body['success'] != true) {
      throw Exception(body != null && body['message'] != null ? body['message'] : 'Get tasks failed');
    }

    final tasks = (body['data']?['tasks'] as List? ?? [])
        .map((t) => Task.fromJson(t as Map<String, dynamic>))
        .toList();
    return tasks;
  }

  @override
  Future<Task> getTaskById(String id) async {
    final response = await _dioClient.get('/api/tasks/$id');
    final body = response.data;
    if (body == null || body['success'] != true) {
      throw Exception(body != null && body['message'] != null ? body['message'] : 'Get task failed');
    }

    final taskJson = body['data']?['task'];
    if (taskJson == null) throw Exception('Task not returned');
    return Task.fromJson(taskJson);
  }

  @override
  Future<Task> updateTask(String id, Map<String, dynamic> updates) async {
    final response = await _dioClient.patch('/api/tasks/$id', data: updates);
    final body = response.data;
    if (body == null || body['success'] != true) {
      throw Exception(body != null && body['message'] != null ? body['message'] : 'Update failed');
    }

    // Backend does not send full object on update by specification — return a refreshed version by calling GET
    return await getTaskById(id);
  }

  @override
  Future<void> deleteTask(String id) async {
    final response = await _dioClient.delete('/api/tasks/$id');
    final body = response.data;
    if (body == null || body['success'] != true) {
      throw Exception(body != null && body['message'] != null ? body['message'] : 'Delete failed');
    }
  }
}
