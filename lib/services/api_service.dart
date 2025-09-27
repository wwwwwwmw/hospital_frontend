import 'package:dio/dio.dart';
import '../models/doctor.dart';
import '../models/appointment.dart';
import '../models/time_slot.dart';


// Một lớp đơn giản để chứa User và Token trả về từ API
class AuthResponse {
  final String token;
  // Bạn có thể tạo một model User đầy đủ hơn nếu cần
  final Map<String, dynamic> user;

  AuthResponse({required this.token, required this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'],
      user: json['user'],
    );
  }
}

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    // Sử dụng localhost cho trình duyệt Chrome và cổng 5000 của backend
    baseUrl: 'http://localhost:5000/api',
  ));

  /// Hàm nội bộ để xử lý và trích xuất thông báo lỗi từ DioException
  String _handleDioError(DioException e) {
    print('--- Dio Error Occurred ---');
    print('Error Type: ${e.type}');
    if (e.response != null) {
      print('Error Response Data: ${e.response?.data}');
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        // Ưu tiên lỗi validation từ express-validator
        if (responseData.containsKey('errors') && responseData['errors'] is List) {
          final errors = responseData['errors'] as List;
          if (errors.isNotEmpty && errors.first is Map && errors.first.containsKey('msg')) {
            return errors.first['msg'];
          }
        }
        // Lỗi thông thường từ backend (ví dụ: throw { message: "..." })
        if (responseData.containsKey('message')) {
          return responseData['message'];
        }
      }
      return 'An error occurred: ${e.response?.statusCode}';
    } else {
      // Lỗi không có response (ví dụ: lỗi kết nối)
      print('Error has no response object. Message: ${e.message}');
      return 'Connection failed. Please check your network and server status.';
    }
  }

  // --- Doctor APIs ---
  Future<List<Doctor>> getDoctors() async {
    try {
      final response = await _dio.get('/doctors');
      return (response.data as List)
          .map((json) => Doctor.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<Doctor> getDoctorById(String id) async {
    try {
      final response = await _dio.get('/doctors/$id');
      return Doctor.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  // --- Auth APIs ---
  Future<AuthResponse> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'fullName': fullName,
        'email': email,
        'password': password,
      });
      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<void> changePassword({
    required String token,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await _dio.post(
        '/auth/change-password',
        data: {
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  // --- Appointment APIs ---
  Future<List<TimeSlot>> getSlotsByDoctorAndDate(String doctorId, String date) async {
    try {
      final response = await _dio.get('/doctors/$doctorId/slots', queryParameters: {'date': date});
      return (response.data as List).map((json) => TimeSlot.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<void> createAppointment({
    required String token,
    required String doctorId,
    required DateTime slot,
  }) async {
    try {
      await _dio.post(
        '/appointments',
        data: {
          'doctor': doctorId,
          'startTime': slot.toIso8601String(),
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<List<Appointment>> getMyAppointments(String token) async {
    try {
      final response = await _dio.get(
        '/appointments/me',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return (response.data as List).map((json) => Appointment.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }
}

