import 'package:flutter/material.dart';
import '../models/homepage_config.dart';
import '../services/homepage_service.dart';

class HomepageProvider with ChangeNotifier {
  HomepageConfig? _config;
  bool _isLoading = false;
  String? _errorMessage;

  HomepageConfig? get config => _config;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetch dynamic, persona-driven homepage configuration from backend APIs
  Future<void> fetchHomepage() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _config = await HomepageService.fetchHomepageConfig();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _config = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Helper to trigger retry upon network or server errors
  Future<void> retryFetch() async {
    await fetchHomepage();
  }
}
