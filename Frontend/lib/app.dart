
import 'package:flutter/material.dart';
import 'package:flutter_riverpod_todo_app/screens/home_screen.dart';
import 'package:flutter_riverpod_todo_app/core/theme/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: AppTheme.dark,
      home: const HomeScreen(),
    );
  }
}
