import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/meal.dart';
import '../services/api_exception.dart';
import '../services/meal_api_handler.dart';

class DetailScreen extends StatefulWidget {
  final String mealId;

  const DetailScreen({super.key, required this.mealId});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final MealApiHandler _apiHandler = MealApiHandler();
  late Future<Meal> _mealFuture;

  @override
  void initState() {
    super.initState();
    _mealFuture = _apiHandler.fetchMealById(widget.mealId);
  }

  void _retry() {
    if (mounted) {
      setState(() {
        _mealFuture = _apiHandler.fetchMealById(widget.mealId);
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

  String _normalizeYoutubeUrl(String url) {
    final shortsRegex = RegExp(r'youtube\.com\/shorts\/([a-zA-Z0-9_-]+)');
    final match = shortsRegex.firstMatch(url);
    if (match != null) {
      return 'https://www.youtube.com/watch?v=${match.group(1)}';
    }
    return url;
  }

  Future<void> _launchYoutube(String url) async {
    if (url.trim().isEmpty) {
      debugPrint('YouTube URL is empty');
      return;
    }

    final normalizedUrl = _normalizeYoutubeUrl(url.trim());
    debugPrint('Attempting to launch: $normalizedUrl');

    final uri = Uri.tryParse(normalizedUrl);
    if (uri == null) {
      debugPrint('Invalid URL: $normalizedUrl');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid YouTube URL')),
        );
      }
      return;
    }

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        debugPrint('launchUrl returned false for: $normalizedUrl');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open YouTube')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open YouTube')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Details'),
        centerTitle: true,
      ),
      body: FutureBuilder<Meal>(
        future: _mealFuture,
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
          if (!snapshot.hasData) {
            return const Center(
              child: Text(
                'Meal not found',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          // State 4: Data loaded
          final meal = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Meal Image
                Image.network(
                  meal.strMealThumb,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox(
                      height: 250,
                      child: Center(child: Icon(Icons.broken_image, size: 48)),
                    );
                  },
                ),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Meal Name
                      Text(
                        meal.strMeal,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Category and Area
                      Row(
                        children: [
                          if (meal.strCategory != null) ...[
                            const Icon(Icons.category, size: 18, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              meal.strCategory!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                          if (meal.strArea != null) ...[
                            const Icon(Icons.public, size: 18, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              meal.strArea!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Ingredients Section
                      if (meal.ingredients.isNotEmpty) ...[
                        const Text(
                          'Ingredients',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...meal.ingredients.map(
                          (ingredient) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Row(
                              children: [
                                const Text('• ', style: TextStyle(fontSize: 16)),
                                Expanded(
                                  child: Text(
                                    ingredient,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Instructions Section
                      if (meal.strInstructions != null) ...[
                        const Text(
                          'Instructions',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          meal.strInstructions!,
                          style: const TextStyle(fontSize: 16, height: 1.5),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // YouTube Button
                      if (meal.strYoutube != null &&
                          meal.strYoutube!.isNotEmpty)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _launchYoutube(meal.strYoutube!),
                            icon: const Icon(Icons.play_circle_fill),
                            label: const Text('Watch on YouTube'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
