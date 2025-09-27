import 'package:flutter/material.dart';
import '../models/time_slot.dart';
import '../models/appointment.dart';
import '../services/api_service.dart';

class AppointmentProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  // Trạng thái cho việc đặt lịch
  DateTime _selectedDate = DateTime.now();
  List<TimeSlot> _availableSlots = [];
  bool _isLoadingSlots = false;
  DateTime? _selectedSlot;
  bool _isBooking = false;

  // Trạng thái cho việc xem lịch hẹn
  List<Appointment> _myAppointments = [];
  bool _isLoadingAppointments = false;

  // Getters
  DateTime get selectedDate => _selectedDate;
  List<TimeSlot> get availableSlots => _availableSlots;
  bool get isLoadingSlots => _isLoadingSlots;
  DateTime? get selectedSlot => _selectedSlot;
  bool get isBooking => _isBooking;
  List<Appointment> get myAppointments => _myAppointments;
  bool get isLoadingAppointments => _isLoadingAppointments;

  void selectDate(DateTime date) {
    _selectedDate = date;
    _selectedSlot = null; // Reset slot đã chọn khi đổi ngày
    notifyListeners();
  }

  void selectSlot(DateTime slot) {
    _selectedSlot = slot;
    notifyListeners();
  }

  Future<void> fetchAvailableSlots(String doctorId) async {
    _isLoadingSlots = true;
    _availableSlots = [];
    notifyListeners();

    try {
      // Định dạng ngày thành chuỗi YYYY-MM-DD
      final dateString = "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";
      _availableSlots = await _apiService.getSlotsByDoctorAndDate(doctorId, dateString);
    } catch (e) {
      print(e); // Xử lý lỗi
    }

    _isLoadingSlots = false;
    notifyListeners();
  }

  Future<bool> createAppointment({
    required String token,
    required String doctorId,
  }) async {
    if (_selectedSlot == null) return false;

    _isBooking = true;
    notifyListeners();

    try {
      await _apiService.createAppointment(
        token: token,
        doctorId: doctorId,
        startTime: _selectedSlot!,
      );
      // *** SỬA LỖI LOGIC Ở ĐÂY ***
      // Sau khi đặt lịch thành công, tự động gọi lại hàm fetchMyAppointments
      await fetchMyAppointments(token); 
      _isBooking = false;
      notifyListeners();
      return true; // Trả về true nếu thành công
    } catch (e) {
      print(e);
      _isBooking = false;
      notifyListeners();
      return false; // Trả về false nếu thất bại
    }
  }

  Future<void> fetchMyAppointments(String token) async {
    _isLoadingAppointments = true;
    notifyListeners();
    try {
      _myAppointments = await _apiService.getMyAppointments(token);
    } catch (e) {
      print(e);
    }
    _isLoadingAppointments = false;
    notifyListeners();
  }
}

