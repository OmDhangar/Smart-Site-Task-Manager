import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_todo_app/features/tasks/presentation/classification_preview_screen.dart';
import 'package:flutter_riverpod_todo_app/features/tasks/data/models/task_preview.dart';
import 'package:flutter_riverpod_todo_app/features/tasks/data/repositories/task_providers.dart';

class CreateTaskScreen extends ConsumerStatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  ConsumerState<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends ConsumerState<CreateTaskScreen> {
  final _controller = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _loading = true);
    try {
      final repo = ref.read(taskRepositoryProvider);
      final previewFuture = repo.getTaskPreview(text);
      final delayFuture = Future.delayed(const Duration(seconds: 2));
      final results = await Future.wait([previewFuture, delayFuture]);
      final preview = results[0] as TaskPreview;
      if (!context.mounted) return;
      Navigator.push(context, MaterialPageRoute(builder: (c) => ClassificationPreviewScreen(preview: preview, originalText: text)));
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Analyze failed: ${e.toString()}')));
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
            Expanded(
              child: TextField(
                controller: _controller,
                expands: true,
                maxLines: null,
                textAlignVertical: TextAlignVertical.top,
                style: const TextStyle(color: Colors.white, fontSize: 18),
                decoration: const InputDecoration(
                  hintText: 'Describe your task in plain English...',
                  hintStyle: TextStyle(color: Color(0xFF9E9E9E), fontSize: 24),
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
              child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator()) : const Text('Analyze Task'),
            ),
          ),
        )
      ]),
    );
  }
}
