import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/doctor.dart';
import '../models/patient.dart';
import '../models/appointment.dart';
import '../models/department.dart';
import '../models/user.dart';
import '../models/doctor_schedule.dart'; // <<< THÊM IMPORT MỚI

class AdminProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  // State variables
  List<Doctor> _allDoctors = [];
  List<Patient> _allPatients = [];
  List<Appointment> _allAppointments = [];
  List<Department> _allDepartments = [];
  List<User> _allUsers = [];
  List<Patient> _patientsForSelectedUser = [];

  // === STATE MỚI CHO QUẢN LÝ LỊCH ===
  List<DoctorSchedule> _selectedDoctorSchedule = [];

  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Doctor> get allDoctors => _allDoctors;
  List<Patient> get allPatients => _allPatients;
  List<Appointment> get allAppointments => _allAppointments;
  List<Department> get allDepartments => _allDepartments;
  List<User> get allUsers => _allUsers;
  List<Patient> get patientsForSelectedUser => _patientsForSelectedUser;
  
  // === GETTER MỚI ===
  List<DoctorSchedule> get selectedDoctorSchedule => _selectedDoctorSchedule;
  
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

  Future<bool> updateDoctor(
      {required String token, required String doctorId, required Map<String, dynamic> doctorData}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _apiService.updateDoctor(
          token: token, doctorId: doctorId, doctorData: doctorData);
      await fetchAllDoctors(token: token); // Refresh list
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

  // === CÁC HÀM MỚI CHO QUẢN LÝ LỊCH ===
  
  Future<void> fetchWeeklyScheduleForDoctor({
    required String token,
    required String doctorId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _selectedDoctorSchedule = []; // Xóa dữ liệu cũ khi chọn bác sĩ mới
    notifyListeners();
    try {
      _selectedDoctorSchedule = await _apiService.adminGetWeeklyScheduleForDoctor(
        token: token,
        doctorId: doctorId,
      );
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateWeeklyScheduleForDoctor({
    required String token,
    required String doctorId,
    required Map<int, List<Map<String, dynamic>>> groupedSchedules,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Gửi request cho từng ngày trong tuần
      for (var entry in groupedSchedules.entries) {
        final weekday = entry.key;
        final blocks = entry.value;

        final scheduleData = {
          'doctor': doctorId, // Admin gửi doctorId trong body
          'weekday': weekday,
          'blocks': blocks,
          'isActive': blocks.isNotEmpty,
        };

        await _apiService.upsertWeeklySchedule(
          token: token,
          scheduleData: scheduleData,
        );
      }
      
      // Tải lại lịch sau khi cập nhật thành công
      await fetchWeeklyScheduleForDoctor(token: token, doctorId: doctorId);
      
      return true; // Trả về true ngay, không cần set isLoading nữa vì fetch đã làm
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  

  

  // --- User Management ---
  Future<void> fetchAllUsers({required String token}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _allUsers = await _apiService.adminGetAllUsers(token: token);
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

   Future<bool> updateUser({required String token, required String userId, required Map<String, dynamic> userData}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _apiService.adminUpdateUser(token: token, userId: userId, userData: userData);
      await fetchAllUsers(token: token); // Refresh list
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

  Future<bool> deleteUser({required String token, required String userId}) async {
    _errorMessage = null;
    try {
      await _apiService.adminDeleteUser(token: token, userId: userId);
      _allUsers.removeWhere((u) => u.id == userId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchPatientsForUser({required String token, required String userId}) async {
     _isLoading = true;
    _errorMessage = null;
    _patientsForSelectedUser = []; // Clear old data
    notifyListeners();
    try {
      _patientsForSelectedUser = await _apiService.adminGetPatientsForUser(token: token, userId: userId);
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

  Future<bool> updateDepartment({required String token, required String departmentId, required Map<String, dynamic> departmentData}) async {
     _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _apiService.updateDepartment(token: token, departmentId: departmentId, departmentData: departmentData);
      await fetchAllDepartments(token: token); // Refresh list
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