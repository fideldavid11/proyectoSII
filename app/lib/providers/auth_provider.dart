import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  String? _authToken;
  bool _isLoggedIn = false;

  String? get authToken => _authToken;
  bool get isLoggedIn => _isLoggedIn;

  // Verificar el estado de autenticación
  Future<void> checkAuthStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    _authToken = prefs.getString('authToken');
    notifyListeners();
  }

  // Realizar login
  Future<void> login(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('authToken', token);
    _authToken = token;
    _isLoggedIn = true;
    notifyListeners();
  }

  // Realizar logout
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('authToken');
    _authToken = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}
