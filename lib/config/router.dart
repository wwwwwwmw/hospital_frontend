import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../screens/splash_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/change_password_screen.dart';
import '../screens/doctor/doctor_list_screen.dart';
import '../screens/doctor/doctor_detail_screen.dart';
import '../screens/appointment/appointment_booking_screen.dart';
import '../screens/appointment/my_appointments_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/edit_patient_profile_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/doctors/manage_doctors_screen.dart';
import '../screens/admin/doctors/edit_doctor_screen.dart';

class AppRouter {
  final AuthProvider authProvider;

  AppRouter({required this.authProvider});

  late final GoRouter router = GoRouter(
    refreshListenable: authProvider,
    initialLocation: '/splash', // Bắt đầu với màn hình splash
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // --- Main App Routes (Protected) ---
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'doctors',
            builder: (context, state) => const DoctorListScreen(),
          ),
          GoRoute(
            path: 'doctor_details/:doctorId',
            builder: (context, state) {
              final doctorId = state.pathParameters['doctorId']!;
              return DoctorDetailScreen(doctorId: doctorId);
            },
          ),
          GoRoute(
            path: 'book-appointment/:doctorId',
            builder: (context, state) {
              final doctorId = state.pathParameters['doctorId']!;
              return AppointmentBookingScreen(doctorId: doctorId);
            },
          ),
          GoRoute(
            path: 'my-appointments',
            builder: (context, state) => const MyAppointmentsScreen(),
          ),
          GoRoute(
            path: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: 'edit-profile',
            builder: (context, state) => const EditPatientProfileScreen(),
          ),
          GoRoute(
            path: 'change-password',
            builder: (context, state) => const ChangePasswordScreen(),
          ),
          
          // --- Admin Routes (Protected by Role) ---
          GoRoute(
            path: 'admin',
            builder: (context, state) => const AdminDashboardScreen(),
            routes: [
              GoRoute(
                path: 'manage-doctors',
                builder: (context, state) => const ManageDoctorsScreen(),
              ),
              GoRoute(
                path: 'edit-doctor/:doctorId',
                 builder: (context, state) {
                  final doctorId = state.pathParameters['doctorId']!;
                  // Thêm logic để xử lý tạo mới (khi doctorId là 'new')
                  return EditDoctorScreen(doctorId: doctorId);
                },
              )
            ]
          ),
        ],
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final bool loggedIn = authProvider.isAuthenticated;
      final bool isAdminOrStaff = authProvider.isAdmin || authProvider.isStaff;
      
      final bool isLoggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/register';
      final bool isGoingToSplash = state.matchedLocation == '/splash';
      final bool isGoingToAdmin = state.matchedLocation.startsWith('/admin');

      // Nếu đang ở màn hình splash, không làm gì cả
      if(isGoingToSplash) return null;

      // Nếu chưa đăng nhập và không ở trang login/register, chuyển hướng về login
      if (!loggedIn && !isLoggingIn) {
        return '/login';
      }

      // Nếu đã đăng nhập và đang ở trang login/register, chuyển hướng về trang chủ
      if (loggedIn && isLoggingIn) {
        return '/';
      }

      // Nếu đang cố vào trang admin mà không có quyền, chuyển về trang chủ
      if (loggedIn && isGoingToAdmin && !isAdminOrStaff) {
        return '/'; // Hoặc có thể hiển thị trang "Không có quyền truy cập"
      }
      
      // Mặc định không chuyển hướng
      return null;
    },
  );
}

