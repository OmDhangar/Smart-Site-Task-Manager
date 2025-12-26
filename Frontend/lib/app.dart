
import 'package:flutter/material.dart';
import 'package:flutter_riverpod_todo_app/features/tasks/presentation/home_screen.dart'
    as tasks_home;
import 'package:flutter_riverpod_todo_app/core/theme/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: AppTheme.dark,
      home: const tasks_home.HomeScreen(),
    );
  }
}
