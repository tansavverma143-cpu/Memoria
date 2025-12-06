import 'package:flutter/material.dart';
import 'package:memoria/models/user_model.dart';
import 'package:memoria/services/storage_service.dart';

class AppProvider extends ChangeNotifier {
  User? _currentUser;
  UserSettings _userSettings = UserSettings();
  bool _isDarkMode = true;
  bool _isLoading = false;
  String _currentScreen = '/';
  
  User? get currentUser => _currentUser;
  UserSettings get userSettings => _userSettings;
  bool get isDarkMode => _isDarkMode;
  bool get isLoading => _isLoading;
  String get currentScreen => _currentScreen;
  String get userName => _currentUser?.displayName ?? _currentUser?.email?.split('@').first ?? 'User';
  
  AppProvider() {
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    _userSettings = StorageService.getSettings();
    _isDarkMode = _userSettings.isDarkMode;
    _currentUser = StorageService.getCurrentUser();
    notifyListeners();
  }
  
  Future<void> setUser(User user) async {
    _currentUser = user;
    await StorageService.saveUser(user);
    notifyListeners();
  }
  
  Future<void> updateSettings(UserSettings settings) async {
    _userSettings = settings;
    _isDarkMode = settings.isDarkMode;
    await StorageService.saveSettings(settings);
    notifyListeners();
  }
  
  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    _userSettings.isDarkMode = _isDarkMode;
    StorageService.saveSettings(_userSettings);
    notifyListeners();
  }
  
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void setCurrentScreen(String screen) {
    _currentScreen = screen;
    notifyListeners();
  }
  
  Future<void> logout() async {
    _currentUser = null;
    await StorageService.clearUser();
    notifyListeners();
  }
}