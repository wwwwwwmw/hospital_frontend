import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
            },
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          _buildDashboardCard(
            context,
            icon: Icons.medical_services_outlined,
            title: 'Quản lý Bác sĩ',
            subtitle: 'Thêm, sửa, xóa thông tin bác sĩ',
            onTap: () {
              context.go('/admin/manage-doctors');
            },
          ),
          _buildDashboardCard(
            context,
            icon: Icons.people_alt_outlined,
            title: 'Quản lý Bệnh nhân',
            subtitle: 'Xem danh sách và thông tin bệnh nhân',
            onTap: () {
              // TODO: Điều hướng đến trang quản lý bệnh nhân khi được tạo
              // context.go('/admin/manage-patients');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chức năng đang được phát triển')),
              );
            },
          ),
          _buildDashboardCard(
            context,
            icon: Icons.business_outlined,
            title: 'Quản lý Khoa',
            subtitle: 'Quản lý danh sách các khoa khám bệnh',
            onTap: () {
              // TODO: Điều hướng đến trang quản lý khoa khi được tạo
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chức năng đang được phát triển')),
              );
            },
          ),
           _buildDashboardCard(
            context,
            icon: Icons.calendar_month_outlined,
            title: 'Quản lý Lịch hẹn',
            subtitle: 'Xem và quản lý tất cả lịch hẹn',
            onTap: () {
              // TODO: Điều hướng đến trang quản lý lịch hẹn khi được tạo
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chức năng đang được phát triển')),
              );
            },
          ),
        ],
      ),
    );
  }

  // Widget helper để tạo các thẻ chức năng cho gọn
  Widget _buildDashboardCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, size: 40, color: Theme.of(context).primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
