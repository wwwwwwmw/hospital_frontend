import 'package:flutter/material.dart';
import '../models/time_slot.dart';
import '../models/shift_info.dart'; // <<< THÊM IMPORT MỚI
import '../services/api_service.dart';
import '../models/appointment.dart';

class AppointmentProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  DateTime _selectedDate = DateTime.now();
  ShiftInfo? _selectedShift; // <<< SỬA: Lưu lại cả ca đã chọn
  List<ShiftInfo> _availableShifts = [];
  bool _isLoadingSlots = false;
  bool _isBooking = false;
  String? _slotsError;
  String? _bookingError;
  List<Appointment> _myAppointments = [];
  bool _isLoadingAppointments = false;
  String? _fetchAppointmentsError;

  DateTime get selectedDate => _selectedDate;
  ShiftInfo? get selectedShift => _selectedShift; // <<< SỬA
  List<ShiftInfo> get availableShifts => _availableShifts;
  bool get isLoadingSlots => _isLoadingSlots;
  bool get isBooking => _isBooking;
  String? get slotsError => _slotsError;
  String? get bookingError => _bookingError;
  List<Appointment> get myAppointments => _myAppointments;
  bool get isLoadingAppointments => _isLoadingAppointments;
  String? get fetchAppointmentsError => _fetchAppointmentsError;

  // --- Methods ---

  void selectDate(DateTime date) {
    _selectedDate = date;
    _selectedShift = null; // <<< SỬA
    _availableShifts = [];
    notifyListeners();
  }

  void selectShift(ShiftInfo shift) { // <<< SỬA
    _selectedShift = shift;
    notifyListeners();
  }

  Future<void> fetchAvailableSlots(String doctorId) async {
    _isLoadingSlots = true;
    _slotsError = null;
    _availableShifts = [];
    notifyListeners();
    try {
      final dateString = _selectedDate.toIso8601String().split('T').first;
      _availableShifts =
          await _apiService.getSlotsByDoctorAndDate(doctorId, dateString);
    } catch (e) {
      _slotsError = e.toString();
    }
    _isLoadingSlots = false;
    notifyListeners();
  }

  Future<bool> createAppointment({
    required String token,
    required String patientId,
    required String doctorId,
  }) async {
    if (_selectedShift == null) {
      _bookingError = 'Vui lòng chọn một ca khám.';
      notifyListeners();
      return false;
    }

    _isBooking = true;
    _bookingError = null;
    notifyListeners();

    try {
      final dateString = _selectedDate.toIso8601String().split('T').first;
      await _apiService.createAppointment(
        token: token,
        patientId: patientId,
        doctorId: doctorId,
        date: dateString,
        shiftStart: _selectedShift!.start, // <<< SỬA
        shiftEnd: _selectedShift!.end,     // <<< SỬA
      );
      
      await fetchMyAppointments(token: token);
      _isBooking = false;
      notifyListeners();
      return true;
    } catch (e) {
      _bookingError = e.toString();
      _isBooking = false;
      notifyListeners();
      return false;
    }
  }

  /// Lấy danh sách lịch hẹn của người dùng đã đăng nhập
  Future<void> fetchMyAppointments({required String token}) async {
    _isLoadingAppointments = true;
    _fetchAppointmentsError = null;
    notifyListeners();

    try {
      _myAppointments = await _apiService.getMyAppointments(token: token);
    } catch (e) {
      _fetchAppointmentsError = e.toString();
    }

    _isLoadingAppointments = false;
    notifyListeners();
  }

  /// Hủy một lịch hẹn
  Future<bool> cancelAppointment(
      {required String token, required String appointmentId}) async {
    _fetchAppointmentsError = null;
    try {
      await _apiService.cancelAppointment(
          token: token, appointmentId: appointmentId);
      await fetchMyAppointments(token: token);
      return true;
    } catch (e) {
      _fetchAppointmentsError = e.toString();
      notifyListeners();
      return false;
    }
  }
}