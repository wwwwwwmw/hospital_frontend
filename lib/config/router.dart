import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/doctor/doctor_detail_screen.dart';
import '../screens/doctor/doctor_list_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/splash_screen.dart';

class AppRouter {
  final AuthProvider authProvider;

  AppRouter(this.authProvider);

  GoRouter get router {
    return GoRouter(
      // Lắng nghe sự thay đổi trạng thái của AuthProvider
      refreshListenable: authProvider,
      // Trang ban đầu khi mở ứng dụng
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
        ),
        GoRoute(
          path: '/doctors',
          builder: (context, state) => const DoctorListScreen(),
        ),
        GoRoute(
          path: '/doctor_details/:doctorId',
          builder: (context, state) {
            final doctorId = state.pathParameters['doctorId']!;
            return DoctorDetailScreen(doctorId: doctorId);
          },
        ),
      ],
      // Logic điều hướng tự động
      redirect: (BuildContext context, GoRouterState state) {
        final isAuthenticated = authProvider.isAuthenticated;
        final isLoggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/register';

        // Nếu chưa đăng nhập và đang cố vào trang được bảo vệ
        if (!isAuthenticated && !isLoggingIn) {
          return '/login'; // Chuyển đến trang đăng nhập
        }

        // Nếu đã đăng nhập và đang ở trang đăng nhập/đăng ký
        if (isAuthenticated && isLoggingIn) {
          return '/'; // Chuyển đến trang chủ
        }

        // Trường hợp còn lại, không cần điều hướng
        return null;
      },
    );
  }
}
