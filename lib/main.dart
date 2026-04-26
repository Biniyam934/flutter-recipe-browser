import 'package:flutter/material.dart';

import 'services/meal_api_handler.dart';

void main() {
  runApp(const MyApp());
  testApi();
}

Future<void> testApi() async {
  final apiHandler = MealApiHandler();

  try {
    debugPrint('--- Fetching Categories ---');
    final categories = await apiHandler.fetchCategories();
    for (final category in categories) {
      debugPrint(
        'Category: ${category.strCategory} (ID: ${category.idCategory})',
      );
    }
    debugPrint('Total categories: ${categories.length}');
  } catch (e) {
    debugPrint('Error fetching categories: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(child: Text('Recipe Browser App')),
      ),
    );
  }
}