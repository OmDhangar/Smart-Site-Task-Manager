import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_todo_app/core/theme/app_theme.dart';

class FlutterRiverpodTodoApp extends ConsumerWidget {
  const FlutterRiverpodTodoApp({super.key});

  static final routesProvider = Provider<RouterConfig<Object>?>((ref) => null);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final route = ref.watch(routesProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: route,
    );
  }
}
