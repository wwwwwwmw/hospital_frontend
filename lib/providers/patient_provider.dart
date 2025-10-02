import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/patient.dart';

class PatientProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Patient> _myPatients = [];
  List<Patient> get myPatients => _myPatients;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Lấy danh sách tất cả bệnh nhân được bảo hộ bởi người dùng
  Future<void> fetchMyPatients(String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _myPatients = await _apiService.getMyPatients(token: token);
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Tạo một hồ sơ bệnh nhân mới
  Future<bool> createPatient({required String token, required Map<String, dynamic> patientData}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      // API trả về bệnh nhân vừa tạo
      final newPatient = await _apiService.createPatient(token: token, patientData: patientData);
      // Thêm bệnh nhân mới vào danh sách hiện tại
      _myPatients.add(newPatient);
      _isLoading = false;
      notifyListeners(); // Thông báo cho UI cập nhật
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Cập nhật thông tin hồ sơ bệnh nhân
  Future<bool> updatePatient({required String token, required String patientId, required Map<String, dynamic> patientData}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      // API trả về bệnh nhân vừa cập nhật
      final updatedPatient = await _apiService.updatePatient(token: token, patientId: patientId, patientData: patientData);
      // Tìm và thay thế bệnh nhân trong danh sách hiện tại
      final index = _myPatients.indexWhere((p) => p.id == patientId);
      if (index != -1) {
        _myPatients[index] = updatedPatient;
      }
      _isLoading = false;
      notifyListeners(); // Thông báo cho UI cập nhật
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Xóa một hồ sơ bệnh nhân
  Future<bool> deletePatient({required String token, required String patientId}) async {
    _errorMessage = null;
    try {
      await _apiService.deletePatient(token: token, patientId: patientId);
      _myPatients.removeWhere((p) => p.id == patientId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}