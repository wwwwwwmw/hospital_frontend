import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/patient.dart';

class PatientProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  // Trạng thái lưu trữ thông tin bệnh nhân của người dùng hiện tại
  Patient? _myProfile;
  Patient? get myProfile => _myProfile;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Lấy thông tin hồ sơ bệnh nhân của người dùng đang đăng nhập
  Future<void> fetchMyPatientProfile(String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _myProfile = await _apiService.getMyPatientProfile(token: token);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Cập nhật thông tin hồ sơ bệnh nhân
  Future<bool> updateMyPatientProfile(
      String token, Map<String, dynamic> patientData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // API service sẽ trả về patient profile đã được cập nhật
      final updatedProfile = await _apiService.updateMyPatientProfile(
          token: token, patientData: patientData);
      _myProfile = updatedProfile;
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
