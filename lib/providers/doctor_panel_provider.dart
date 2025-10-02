import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/appointment.dart';

class DoctorPanelProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Appointment> _myAppointments = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Appointment> get myAppointments => _myAppointments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Lấy danh sách lịch hẹn của bác sĩ đã đăng nhập
  Future<void> fetchMyAppointments({required String token}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _myAppointments = await _apiService.getMyAppointmentsForDoctor(token: token);
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Đăng ký lịch làm việc cho cả tuần.
  /// Hàm này sẽ lặp qua các ngày có lịch và gọi API cho từng ngày.
  Future<bool> registerSchedulesForWeek({
    required String token,
    required Map<int, List<Map<String, dynamic>>> groupedSchedules, // Nhận vào dữ liệu đã được nhóm theo ngày
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Lặp qua từng entry trong map (key: weekday, value: list of blocks)
      for (var entry in groupedSchedules.entries) {
        final weekday = entry.key;
        final blocks = entry.value;

        // Tạo payload cho API request của một ngày
        final scheduleDataForOneDay = {
          'weekday': weekday,
          'blocks': blocks,
          // Lưu ý: doctorId sẽ được backend tự lấy từ token, không cần gửi lên
        };

        // Gọi API để cập nhật lịch cho ngày hiện tại trong vòng lặp
        // Giả sử trong ApiService bạn đã có hàm upsertWeeklySchedule
        await _apiService.upsertWeeklySchedule(
          token: token, 
          scheduleData: scheduleDataForOneDay
        );
      }

      _isLoading = false;
      notifyListeners();
      return true; // Trả về true nếu tất cả các request thành công
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false; // Trả về false nếu có bất kỳ request nào thất bại
    }
  }
}