import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/meal.dart';
import '../models/meal_category.dart';
import 'api_exception.dart';

class MealApiHandler {
  final String _baseUrl = "www.themealdb.com";
  final Duration _timeout = const Duration(seconds: 10);
  final Map<String, String> _headers = {
    "Content-Type": "application/json",
    "Accept": "application/json",
  };

  void _checkResponse(http.Response response) {
    if (response.statusCode != 200) {
      throw ApiException(
        "Request failed with status: ${response.statusCode}",
        response.statusCode,
      );
    }
  }

  Future<List<MealCategory>> fetchCategories() async {
    try {
      final uri = Uri.https(_baseUrl, '/api/json/v1/1/categories.php');
      final response = await http
          .get(uri, headers: _headers)
          .timeout(_timeout);

      _checkResponse(response);

      final Map<String, dynamic> data =
          json.decode(response.body) as Map<String, dynamic>;
      final List<dynamic> categories = data['categories'] as List<dynamic>;

      return categories
          .map((json) =>
              MealCategory.fromJson(json as Map<String, dynamic>))
          .toList();
    } on SocketException {
      throw Exception("No internet connection");
    } on TimeoutException {
      throw Exception("Request timed out");
    } on FormatException {
      throw Exception("Unexpected data format");
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception("An unexpected error occurred: $e");
    }
  }

  Future<List<Meal>> fetchMealsByCategory(String category) async {
    try {
      final uri = Uri.https(
        _baseUrl,
        '/api/json/v1/1/filter.php',
        {'c': category},
      );
      final response = await http
          .get(uri, headers: _headers)
          .timeout(_timeout);

      _checkResponse(response);

      final Map<String, dynamic> data =
          json.decode(response.body) as Map<String, dynamic>;
      final List<dynamic> meals = data['meals'] as List<dynamic>;

      return meals
          .map((json) => Meal.fromJson(json as Map<String, dynamic>))
          .toList();
    } on SocketException {
      throw Exception("No internet connection");
    } on TimeoutException {
      throw Exception("Request timed out");
    } on FormatException {
      throw Exception("Unexpected data format");
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception("An unexpected error occurred: $e");
    }
  }

  Future<Meal> fetchMealById(String id) async {
    try {
      final uri = Uri.https(
        _baseUrl,
        '/api/json/v1/1/lookup.php',
        {'i': id},
      );
      final response = await http
          .get(uri, headers: _headers)
          .timeout(_timeout);

      _checkResponse(response);

      final Map<String, dynamic> data =
          json.decode(response.body) as Map<String, dynamic>;
      final List<dynamic> meals = data['meals'] as List<dynamic>;

      return Meal.fromJson(meals.first as Map<String, dynamic>);
    } on SocketException {
      throw Exception("No internet connection");
    } on TimeoutException {
      throw Exception("Request timed out");
    } on FormatException {
      throw Exception("Unexpected data format");
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception("An unexpected error occurred: $e");
    }
  }
}
