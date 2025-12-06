import 'package:flutter/material.dart';
import 'package:memoria/models/user_model.dart';
import 'package:memoria/services/storage_service.dart';

class UserProvider extends ChangeNotifier {
  User? _currentUser;
  UserSettings _settings = UserSettings();
  bool _isAuthenticated = false;
  
  User? get currentUser => _currentUser;
  UserSettings get settings => _settings;
  bool get isAuthenticated => _isAuthenticated;
  
  UserProvider() {
    _loadUser();
  }
  
  Future<void> _loadUser() async {
    final user = StorageService.getCurrentUser();
    if (user != null) {
      _currentUser = user;
      _isAuthenticated = true;
      _settings = StorageService.getSettings();
    }
    notifyListeners();
  }
  
  Future<void> login(User user) async {
    _currentUser = user;
    _isAuthenticated = true;
    await StorageService.saveUser(user);
    notifyListeners();
  }
  
  Future<void> register(User user) async {
    _currentUser = user;
    _isAuthenticated = true;
    await StorageService.saveUser(user);
    notifyListeners();
  }
  
  Future<void> updateProfile({
    String? displayName,
    String? profileImage,
  }) async {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        displayName: displayName ?? _currentUser!.displayName,
        profileImage: profileImage ?? _currentUser!.profileImage,
        lastLogin: DateTime.now(),
      );
      await StorageService.saveUser(_currentUser!);
      notifyListeners();
    }
  }
  
  Future<void> updateSettings(UserSettings newSettings) async {
    _settings = newSettings;
    await StorageService.saveSettings(newSettings);
    notifyListeners();
  }
  
  Future<void> logout() async {
    _currentUser = null;
    _isAuthenticated = false;
    await StorageService.clearUser();
    notifyListeners();
  }
  
  bool isFirstTimeUser() {
    return _currentUser == null;
  }
}