import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

// Core Screens
import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/change_password_screen.dart';

// User Flow Screens
import '../screens/user_flow/home_screen.dart';
import '../screens/user_flow/doctor_list_screen.dart';
import '../screens/user_flow/doctor_detail_screen.dart';
import '../screens/user_flow/appointment_booking_screen.dart';
import '../screens/user_flow/my_appointments_screen.dart';
import '../screens/user_flow/profile_screen.dart';
import '../screens/user_flow/edit_patient_profile_screen.dart';

// Doctor Panel Screens
import '../screens/doctor_panel/doctor_dashboard_screen.dart';
import '../screens/doctor_panel/doctor_appointments_screen.dart';
import '../screens/doctor_panel/register_schedule_screen.dart'; // Import màn hình mới

// Admin Screens
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/doctors/manage_doctors_screen.dart';
import '../screens/admin/doctors/edit_doctor_screen.dart';
import '../screens/admin/users/manage_users_screen.dart';
import '../screens/admin/users/user_detail_screen.dart';


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

      // --- Doctor Panel Route ---
      GoRoute(
        path: '/doctor',
        builder: (context, state) => const DoctorDashboardScreen(),
        routes: [
          GoRoute(
            path: 'appointments',
            builder: (context, state) => const DoctorAppointmentsScreen(),
          ),
          // BỔ SUNG ROUTE MỚI
          GoRoute(
            path: 'register-schedule',
            builder: (context, state) => const RegisterScheduleScreen(),
          ),
        ],
      ),

      // --- User & Admin Routes (nested under root) ---
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
        routes: [
          // User Routes
          GoRoute(
            path: 'doctors',
            builder: (context, state) => const DoctorListScreen(),
          ),
          GoRoute(
            path: 'doctor_details/:doctorId',
            builder: (context, state) =>
                DoctorDetailScreen(doctorId: state.pathParameters['doctorId']!),
          ),
          GoRoute(
            path: 'book-appointment/:doctorId',
            builder: (context, state) => AppointmentBookingScreen(
                doctorId: state.pathParameters['doctorId']!),
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

          // Admin Routes (Simplified)
          GoRoute(
            path: 'admin',
            builder: (context, state) => const AdminDashboardScreen(),
            routes: [
              GoRoute(
                path: 'manage-doctors',
                builder: (context, state) => const ManageDoctorsScreen(),
                routes: [
                  GoRoute(
                    path: 'edit/:doctorId',
                    builder: (context, state) => EditDoctorScreen(
                        doctorId: state.pathParameters['doctorId']!),
                  ),
                ],
              ),
              GoRoute(
                path: 'manage-users',
                builder: (context, state) => const ManageUsersScreen(),
                routes: [
                  GoRoute(
                    path: 'details/:userId',
                    builder: (context, state) => UserDetailScreen(
                        userId: state.pathParameters['userId']!),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final authStatus = authProvider.status;
      final bool isDoctor = authProvider.isDoctor;
      final bool isAdminOrStaff = authProvider.isAdmin || authProvider.isStaff;

      final String location = state.matchedLocation;
      final bool isLoggingIn =
          location == '/login' || location == '/register';
      final bool isGoingToSplash = location == '/splash';
      final bool isGoingToAdmin = location.startsWith('/admin');
      final bool isGoingToDoctor = location.startsWith('/doctor');

      if (authStatus == AuthStatus.uninitialized) {
        return isGoingToSplash ? null : '/splash';
      }

      if (authStatus == AuthStatus.unauthenticated) {
        return isLoggingIn ? null : '/login';
      }

      if (authStatus == AuthStatus.authenticated) {
        if (isLoggingIn || isGoingToSplash) {
          if (isAdminOrStaff) return '/admin';
          if (isDoctor) return '/doctor';
          return '/';
        }

        if (isGoingToAdmin && !isAdminOrStaff) return '/';
        if (isGoingToDoctor && !isDoctor) return '/';

        final isGoingToUserFlow = !isGoingToAdmin && !isGoingToDoctor;
        if (isGoingToUserFlow && (isAdminOrStaff || isDoctor)) {
          if (isAdminOrStaff) return '/admin';
          if (isDoctor) return '/doctor';
        }
      }
      return null;
    },
  );
}

