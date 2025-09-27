import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lắng nghe AuthProvider nhưng không cần build lại widget này khi nó thay đổi
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Lấy thông tin người dùng, nếu chưa có thì hiển thị rỗng
    final user = authProvider.user;
    final fullName = user?['fullName'] ?? 'Không có thông tin';
    final email = user?['email'] ?? 'Không có thông tin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ của tôi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: CircleAvatar(
                radius: 50,
                child: Icon(Icons.person, size: 50),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: const Text('Họ và Tên'),
                    subtitle: Text(fullName),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.email_outlined),
                    title: const Text('Email'),
                    subtitle: Text(email),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Nút đổi mật khẩu
            ElevatedButton.icon(
              icon: const Icon(Icons.lock_outline),
              label: const Text('Đổi mật khẩu'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                context.go('/change-password');
              },
            ),
            const SizedBox(height: 16),
            // Nút đăng xuất
            OutlinedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Đăng xuất'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
              onPressed: () {
                // Gọi hàm logout từ provider
                authProvider.logout();
                // GoRouter sẽ tự động chuyển hướng về trang login
                // do thay đổi trạng thái isAuthenticated
              },
            ),
          ],
        ),
      ),
    );
  }
}

