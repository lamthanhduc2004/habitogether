import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String? _id;
  String? _fullName;
  String? _email;
  String? _avatar;
  bool _isLoading = false;
  String? _error;

  // Getters
  String? get id => _id;
  String? get fullName => _fullName;
  String? get email => _email;
  String? get avatar => _avatar;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Set user data
  void setUserData({
    required String id,
    required String fullName,
    required String email,
    String? avatar,
  }) {
    _id = id;
    _fullName = fullName;
    _email = email;
    _avatar = avatar;
    notifyListeners();
  }

  // Clear user data (logout)
  void clearUserData() {
    _id = null;
    _fullName = null;
    _email = null;
    _avatar = null;
    notifyListeners();
  }

  // Set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error
  void setError(String? error) {
    _error = error;
    notifyListeners();
  }
} 