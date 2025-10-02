import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

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
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          // Phần chào mừng người dùng
          if (user != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Chào mừng trở lại!',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(user['fullName'] ?? ''),
                ],
              ),
            ),
          
          // Các thẻ chức năng
          _buildDashboardCard(
            context,
            icon: Icons.calendar_month_outlined,
            title: 'Đặt lịch hẹn',
            subtitle: 'Tìm bác sĩ và đặt lịch khám',
            onTap: () {
              context.go('/doctors');
            },
          ),
          _buildDashboardCard(
            context,
            icon: Icons.list_alt_outlined,
            title: 'Lịch hẹn của tôi',
            subtitle: 'Xem và quản lý các lịch hẹn đã đặt',
            onTap: () {
              context.go('/my-appointments');
            },
          ),
          _buildDashboardCard(
            context,
            icon: Icons.family_restroom_outlined,
            title: 'Thông tin Bệnh nhân',
            subtitle: 'Quản lý hồ sơ của các bệnh nhân được bảo hộ',
            onTap: () {
              context.go('/manage-patients');
            },
          ),
          _buildDashboardCard(
            context,
            icon: Icons.person_outline,
            title: 'Tài khoản',
            subtitle: 'Chỉnh sửa thông tin cá nhân và mật khẩu',
            onTap: () {
              context.go('/profile');
            },
          ),
        ],
      ),
    );
  }

  // Widget helper để tạo các thẻ chức năng cho gọn gàng, sạch sẽ
  Widget _buildDashboardCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: ListTile(
        leading: Icon(icon, size: 40, color: Theme.of(context).primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}