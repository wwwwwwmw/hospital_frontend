import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

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
    initialLocation: '/splash',
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
                  return EditDoctorScreen(doctorId: doctorId);
                },
              )
            ]
          ),
        ],
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final authStatus = authProvider.status;
      final bool isAdminOrStaff = authProvider.isAdmin || authProvider.isStaff;
      
      final String location = state.matchedLocation;
      final bool isLoggingIn = location == '/login' || location == '/register';
      final bool isGoingToSplash = location == '/splash';
      final bool isGoingToAdmin = location.startsWith('/admin');

      if (authStatus == AuthStatus.uninitialized) {
        return isGoingToSplash ? null : '/splash';
      }

      if (authStatus == AuthStatus.unauthenticated) {
        return isLoggingIn ? null : '/login';
      }

      if (authStatus == AuthStatus.authenticated) {
        // --- SỬA LOGIC Ở ĐÂY ---
        // Nếu đã đăng nhập và đang ở trang login/register/splash,
        // hãy kiểm tra vai trò để quyết định trang đích.
        if (isLoggingIn || isGoingToSplash) {
          if (isAdminOrStaff) {
            return '/admin'; // Chuyển admin/staff đến trang dashboard
          }
          return '/'; // Chuyển người dùng thông thường đến trang chủ
        }
        // -------------------------

        if (isGoingToAdmin && !isAdminOrStaff) {
          return '/';
        }
      }
      
      return null;
    },
  );
}

