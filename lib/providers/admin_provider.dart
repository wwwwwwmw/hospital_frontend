import 'package:flutter/material.dart';
import '../models/department.dart';
import '../models/doctor.dart';
import '../models/user.dart';
import '../models/patient.dart';
import '../models/appointment.dart';
import '../services/api_service.dart';

class AdminProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  bool _isLoading = false;
  String? _errorMessage;
  List<Doctor> _allDoctors = [];
  List<User> _allUsers = [];
  List<Department> _allDepartments = [];
  List<Patient> _patientsForSelectedUser = [];
  List<Appointment> _allAppointments = [];
  List<dynamic> _selectedDoctorSchedule = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Doctor> get allDoctors => _allDoctors;
  List<User> get allUsers => _allUsers;
  List<Department> get allDepartments => _allDepartments;
  List<Patient> get patientsForSelectedUser => _patientsForSelectedUser;
  List<Appointment> get allAppointments => _allAppointments;
  List<dynamic> get selectedDoctorSchedule => _selectedDoctorSchedule;

  Future<void> fetchAllDoctors({required String token}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _allDoctors = await _apiService.adminGetAllDoctors(token: token);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllUsers({required String token}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _allUsers = await _apiService.adminGetAllUsers(token: token);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllDepartments({required String token}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _allDepartments = await _apiService.adminGetAllDepartments(token: token);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllAppointments({required String token}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _allAppointments = await _apiService.adminGetAllAppointments(token: token);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPatientsForUser({required String token, required String userId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _patientsForSelectedUser = await _apiService.adminGetPatientsByUser(token: token, userId: userId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteDoctor({required String token, required String doctorId}) async {
    try {
      await _apiService.deleteDoctor(token: token, doctorId: doctorId);
      // Refresh the list after deleting
      await fetchAllDoctors(token: token);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteUser({required String token, required String userId}) async {
    try {
      await _apiService.adminDeleteUser(token: token, userId: userId);
      // Refresh the list after deleting
      await fetchAllUsers(token: token);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateDoctor({required String token, required String doctorId, required Map<String, dynamic> doctorData}) async {
    try {
      await _apiService.updateDoctor(token: token, doctorId: doctorId, doctorData: doctorData);
      // Refresh the list after updating
      await fetchAllDoctors(token: token);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> createDoctor({required String token, required Map<String, dynamic> doctorData}) async {
    try {
      await _apiService.createDoctor(token: token, doctorData: doctorData);
      // Refresh the list after creating
      await fetchAllDoctors(token: token);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateUser({required String token, required String userId, required Map<String, dynamic> userData}) async {
    try {
      await _apiService.adminUpdateUser(token: token, userId: userId, userData: userData);
      // Refresh the list after updating
      await fetchAllUsers(token: token);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateAppointmentStatus({required String token, required String appointmentId, required String status}) async {
    try {
      await _apiService.adminUpdateAppointmentStatus(token: token, appointmentId: appointmentId, status: status);
      // Refresh the list after updating
      await fetchAllAppointments(token: token);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchWeeklyScheduleForDoctor({required String token, required String doctorId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _selectedDoctorSchedule = await _apiService.adminGetWeeklyScheduleForDoctor(token: token, doctorId: doctorId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateWeeklyScheduleForDoctor({required String token, required String doctorId, required Map<int, List<Map<String, dynamic>>> groupedSchedules}) async {
    try {
      // Convert groupedSchedules to the format expected by API
      for (var entry in groupedSchedules.entries) {
        final weekday = entry.key;
        final shifts = entry.value;
        
        // Each entry represents a weekday with its shifts
        final scheduleData = {
          'doctor': doctorId,
          'weekday': weekday,
          'blocks': shifts, // shifts already contain start, end, slotDurationMin, capacityPerSlot
          'isActive': true,
        };
        
        await _apiService.upsertWeeklySchedule(token: token, scheduleData: scheduleData);
      }
      
      // Refresh the schedule after updating
      await fetchWeeklyScheduleForDoctor(token: token, doctorId: doctorId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}