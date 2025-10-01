import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang chủ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: () {
              // Gọi hàm logout từ provider
              context.read<AuthProvider>().logout();
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Chào mừng trở lại!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            // Hiển thị email người dùng nếu có
            if (authProvider.user != null) Text(authProvider.user!['email']),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Điều hướng đến trang danh sách bác sĩ
                context.go('/doctors');
              },
              child: const Text('Xem danh sách Bác sĩ'),
            )
          ],
        ),
      ),
    );
  }
}
