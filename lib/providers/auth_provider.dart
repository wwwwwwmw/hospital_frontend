import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert'; // Import for jsonEncode
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final _storage = const FlutterSecureStorage();

  String? _token;
  Map<String, dynamic>? _user;
  bool _isLoading = false;
  String? _errorMessage;

  String? get token => _token;
  Map<String, dynamic>? get user => _user;
  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isAdmin => _user != null && (_user!['role'] == 'admin');
  bool get isStaff => _user != null && (_user!['role'] == 'staff');

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final authResponse =
          await _apiService.login(email: email, password: password);
      _token = authResponse.token;
      _user = authResponse.user;
      
      await _storage.write(key: 'authToken', value: _token);
      await _storage.write(key: 'user', value: jsonEncode(_user));

    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> register(String fullName, String email, String password) async {
     _isLoading = true;
    _errorMessage = null;
    notifyListeners();
     try {
       final authResponse = await _apiService.register(fullName: fullName, email: email, password: password);
       _token = authResponse.token;
       _user = authResponse.user;
       await _storage.write(key: 'authToken', value: _token);
       await _storage.write(key: 'user', value: jsonEncode(_user));

     } catch (e) {
       _errorMessage = e.toString();
     }
      _isLoading = false;
      notifyListeners();
  }

  Future<void> tryAutoLogin() async {
    final storedToken = await _storage.read(key: 'authToken');
    final storedUser = await _storage.read(key: 'user');
    if (storedToken != null) {
      _token = storedToken;
      if (storedUser != null) {
        _user = jsonDecode(storedUser);
      }
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    await _storage.deleteAll();
    notifyListeners();
  }

  // SỬA Ở ĐÂY: Thêm 'required' để định nghĩa tham số được đặt tên
   Future<bool> changePassword({required String oldPassword, required String newPassword}) async {
    if (_token == null) {
      _errorMessage = "Bạn chưa đăng nhập.";
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.changePassword(
        token: _token!,
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}

