import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Màn hình này chỉ hiển thị một vòng xoay loading ở giữa.
    // Toàn bộ logic chuyển trang đã được xử lý trong GoRouter.
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

