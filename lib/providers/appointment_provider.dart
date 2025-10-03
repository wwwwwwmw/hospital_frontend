import 'package:flutter/material.dart';

import '../models/appointment.dart';
import '../models/shift_info.dart';
import '../services/api_service.dart';

class AppointmentProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  DateTime _selectedDate = DateTime.now();
  ShiftInfo? _selectedShift;
  List<ShiftInfo> _availableShifts = [];
  bool _isLoadingSlots = false;
  bool _isBooking = false;
  String? _slotsError;
  String? _bookingError;
  List<Appointment> _myAppointments = [];
  bool _isLoadingAppointments = false;
  String? _fetchAppointmentsError;

  DateTime get selectedDate => _selectedDate;
  ShiftInfo? get selectedShift => _selectedShift;
  List<ShiftInfo> get availableShifts => _availableShifts;
  bool get isLoadingSlots => _isLoadingSlots;
  bool get isBooking => _isBooking;
  String? get slotsError => _slotsError;
  String? get bookingError => _bookingError;
  List<Appointment> get myAppointments => _myAppointments;
  bool get isLoadingAppointments => _isLoadingAppointments;
  String? get fetchAppointmentsError => _fetchAppointmentsError;

  void selectDate(DateTime date) {
    _selectedDate = date;
    _selectedShift = null; // Reset ca đã chọn khi đổi ngày
    _availableShifts = [];
    notifyListeners();
  }

  void selectShift(ShiftInfo shift) {
    _selectedShift = shift;
    print('[PROVIDER] Đã chọn ca khám: ${shift.start} - ${shift.end}');
    notifyListeners();
  }

  Future<void> fetchAvailableSlots(String doctorId) async {
    _isLoadingSlots = true;
    _slotsError = null;
    _availableShifts = [];
    _selectedShift = null; // Reset ca đã chọn khi tải lại
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
    print('[PROVIDER] Bắt đầu đặt lịch với ca đã chọn: ${_selectedShift?.start}');
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
      // Hàm này sẽ lấy thông tin ca khám từ _selectedShift
      await _apiService.createAppointment(
        token: token,
        patientId: patientId,
        doctorId: doctorId,
        date: dateString,
        shiftStart: _selectedShift!.start,
        shiftEnd: _selectedShift!.end,
      );
      
      // Sau khi đặt lịch thành công, tải lại danh sách lịch hẹn
      await fetchMyAppointments(token: token);
      _isBooking = false;
      notifyListeners();
      return true;
    } catch (e) {
      // Lấy lỗi từ ApiService nếu có
      if (e is Exception) {
        _bookingError = e.toString().replaceFirst('Exception: ', '');
      } else {
        _bookingError = 'Đã xảy ra lỗi không xác định.';
      }
      _isBooking = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchMyAppointments({required String token}) async {
  _isLoadingAppointments = true;
  _fetchAppointmentsError = null;
  notifyListeners();

  try {
    // 1. Lấy dữ liệu gốc từ API
    final appointments = await _apiService.getMyAppointments(token: token);

    // 2. Logic sắp xếp danh sách
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    appointments.sort((a, b) {
      final aDate = a.date;
      final bDate = b.date;
      final aIsPast = aDate.isBefore(today);
      final bIsPast = bDate.isBefore(today);

      // Nếu cả hai đều là lịch trong tương lai -> sắp xếp từ gần nhất đến xa nhất
      if (!aIsPast && !bIsPast) {
        return aDate.compareTo(bDate);
      }
      // Nếu cả hai đều là lịch trong quá khứ -> sắp xếp lịch gần đây nhất lên trên
      if (aIsPast && bIsPast) {
        return bDate.compareTo(aDate);
      }
      // Ưu tiên lịch tương lai lên trên lịch quá khứ
      return aIsPast ? 1 : -1;
    });
    
    _myAppointments = appointments;

  } catch (e) {
    _fetchAppointmentsError = e.toString();
  }

  _isLoadingAppointments = false;
  notifyListeners();
}

  Future<bool> cancelAppointment(
      {required String token, required String appointmentId}) async {
    // Tạm thời giữ lại lịch hẹn để có thể khôi phục nếu API lỗi
    final originalAppointments = List<Appointment>.from(_myAppointments);
    _myAppointments.removeWhere((appt) => appt.id == appointmentId);
    notifyListeners();
    
    _fetchAppointmentsError = null;
    try {
      await _apiService.cancelAppointment(
          token: token, appointmentId: appointmentId);
      return true;
    } catch (e) {
      _fetchAppointmentsError = e.toString();
      // Khôi phục lại danh sách nếu có lỗi
      _myAppointments = originalAppointments;
      notifyListeners();
      return false;
    }
  }
}