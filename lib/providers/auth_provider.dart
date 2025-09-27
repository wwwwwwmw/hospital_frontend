import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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

  /// Xử lý đăng nhập
  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final authResponse =
          await _apiService.login(email: email, password: password);
      _token = authResponse.token;
      _user = authResponse.user;
      
      // Lưu token vào storage an toàn
      await _storage.write(key: 'authToken', value: _token);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Xử lý đăng ký
  Future<void> register(String fullName, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Backend mới sẽ tự động đăng nhập sau khi đăng ký
      final authResponse = await _apiService.register(
          fullName: fullName, email: email, password: password);
      _token = authResponse.token;
      _user = authResponse.user;

      // Lưu token vào storage
      await _storage.write(key: 'authToken', value: _token);
    } catch (e) {
      _errorMessage = e.toString();
    }
    
    _isLoading = false;
    notifyListeners();
  }

  /// Xử lý đổi mật khẩu
  Future<bool> changePassword({required String oldPassword, required String newPassword}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    bool success = false;
    try {
      await _apiService.changePassword(
        token: _token!, // Cần token để xác thực
        oldPassword: oldPassword, 
        newPassword: newPassword
      );
      success = true;
    } catch (e) {
      _errorMessage = e.toString();
      success = false;
    }

    _isLoading = false;
    notifyListeners();
    return success;
  }

  /// Kiểm tra xem có token đã lưu không để tự động đăng nhập
  Future<void> tryAutoLogin() async {
    final storedToken = await _storage.read(key: 'authToken');
    if (storedToken != null) {
      _token = storedToken;
      // Trong ứng dụng thực tế, bạn nên có một API để xác thực token
      // và lấy lại thông tin người dùng ở đây.
      // Ví dụ: _user = await _apiService.getMe(_token!);
      notifyListeners();
    }
  }

  /// Xử lý đăng xuất
  Future<void> logout() async {
    _token = null;
    _user = null;
    await _storage.delete(key: 'authToken');
    notifyListeners();
  }
}

