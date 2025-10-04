import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_frontend/models/appointment.dart';
import 'package:hospital_frontend/screens/user_flow/appointment_detail_screen.dart';

import '../providers/auth_provider.dart';

// Import tất cả các màn hình của bạn ở đây
import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/change_password_screen.dart';
import '../screens/user_flow/home_screen.dart';
import '../screens/user_flow/doctor_list_screen.dart';
import '../screens/user_flow/doctor_detail_screen.dart';
import '../screens/user_flow/appointment_booking_screen.dart';
import '../screens/user_flow/my_appointments_screen.dart';
import '../screens/user_flow/profile_screen.dart';
import '../screens/user_flow/edit_profile_screen.dart';
import '../screens/user_flow/manage_patients_screen.dart';
import '../screens/user_flow/edit_patient_screen.dart';

import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/doctors/manage_doctors_screen.dart';
import '../screens/admin/doctors/edit_doctor_screen.dart';
import '../screens/admin/users/manage_users_screen.dart';
import '../screens/admin/users/user_detail_screen.dart';
import '../screens/admin/manage_schedules_screen.dart';
import '../screens/admin/appointments/manage_appointment_screen.dart';


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
            path: '/my-appointments/:appointmentId',
            name: 'appointmentDetail',
            builder: (context, state) {
              // Lấy đối tượng appointment đã được truyền qua từ màn hình trước
              final Appointment appointment = state.extra as Appointment;
              return AppointmentDetailScreen(appointment: appointment);
            },
          ),
          GoRoute(
            path: 'edit-profile',
            builder: (context, state) => const EditProfileScreen(),
          ),
           GoRoute(
            path: 'manage-patients',
            builder: (context, state) => const ManagePatientsScreen(),
            routes: [
              GoRoute(
                path: 'edit/:patientId',
                builder: (context, state) => EditPatientScreen(
                  patientId: state.pathParameters['patientId']!,
                ),
              ),
            ],
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
              GoRoute(
                path: 'manage-schedules',
                builder: (context, state) => const ManageSchedulesScreen(),
              ),
              GoRoute(
                path: 'manage-appointments',
                builder: (context, state) => const ManageAppointmentsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final authStatus = authProvider.status;
      final userRole = authProvider.user?['role'];
      final location = state.matchedLocation;

      if (authStatus == AuthStatus.uninitialized) {
        return location == '/splash' ? null : '/splash';
      }

      final isAtAuthScreen = location == '/login' || location == '/register';

      if (authStatus == AuthStatus.unauthenticated) {
        return isAtAuthScreen ? null : '/login';
      }

      if (authStatus == AuthStatus.authenticated) {
        if (isAtAuthScreen || location == '/splash') {
          if (userRole == 'admin' || userRole == 'staff') return '/admin';
          return '/';
        }

        final isGoingToAdmin = location.startsWith('/admin');

        if (isGoingToAdmin && !(userRole == 'admin' || userRole == 'staff')) {
          return '/';
        }
      }
      
      return null;
    },
  );
}