import 'package:flutter/material.dart';
import '../models/time_slot.dart';
import '../services/api_service.dart';
import '../models/appointment.dart';


class AppointmentProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  // Trạng thái cho việc lấy danh sách lịch hẹn
  List<Appointment> _appointments = [];
  List<Appointment> get appointments => _appointments;
  bool _isLoadingAppointments = false;
  bool get isLoadingAppointments => _isLoadingAppointments;

  // Trạng thái cho quá trình đặt lịch hẹn
  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  List<TimeSlot> _availableSlots = [];
  List<TimeSlot> get availableSlots => _availableSlots;
  bool _isLoadingSlots = false;
  bool get isLoadingSlots => _isLoadingSlots;

  TimeSlot? _selectedSlot;
  TimeSlot? get selectedSlot => _selectedSlot;

  bool _isBooking = false;
  bool get isBooking => _isBooking;
  String? _bookingError;
  String? get bookingError => _bookingError;

  // --- Logic cho việc xem lịch hẹn ---

  Future<void> fetchMyAppointments(String userId) async {
    _isLoadingAppointments = true;
    notifyListeners();
    try {
      _appointments = await _apiService.getMyAppointments(userId);
    } catch (e) {
      print('Error fetching appointments: $e');
    }
    _isLoadingAppointments = false;
    notifyListeners();
  }

  // --- Logic cho quá trình đặt lịch hẹn ---

  void selectDate(DateTime date) {
    _selectedDate = date;
    _selectedSlot = null; // Reset slot đã chọn khi đổi ngày
    notifyListeners();
  }

  void selectSlot(TimeSlot slot) {
    _selectedSlot = slot;
    notifyListeners();
  }

  Future<void> fetchAvailableSlots(String doctorId) async {
    _isLoadingSlots = true;
    _availableSlots = []; // Xóa danh sách cũ
    notifyListeners();
    try {
      final dateString = _selectedDate.toIso8601String().split('T').first;
      _availableSlots = await _apiService.getAvailableSlots(doctorId, dateString);
    } catch (e) {
      print('Error fetching slots: $e');
    }
    _isLoadingSlots = false;
    notifyListeners();
  }

  Future<bool> createAppointment({
    required String doctorId,
    required String? patientId,
  }) async {
    if (_selectedSlot == null || patientId == null) {
      _bookingError = "Vui lòng chọn khung giờ khám.";
      notifyListeners();
      return false;
    }

    _isBooking = true;
    _bookingError = null;
    notifyListeners();

    try {
      // Kết hợp ngày đã chọn và giờ đã chọn để tạo DateTime hoàn chỉnh
      final appointmentDate = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedSlot!.hour,
        _selectedSlot!.minute,
      );

      await _apiService.createAppointment(
        doctorId: doctorId,
        patientId: patientId,
        appointmentDate: appointmentDate,
      );
      
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
}

