import 'package:dio/dio.dart';
import '../models/doctor.dart';
import '../models/appointment.dart';
import '../models/time_slot.dart';
import '../models/patient.dart';
import '../models/department.dart';
import '../models/user.dart';

// ... (AuthResponse class and _handleDioError function remain the same)
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
    baseUrl: 'http://localhost:5000/api',
  ));

  String _handleDioError(DioException e) {
    // ... (existing error handling code)
    print('--- Dio Error Occurred ---');
    print('Error Type: ${e.type}');
    if (e.response != null) {
      print('Error Response Data: ${e.response?.data}');
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('errors') && responseData['errors'] is List) {
          final errors = responseData['errors'] as List;
          if (errors.isNotEmpty && errors.first is Map && errors.first.containsKey('msg')) {
            return errors.first['msg'];
          }
        }
        if (responseData.containsKey('message')) {
          return responseData['message'];
        }
      }
      return 'An error occurred: ${e.response?.statusCode}';
    } else {
      print('Error has no response object. Message: ${e.message}');
      return 'Connection failed. Please check your network and server status.';
    }
  }

  // --- Auth, Patient Profile APIs ---
  // ... (All existing functions in this section remain the same)
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

  // --- Public/User Doctor and Department APIs ---
  // ... (All existing functions in this section remain the same)
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
  
  Future<List<Department>> getDepartments() async {
    try {
      final response = await _dio.get('/departments');
      return (response.data as List).map((json) => Department.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  // --- Appointment APIs ---
  // ... (createAppointment and getSlotsByDoctorAndDate remain the same)
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

  // SỬA Ở ĐÂY: Sửa endpoint từ /me thành /my
  Future<List<Appointment>> getMyAppointments({required String token}) async {
    try {
      final response = await _dio.get(
        '/appointments/my',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return (response.data as List).map((json) => Appointment.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  // SỬA Ở ĐÂY: Sửa phương thức từ DELETE thành POST và endpoint
  Future<void> cancelAppointment({required String token, required String appointmentId}) async {
    try {
      await _dio.post(
        '/appointments/$appointmentId/cancel',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  // --- Doctor APIs ---
  // LƯU Ý: HÀM NÀY SẼ GÂY LỖI FORBIDDEN. BẠN CẦN LÀM VIỆC VỚI BACKEND ĐỂ TẠO API MỚI.
  Future<List<Appointment>> getMyAppointmentsForDoctor({required String token}) async {
    try {
      // Backend của bạn hiện không có API này. Đây là API mà đáng lẽ phải có:
      final response = await _dio.get(
        '/appointments/doctor/me', // Endpoint này chưa tồn tại
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return (response.data as List).map((json) => Appointment.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }
  
  // ... (All other functions remain the same)
  Future<void> registerDoctorSchedule({required String token, required List<Map<String, dynamic>> schedules}) async {
    try {
      await _dio.post(
        '/schedules',
        data: {'schedules': schedules},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }
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
      await _dio.patch(
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
  Future<void> createDepartment({required String token, required Map<String, dynamic> departmentData}) async {
    try {
      await _dio.post(
        '/departments',
        data: departmentData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }
  Future<void> updateDepartment({required String token, required String departmentId, required Map<String, dynamic> departmentData}) async {
    try {
      await _dio.patch(
        '/departments/$departmentId',
        data: departmentData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }
  Future<void> deleteDepartment({required String token, required String departmentId}) async {
    try {
      await _dio.delete(
        '/departments/$departmentId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }
  Future<List<Appointment>> adminGetAllAppointments({required String token}) async {
    try {
      final response = await _dio.get(
        '/appointments',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return (response.data as List).map((json) => Appointment.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }
  Future<void> adminUpdateAppointmentStatus({required String token, required String appointmentId, required String status}) async {
     try {
      await _dio.patch(
        '/appointments/$appointmentId',
        data: {'status': status},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
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
  Future<void> adminCreatePatient({required String token, required Map<String, dynamic> patientData}) async {
    try {
      await _dio.post(
        '/patients',
        data: patientData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }
  Future<void> adminUpdatePatient({required String token, required String patientId, required Map<String, dynamic> patientData}) async {
    try {
      await _dio.patch(
        '/patients/$patientId',
        data: patientData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }
  Future<void> adminDeletePatient({required String token, required String patientId}) async {
    try {
      await _dio.delete(
        '/patients/$patientId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }
  Future<List<User>> adminGetAllUsers({required String token}) async {
    try {
      final response = await _dio.get(
        '/users',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return (response.data as List).map((json) => User.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }
  Future<void> adminUpdateUser({required String token, required String userId, required Map<String, dynamic> userData}) async {
    try {
      await _dio.patch(
        '/users/$userId',
        data: userData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }
  Future<void> adminDeleteUser({required String token, required String userId}) async {
    try {
      await _dio.delete(
        '/users/$userId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }
  Future<List<Patient>> adminGetPatientsForUser({required String token, required String userId}) async {
    try {
      final response = await _dio.get(
        '/users/$userId/patients',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return (response.data as List).map((json) => Patient.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }
}

