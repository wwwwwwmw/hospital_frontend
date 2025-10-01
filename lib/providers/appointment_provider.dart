import 'package:flutter/material.dart';
import '../models/time_slot.dart';
import '../services/api_service.dart';
import '../models/appointment.dart';

class AppointmentProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  // Trạng thái cho việc đặt lịch
  DateTime _selectedDate = DateTime.now();
  List<TimeSlot> _availableSlots = [];
  bool _isLoadingSlots = false;
  DateTime? _selectedSlot;
  bool _isBooking = false;
  String? _bookingError;
  String? _slotsError;

  // Trạng thái cho việc xem lịch hẹn
  List<Appointment> _myAppointments = [];
  bool _isLoadingAppointments = false;
  String? _fetchAppointmentsError;

  // Getters
  DateTime get selectedDate => _selectedDate;
  List<TimeSlot> get availableSlots => _availableSlots;
  bool get isLoadingSlots => _isLoadingSlots;
  DateTime? get selectedSlot => _selectedSlot;
  bool get isBooking => _isBooking;
  String? get bookingError => _bookingError;
  String? get slotsError => _slotsError;
  List<Appointment> get myAppointments => _myAppointments;
  bool get isLoadingAppointments => _isLoadingAppointments;
  String? get fetchAppointmentsError => _fetchAppointmentsError;


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
    _slotsError = null;
    _availableSlots = [];
    notifyListeners();
    try {
      final dateString = "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";
      _availableSlots = await _apiService.getSlotsByDoctorAndDate(doctorId, dateString);
    } catch (e) {
      _slotsError = e.toString();
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
    _bookingError = null;
    notifyListeners();

    try {
      await _apiService.createAppointment(
        token: token,
        doctorId: doctorId,
        startTime: _selectedSlot!,
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

  Future<void> fetchMyAppointments({required String token}) async {
    _isLoadingAppointments = true;
    _fetchAppointmentsError = null;
    notifyListeners();
    try {
      // SỬA Ở ĐÂY: Gọi hàm với tham số được đặt tên
      _myAppointments = await _apiService.getMyAppointments(token: token);
    } catch (e) {
      _fetchAppointmentsError = e.toString();
    }
    _isLoadingAppointments = false;
    notifyListeners();
  }
  
  Future<bool> cancelAppointment(String token, String appointmentId) async {
    _fetchAppointmentsError = null;
    try {
      await _apiService.cancelAppointment(token: token, appointmentId: appointmentId);
      
      // Cập nhật trạng thái của lịch hẹn trong danh sách thay vì xóa
      final index = _myAppointments.indexWhere((app) => app.id == appointmentId);
      if (index != -1) {
        // Giả sử backend trả về appointment đã cập nhật, hoặc chúng ta tự cập nhật trên UI
        // Ở đây chúng ta sẽ tải lại toàn bộ danh sách để đảm bảo dữ liệu mới nhất
         await fetchMyAppointments(token: token);
      }
      notifyListeners();
      return true;
    } catch (e) {
      _fetchAppointmentsError = e.toString();
      notifyListeners();
      return false;
    }
  }
}

