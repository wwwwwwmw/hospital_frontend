import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class DoctorDashboardScreen extends StatelessWidget {
  const DoctorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bảng điều khiển Bác sĩ'),
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
            icon: Icons.calendar_today_outlined,
            title: 'Xem lịch hẹn',
            subtitle: 'Xem danh sách các lịch hẹn đã đặt',
            onTap: () {
              context.go('/doctor/appointments');
            },
          ),
          _buildDashboardCard(
            context,
            icon: Icons.schedule_outlined,
            title: 'Đăng ký lịch làm việc',
            subtitle: 'Thiết lập thời gian làm việc trong tuần',
            onTap: () {
              // SỬA Ở ĐÂY
              context.go('/doctor/register-schedule');
            },
          ),
        ],
      ),
    );
  }

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
