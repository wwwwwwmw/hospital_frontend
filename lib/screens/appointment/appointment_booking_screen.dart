import 'package:flutter/material.dart';
import '../../models/appointment.dart';
import '../../models/time_slot.dart';
import '../../services/api_service.dart';




class AppointmentProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  // Trạng thái cho việc đặt lịch
  DateTime _selectedDate = DateTime.now();
  List<TimeSlot> _availableSlots = [];
  bool _isLoadingSlots = false;
  DateTime? _selectedSlot;
  bool _isBooking = false;
  String? _bookingError; // BIẾN MỚI ĐỂ LƯU LỖI

  // Trạng thái cho việc xem lịch hẹn
  List<Appointment> _myAppointments = [];
  bool _isLoadingAppointments = false;

  // Getters
  DateTime get selectedDate => _selectedDate;
  List<TimeSlot> get availableSlots => _availableSlots;
  bool get isLoadingSlots => _isLoadingSlots;
  DateTime? get selectedSlot => _selectedSlot;
  bool get isBooking => _isBooking;
  String? get bookingError => _bookingError; // GETTER MỚI
  List<Appointment> get myAppointments => _myAppointments;
  bool get isLoadingAppointments => _isLoadingAppointments;

  void selectDate(DateTime date) {
    _selectedDate = date;
    _selectedSlot = null;
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
      final dateString = "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";
      _availableSlots = await _apiService.getSlotsByDoctorAndDate(doctorId, dateString);
    } catch (e) {
      print(e);
    }
    _isLoadingSlots = false;
    notifyListeners();
  }

  Future<bool> createAppointment({
    required String token, // Sửa lại: Nhận token
    required String doctorId,
  }) async {
    if (_selectedSlot == null) return false;

    _isBooking = true;
    _bookingError = null; // Reset lỗi trước khi thực hiện
    notifyListeners();

    try {
      await _apiService.createAppointment(
        token: token,
        doctorId: doctorId,
        startTime: _selectedSlot!,
      );
      await fetchMyAppointments(token);
      _isBooking = false;
      notifyListeners();
      return true;
    } catch (e) {
      _bookingError = e.toString(); // Gán lỗi
      _isBooking = false;
      notifyListeners();
      return false;
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

