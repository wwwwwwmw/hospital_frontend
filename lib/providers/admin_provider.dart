
import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../models/doctor.dart';
import '../models/patient.dart';
import '../models/appointment.dart';
import '../models/department.dart';

class AdminProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  // State variables
  List<Doctor> _allDoctors = [];
  List<Patient> _allPatients = [];
  List<Appointment> _allAppointments = [];
  List<Department> _allDepartments = [];

  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Doctor> get allDoctors => _allDoctors;
  List<Patient> get allPatients => _allPatients;
  List<Appointment> get allAppointments => _allAppointments;
  List<Department> get allDepartments => _allDepartments;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // --- Doctor Management ---
  Future<void> fetchAllDoctors({required String token}) async {
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

  Future<bool> createDoctor({required String token, required Map<String, dynamic> doctorData}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _apiService.createDoctor(token: token, doctorData: doctorData);
      await fetchAllDoctors(token: token); // Refresh list
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateDoctor(
      {required String token, required String doctorId, required Map<String, dynamic> doctorData}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _apiService.updateDoctor(
          token: token, doctorId: doctorId, doctorData: doctorData);
      await fetchAllDoctors(token: token); // Refresh list
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteDoctor({required String token, required String doctorId}) async {
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
  Future<void> fetchAllPatients({required String token}) async {
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

  // --- Appointment Management ---
  Future<void> fetchAllAppointments({required String token}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _allAppointments = await _apiService.adminGetAllAppointments(token: token);
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateAppointmentStatus({required String token, required String appointmentId, required String status}) async {
     try {
      await _apiService.adminUpdateAppointmentStatus(token: token, appointmentId: appointmentId, status: status);
      // Update status on the UI
      final index = _allAppointments.indexWhere((app) => app.id == appointmentId);
      if (index != -1) {
        final oldAppointment = _allAppointments[index];
        _allAppointments[index] = Appointment(
          id: oldAppointment.id,
          doctor: oldAppointment.doctor,
          patient: oldAppointment.patient,
          startTime: oldAppointment.startTime,
          status: status, // New status
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // --- Department Management ---
  Future<void> fetchAllDepartments({required String token}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _allDepartments = await _apiService.adminGetAllDepartments(token: token);
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createDepartment({required String token, required Map<String, dynamic> departmentData}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _apiService.createDepartment(token: token, departmentData: departmentData);
      await fetchAllDepartments(token: token); // Refresh list
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateDepartment({required String token, required String departmentId, required Map<String, dynamic> departmentData}) async {
     _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _apiService.updateDepartment(token: token, departmentId: departmentId, departmentData: departmentData);
      await fetchAllDepartments(token: token); // Refresh list
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteDepartment({required String token, required String departmentId}) async {
     _errorMessage = null;
    try {
      await _apiService.deleteDepartment(token: token, departmentId: departmentId);
      _allDepartments.removeWhere((dept) => dept.id == departmentId);
      notifyListeners();
      return true;
    } catch (e) {
       _errorMessage = e.toString();
       notifyListeners();
      return false;
    }
  }
}

