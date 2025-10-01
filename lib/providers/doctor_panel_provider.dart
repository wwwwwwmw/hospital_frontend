import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/appointment.dart';

class DoctorPanelProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Appointment> _myAppointments = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Appointment> get myAppointments => _myAppointments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Lấy danh sách lịch hẹn của bác sĩ đã đăng nhập
  Future<void> fetchMyAppointments({required String token}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _myAppointments = await _apiService.getMyAppointmentsForDoctor(token: token);
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  /// BỔ SUNG HÀM CÒN THIẾU: Đăng ký lịch làm việc mới
  Future<bool> registerSchedule({required String token, required List<Map<String, dynamic>> schedules}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _apiService.registerDoctorSchedule(token: token, schedules: schedules);
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

