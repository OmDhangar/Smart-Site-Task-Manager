import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_todo_app/features/tasks/data/models/task_preview.dart';
import 'package:flutter_riverpod_todo_app/features/tasks/presentation/task_detail_screen.dart';
import 'package:flutter_riverpod_todo_app/providers/task_provider.dart';

class ClassificationPreviewScreen extends ConsumerWidget {
  final TaskPreview preview;
  final String originalText;

  const ClassificationPreviewScreen({super.key, required this.preview, required this.originalText});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: const Text('Classification Preview'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: _buildGlassmorphicCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Category', style: const TextStyle(color: Colors.white70, fontSize: 16)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16161A),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(preview.category, style: const TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(height: 16),
                    Text('Priority', style: const TextStyle(color: Colors.white70, fontSize: 16)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16161A),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(preview.priority, style: const TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(height: 16),
                    _buildChipsSection('Entities', [
                      ...preview.entities.dates,
                      ...preview.entities.people,
                      ...preview.entities.locations,
                      ...preview.entities.topics,
                    ].where((e) => e.isNotEmpty).toList()),
                    const SizedBox(height: 16),
                    _buildChipsSection('Suggested Actions', preview.suggestedActions),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFF22D4A7)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Go back', style: TextStyle(color: Color(0xFF22D4A7))),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      // Create the task using the notifier which updates the list state
                      final created = await ref.read(tasksProvider.notifier).createTask(originalText, confirm: true);
                      if (created != null) {
                        if (context.mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => TaskDetailScreen(task: created)),
                          );
                        }
                      } else {
                        // show error
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to create task')));
                      }
                    },
                     style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Confirm & Save'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildGlassmorphicCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildChipsSection(String title, List<String> chips) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white70, fontSize: 16)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: chips.map((chip) {
            return Chip(
              label: Text(chip),
              backgroundColor: const Color(0xFF16161A),
              labelStyle: const TextStyle(color: Colors.white),
            );
          }).toList(),
        ),
      ],
    );
  }
}
