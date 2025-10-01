import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/admin_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/appointment.dart';
import '../../../utils/date_formatter.dart';

class ManageAppointmentsScreen extends StatefulWidget {
  const ManageAppointmentsScreen({super.key});

  @override
  State<ManageAppointmentsScreen> createState() =>
      _ManageAppointmentsScreenState();
}

class _ManageAppointmentsScreenState extends State<ManageAppointmentsScreen> {
  @override
  void initState() {
    super.initState();
    // Tải danh sách tất cả lịch hẹn khi màn hình được tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      if (token != null) {
        Provider.of<AdminProvider>(context, listen: false)
            .fetchAllAppointments(token: token);
      }
    });
  }

  // Hàm để thay đổi trạng thái lịch hẹn (chức năng "edit")
  Future<void> _changeAppointmentStatus(
      Appointment appointment, String newStatus) async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);

    if (token == null) return;

    // SỬA Ở ĐÂY: Dùng tham số được đặt tên
    final success = await adminProvider.updateAppointmentStatus(
      token: token,
      appointmentId: appointment.id,
      status: newStatus,
    );

    if (mounted && !success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Lỗi: ${adminProvider.errorMessage ?? "Không thể cập nhật"}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final token = Provider.of<AuthProvider>(context, listen: false).token;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Lịch hẹn'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (token != null) {
                Provider.of<AdminProvider>(context, listen: false)
                    .fetchAllAppointments(token: token);
              }
            },
          ),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.allAppointments.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.errorMessage != null &&
              provider.allAppointments.isEmpty) {
            return Center(child: Text('Lỗi: ${provider.errorMessage}'));
          }
          if (provider.allAppointments.isEmpty) {
            return const Center(
                child: Text('Không có lịch hẹn nào trong hệ thống.'));
          }

          return RefreshIndicator(
            onRefresh: () async {
               if (token != null) {
                await Provider.of<AdminProvider>(context, listen: false)
                    .fetchAllAppointments(token: token);
              }
            },
            child: ListView.builder(
              itemCount: provider.allAppointments.length,
              itemBuilder: (context, index) {
                final appointment = provider.allAppointments[index];
                return Card(
                  child: ListTile(
                    title: Text('BN: ${appointment.patient?.fullName ?? 'N/A'}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('BS: ${appointment.doctor.fullName}'),
                        Text(
                            'Thời gian: ${DateFormatter.formatDate(appointment.startTime)} - ${DateFormatter.formatTime(appointment.startTime)}'),
                      ],
                    ),
                    trailing: DropdownButton<String>(
                      value: appointment.status,
                      items: ['pending', 'confirmed', 'completed', 'cancelled']
                          .map((status) => DropdownMenuItem(
                                value: status,
                                child: Text(status),
                              ))
                          .toList(),
                      onChanged: (newStatus) {
                        if (newStatus != null &&
                            newStatus != appointment.status) {
                          _changeAppointmentStatus(appointment, newStatus);
                        }
                      },
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

