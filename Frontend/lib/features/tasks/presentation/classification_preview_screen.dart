import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_todo_app/features/tasks/presentation/task_detail_screen.dart';
import 'package:flutter_riverpod_todo_app/models/task.dart';

class ClassificationPreviewScreen extends ConsumerStatefulWidget {
  final Task task;

  const ClassificationPreviewScreen({
    super.key,
    required this.task,
  });

  @override
  ConsumerState<ClassificationPreviewScreen> createState() => _ClassificationPreviewScreenState();
}

class _ClassificationPreviewScreenState extends ConsumerState<ClassificationPreviewScreen> {
  late String _category;

  @override
  void initState() {
    super.initState();
    _category = widget.task.category.isEmpty ? 'Work' : widget.task.category;
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: const Text('Classification Preview'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(children: [
          Expanded(
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 720),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: accent.withOpacity(0.18)),
                      boxShadow: [BoxShadow(color: accent.withOpacity(0.04), blurRadius: 24, spreadRadius: 2)],
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Category', style: TextStyle(color: Colors.white70, fontSize: 14)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _category,
                        items: ['Work', 'Personal', 'Other'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (v) => setState(() => _category = v ?? _category),
                        decoration: const InputDecoration(border: InputBorder.none),
                      ),
                      const SizedBox(height: 16),
                      const Text('Priority', style: TextStyle(color: Colors.white70, fontSize: 14)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(12)),
                        child: Text(widget.task.priority.name, style: const TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(height: 16),
                      if (_entitiesList().isNotEmpty) ...[
                        const Text('Entities', style: TextStyle(color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 8),
                        Wrap(spacing: 8, runSpacing: 8, children: _entitiesList().map((e) => Chip(label: Text(e), backgroundColor: Theme.of(context).cardColor, labelStyle: const TextStyle(color: Colors.white))).toList()),
                        const SizedBox(height: 16),
                      ],
                      if ((widget.task.suggestedActions ?? []).isNotEmpty) ...[
                        const Text('Suggested Actions', style: TextStyle(color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: (widget.task.suggestedActions ?? [])
                              .map(
                                (a) => Chip(
                                  label: Text(a),
                                  backgroundColor: Theme.of(context).cardColor,
                                  labelStyle: const TextStyle(color: Colors.white),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ]),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(side: BorderSide(color: accent.withOpacity(0.9)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Text('Go back', style: TextStyle(color: Colors.white))),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TaskDetailScreen(task: widget.task),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: accent, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: const Text('View Task'),
                ),
              ),
            )
          ])
        ]),
      ),
    );
  }

  List<String> _entitiesList() {
    final map = widget.task.extractedEntities ?? {};
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
}
