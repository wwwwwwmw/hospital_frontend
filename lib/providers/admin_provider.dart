import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/doctor.dart';
import '../models/patient.dart';
import '../models/department.dart'; // Import model mới

class AdminProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  // Trạng thái cho việc quản lý bác sĩ
  List<Doctor> _allDoctors = [];
  List<Doctor> get allDoctors => _allDoctors;

  // Trạng thái cho việc quản lý bệnh nhân
  List<Patient> _allPatients = [];
  List<Patient> get allPatients => _allPatients;
  
  // Trạng thái cho việc quản lý Khoa (Mới)
  List<Department> _allDepartments = [];
  List<Department> get allDepartments => _allDepartments;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // --- Doctor Management ---
  Future<void> fetchAllDoctors(String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allDoctors = await _apiService.adminGetAllDoctors(token: token);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createDoctor(String token, Map<String, dynamic> doctorData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.createDoctor(token: token, doctorData: doctorData);
      await fetchAllDoctors(token);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateDoctor(
      String token, String doctorId, Map<String, dynamic> doctorData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.updateDoctor(
          token: token, doctorId: doctorId, doctorData: doctorData);
      await fetchAllDoctors(token);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteDoctor(String token, String doctorId) async {
    _errorMessage = null;
    try {
      await _apiService.deleteDoctor(token: token, doctorId: doctorId);
      _allDoctors.removeWhere((doc) => doc.id == doctorId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // --- Patient Management ---
  Future<void> fetchAllPatients(String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allPatients = await _apiService.adminGetAllPatients(token: token);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // --- Department Management (Mới) ---
  Future<void> fetchAllDepartments(String token) async {
    // Không cần set isLoading vì thường tải cùng lúc với màn hình
    _errorMessage = null;
    try {
      _allDepartments = await _apiService.adminGetAllDepartments(token: token);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}

