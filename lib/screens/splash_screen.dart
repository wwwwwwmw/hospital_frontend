import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Giao diện đơn giản chỉ hiển thị vòng xoay loading
    // Logic kiểm tra và điều hướng sẽ được xử lý trong main.dart và router.dart
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
