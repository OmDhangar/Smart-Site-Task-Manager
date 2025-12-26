import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_todo_app/app.dart';
import 'package:flutter/foundation.dart';

void main() async {
  await dotenv.load(fileName: '.env');

  if (kDebugMode) {
    final baseUrl = dotenv.env['API_BASE_URL'] ?? 'not-set';
    final apiKeySet = (dotenv.env['API_KEY'] ?? '').isNotEmpty;
    debugPrint('Env loaded - API_BASE_URL: $baseUrl, API_KEY set: $apiKeySet');
  }

  runApp(const ProviderScope(child: MyApp()));
}
