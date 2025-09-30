import 'package:flutter/material.dart';
import '../models/time_slot.dart';
import '../services/api_service.dart';
import '../models/appointment.dart';

class AppointmentProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  // Trạng thái cho việc đặt lịch hẹn
  DateTime _selectedDate = DateTime.now();
  DateTime? _selectedSlot;
  List<TimeSlot> _availableSlots = [];
  bool _isLoadingSlots = false;
  bool _isBooking = false;
  String? _slotsError;
  String? _bookingError;

  DateTime get selectedDate => _selectedDate;
  DateTime? get selectedSlot => _selectedSlot;
  List<TimeSlot> get availableSlots => _availableSlots;
  bool get isLoadingSlots => _isLoadingSlots;
  bool get isBooking => _isBooking;
  String? get slotsError => _slotsError;
  String? get bookingError => _bookingError;

  // Trạng thái cho việc xem lịch hẹn của tôi
  List<Appointment> _myAppointments = [];
  List<Appointment> get myAppointments => _myAppointments;
  bool _isLoadingAppointments = false;
  bool get isLoadingAppointments => _isLoadingAppointments;
  String? _fetchAppointmentsError;
  String? get fetchAppointmentsError => _fetchAppointmentsError;

  void selectDate(DateTime date) {
    _selectedDate = date;
    _selectedSlot = null; // Reset giờ đã chọn khi đổi ngày
    _availableSlots = []; // Xóa danh sách slot cũ
    notifyListeners();
  }

  void selectSlot(DateTime slot) {
    _selectedSlot = slot;
    notifyListeners();
  }

  /// Lấy các khung giờ trống của một bác sĩ theo ngày đã chọn
  Future<void> fetchAvailableSlots(String doctorId) async {
    _isLoadingSlots = true;
    _slotsError = null;
    notifyListeners();

    try {
      final dateString = _selectedDate.toIso8601String().split('T').first;
      _availableSlots =
          await _apiService.getSlotsByDoctorAndDate(doctorId, dateString);
    } catch (e) {
      _slotsError = e.toString();
    }

    _isLoadingSlots = false;
    notifyListeners();
  }

  /// Tạo một lịch hẹn mới
  Future<bool> createAppointment(
      {required String token, required String doctorId}) async {
    if (_selectedSlot == null) {
      _bookingError = 'Vui lòng chọn một giờ khám.';
      notifyListeners();
      return false;
    }

    _isBooking = true;
    _bookingError = null;
    notifyListeners();

    try {
      await _apiService.createAppointment(
        token: token,
        doctorId: doctorId,
        startTime: _selectedSlot!,
      );
      // Tải lại danh sách lịch hẹn của tôi sau khi đặt thành công
      await fetchMyAppointments(token);
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
  Future<void> fetchMyAppointments(String token) async {
    _isLoadingAppointments = true;
    _fetchAppointmentsError = null;
    notifyListeners();

    try {
      _myAppointments = await _apiService.getMyAppointments(token);
    } catch (e) {
      _fetchAppointmentsError = e.toString();
    }

    _isLoadingAppointments = false;
    notifyListeners();
  }

  /// Hủy một lịch hẹn
  Future<bool> cancelAppointment(String token, String appointmentId) async {
    try {
      await _apiService.cancelAppointment(token: token, appointmentId: appointmentId);
      // Xóa lịch hẹn khỏi danh sách trên UI ngay lập tức
      _myAppointments.removeWhere((app) => app.id == appointmentId);
      notifyListeners();
      return true;
    } catch (e) {
      // Có thể hiển thị lỗi cho người dùng nếu cần
      print(e.toString());
      return false;
    }
  }
}

