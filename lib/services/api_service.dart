import 'package:dio/dio.dart';
import '../models/doctor.dart';
import '../models/appointment.dart';
import '../models/time_slot.dart';
import '../models/patient.dart';
import '../models/department.dart';

// Lớp helper để chứa User và Token từ response của API
class AuthResponse {
  final String token;
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

  /// Hàm nội bộ để xử lý lỗi DioException
  String _handleDioError(DioException e) {
    if (e.response != null && e.response?.data is Map<String, dynamic>) {
        final responseData = e.response?.data;
        if (responseData.containsKey('message')) {
          return responseData['message'];
        }
    }
    if (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.connectionTimeout){
         return 'Connection failed. Please check your network and server status.';
    }
    return 'An unknown error occurred.';
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


  // --- User-facing APIs ---
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
    required DateTime startTime,
  }) async {
    try {
      await _dio.post(
        '/appointments',
        data: {
          'doctor': doctorId,
          'startTime': startTime.toIso8601String(),
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

  Future<void> cancelAppointment({required String token, required String appointmentId}) async {
    try {
      await _dio.delete(
        '/appointments/$appointmentId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<Patient> getMyPatientProfile({required String token}) async {
    try {
      final response = await _dio.get(
        '/patients/me',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return Patient.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }
  
  Future<Patient> updateMyPatientProfile({required String token, required Map<String, dynamic> patientData}) async {
      try {
      final response = await _dio.put(
        '/patients/me',
        data: patientData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return Patient.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  // --- Admin APIs ---
  Future<List<Doctor>> adminGetAllDoctors({required String token}) async {
    try {
      final response = await _dio.get(
        '/doctors', 
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return (response.data as List).map((json) => Doctor.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<List<Patient>> adminGetAllPatients({required String token}) async {
    try {
      final response = await _dio.get(
        '/patients',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return (response.data as List).map((json) => Patient.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<List<Department>> adminGetAllDepartments({required String token}) async {
    try {
      final response = await _dio.get(
        '/departments',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return (response.data as List).map((json) => Department.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<void> createDoctor({required String token, required Map<String, dynamic> doctorData}) async {
    try {
      await _dio.post(
        '/doctors',
        data: doctorData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }
  
  Future<void> updateDoctor({required String token, required String doctorId, required Map<String, dynamic> doctorData}) async {
     try {
      await _dio.put(
        '/doctors/$doctorId',
        data: doctorData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<void> deleteDoctor({required String token, required String doctorId}) async {
     try {
      await _dio.delete(
        '/doctors/$doctorId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }
}

