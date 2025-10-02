import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../services/api_service.dart';

// Enum để định nghĩa các trạng thái xác thực
enum AuthStatus { uninitialized, authenticated, unauthenticated }

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final _storage = const FlutterSecureStorage();

  String? _token;
  Map<String, dynamic>? _user;
  AuthStatus _status = AuthStatus.uninitialized;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  String? get token => _token;
  Map<String, dynamic>? get user => _user;
  AuthStatus get status => _status;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Getters kiểm tra vai trò
  bool get isAdmin => _user != null && (_user!['role'] == 'admin');
  bool get isStaff => _user != null && (_user!['role'] == 'staff');
  bool get isDoctor => _user != null && (_user!['role'] == 'doctor'); // Bổ sung getter còn thiếu

  AuthProvider() {
    tryAutoLogin();
  }

  Future<void> tryAutoLogin() async {
    final storedToken = await _storage.read(key: 'authToken');
    final storedUser = await _storage.read(key: 'user');

    if (storedToken != null) {
      _token = storedToken;
      if (storedUser != null) {
        try {
          _user = jsonDecode(storedUser);
        } catch (e) {
          // Nếu dữ liệu user bị lỗi, đăng xuất để đảm bảo an toàn
          await logout();
          return;
        }
      }
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final authResponse = await _apiService.login(email: email, password: password);
      _token = authResponse.token;
      _user = authResponse.user;
      
      await _storage.write(key: 'authToken', value: _token);
      await _storage.write(key: 'user', value: jsonEncode(_user));
      
      _status = AuthStatus.authenticated;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStatus.unauthenticated;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String fullName, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
       final authResponse = await _apiService.register(fullName: fullName, email: email, password: password);
       _token = authResponse.token;
       _user = authResponse.user;
       await _storage.write(key: 'authToken', value: _token);
       await _storage.write(key: 'user', value: jsonEncode(_user));
       _status = AuthStatus.authenticated;
       _isLoading = false;
       notifyListeners();
       return true;
     } catch (e) {
       _errorMessage = e.toString();
       _status = AuthStatus.unauthenticated;
       _isLoading = false;
       notifyListeners();
       return false;
     }
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    _status = AuthStatus.unauthenticated;
    await _storage.deleteAll();
    notifyListeners();
  }
  
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
  Future<bool> updateProfile({required String fullName}) async {
    if (_token == null) {
      _errorMessage = "Phiên đăng nhập đã hết hạn.";
      notifyListeners();
      return false;
    }

    _errorMessage = null;
    notifyListeners();

    try {
      // Giả định bạn sẽ thêm hàm updateMyProfile vào ApiService
      final updatedUser = await _apiService.updateMyProfile(
        token: _token!,
        fullName: fullName,
      );
      
      // Cập nhật lại thông tin user trong provider
      _user = updatedUser; 
      notifyListeners();
      return true;

    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}

