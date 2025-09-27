// lib/providers/doctor_provider.dart

import 'package:flutter/material.dart';
import '../models/doctor.dart';
import '../services/api_service.dart';

class DoctorProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  // Trạng thái cho danh sách bác sĩ
  List<Doctor> _doctors = [];
  List<Doctor> get doctors => _doctors;

  // Trạng thái cho một bác sĩ được chọn (dùng cho màn hình chi tiết)
  Doctor? _selectedDoctor;
  Doctor? get selectedDoctor => _selectedDoctor;

  // Trạng thái loading chung
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  // Trạng thái lỗi
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Hàm để lấy danh sách tất cả bác sĩ
  Future<void> fetchDoctors() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Báo cho UI biết là đang bắt đầu loading

    try {
      _doctors = await _apiService.getDoctors();
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners(); // Báo cho UI biết đã load xong (dù thành công hay thất bại)
  }

  /// Hàm để lấy thông tin chi tiết của một bác sĩ
  Future<void> fetchDoctorById(String id) async {
    _isLoading = true;
    _selectedDoctor = null; // Xóa dữ liệu cũ để tránh hiển thị sai
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedDoctor = await _apiService.getDoctorById(id);
    } catch (e) {
      _errorMessage = e.toString();
    }
    
    _isLoading = false;
    notifyListeners();
  }
}