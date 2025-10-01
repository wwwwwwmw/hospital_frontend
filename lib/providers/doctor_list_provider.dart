import 'package:flutter/material.dart';
import '../models/doctor.dart';
import '../models/department.dart';
import '../services/api_service.dart';

// SỬA Ở ĐÂY: Đổi tên class
class DoctorListProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Doctor> _doctors = [];
  List<Department> _departments = [];
  String? _selectedDepartmentId;
  Doctor? _selectedDoctor;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Doctor> get doctors => _doctors;
  List<Department> get departments => _departments;
  String? get selectedDepartmentId => _selectedDepartmentId;
  Doctor? get selectedDoctor => _selectedDoctor;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Doctor> get filteredDoctors {
    if (_selectedDepartmentId == null) {
      return _doctors;
    }
    return _doctors.where((doc) => doc.department.id == _selectedDepartmentId).toList();
  }

  void selectDepartment(String? departmentId) {
    _selectedDepartmentId = departmentId;
    notifyListeners();
  }

  Future<void> fetchDataForListScreen() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _apiService.getDoctors(),
        _apiService.getDepartments(),
      ]);
      _doctors = results[0] as List<Doctor>;
      _departments = results[1] as List<Department>;
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchDoctorById(String id) async {
    _isLoading = true;
    _selectedDoctor = null;
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
