import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_todo_app/features/tasks/presentation/classification_preview_screen.dart';
import 'package:flutter_riverpod_todo_app/providers/task_provider.dart';

class CreateTaskScreen extends ConsumerStatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  ConsumerState<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends ConsumerState<CreateTaskScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a task title')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final created = await ref
          .read(tasksProvider.notifier)
          .createTask(title, description, confirm: true);
      if (!context.mounted) return;
      if (created != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (c) => ClassificationPreviewScreen(task: created),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create task')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Analyze failed: ${e.toString()}')),
        );
      }
    } finally {
      if (context.mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: const Text('Create Task'),
      ),
      body: Stack(children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(children: [
            // Title field
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
              decoration: const InputDecoration(
                hintText: 'Task title',
                hintStyle: TextStyle(color: Color(0xFF9E9E9E), fontSize: 20),
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFF2A2A2A)),
            const SizedBox(height: 16),
            // Description field
            Expanded(
              child: TextField(
                controller: _descriptionController,
                expands: true,
                maxLines: null,
                textAlignVertical: TextAlignVertical.top,
                style: const TextStyle(color: Colors.white, fontSize: 18),
                decoration: const InputDecoration(
                  hintText: 'Describe your task in plain English...',
                  hintStyle: TextStyle(color: Color(0xFF9E9E9E), fontSize: 18),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 100),
          ]),
        ),
        Positioned(
          left: 20,
          right: 20,
          bottom: 20,
          child: SafeArea(
            child: ElevatedButton(
              onPressed: _loading ? null : _analyze,
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _loading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator())
                  : const Text('Analyze Task'),
            ),
          ),
        )
      ]),
    );
  }
}
