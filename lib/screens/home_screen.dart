import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../models/meal_category.dart';
import '../services/api_exception.dart';
import '../services/meal_api_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MealApiHandler _apiHandler = MealApiHandler();
  late Future<List<MealCategory>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _apiHandler.fetchCategories();
  }

  void _retry() {
    if (mounted) {
      setState(() {
        _categoriesFuture = _apiHandler.fetchCategories();
      });
    }
  }

  String _getErrorMessage(Object error) {
    if (error is SocketException) {
      return "No internet connection";
    } else if (error is TimeoutException) {
      return "Request timed out";
    } else if (error is ApiException) {
      return "${error.message} (Status: ${error.statusCode})";
    } else {
      return "Unexpected error occurred";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Browser'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<MealCategory>>(
        future: _categoriesFuture,
        builder: (context, snapshot) {
          // State 1: Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // State 2: Error
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      _getErrorMessage(snapshot.error!),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _retry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          // State 3: No data
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No categories found',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          // State 4: Data loaded
          final categories = snapshot.data!;
          return ListView.builder(
            itemCount: categories.length,
            padding: const EdgeInsets.all(8.0),
            itemBuilder: (context, index) {
              final category = categories[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      category.strCategoryThumb,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const SizedBox(
                          width: 56,
                          height: 56,
                          child: Icon(Icons.broken_image),
                        );
                      },
                    ),
                  ),
                  title: Text(
                    category.strCategory,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
