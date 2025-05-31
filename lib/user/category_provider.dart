import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/service.dart';

class CategoryProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Category> _categories = [];

  List<Category> get categories => _categories;

  Future<void> loadCategories() async {
    try {
      _categories = await _apiService.fetchCategories();
      notifyListeners(); 
    } catch (e) {
      debugPrint('Error loading categories in Provider: $e'); // [cite: 591]
      _categories = []; // Ensure categories list is empty on error
      notifyListeners();
      // Optionally, rethrow or set an error state for the UI
    }
  }
}