import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/doctor_panel_provider.dart'; // Sửa: Import đúng provider
import '../../utils/date_formatter.dart';

class DoctorAppointmentsScreen extends StatefulWidget {
  const DoctorAppointmentsScreen({super.key});

  @override
  State<DoctorAppointmentsScreen> createState() => _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState extends State<DoctorAppointmentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      if (token != null) {
        // Sửa: Gọi đúng provider
        Provider.of<DoctorPanelProvider>(context, listen: false)
            .fetchMyAppointments(token: token);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch hẹn của tôi'),
      ),
      // Sửa: Lắng nghe đúng provider
      body: Consumer<DoctorPanelProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.errorMessage != null) {
            return Center(child: Text('Lỗi: ${provider.errorMessage}'));
          }
          if (provider.myAppointments.isEmpty) {
            return const Center(child: Text('Bạn không có lịch hẹn nào.'));
          }
          return RefreshIndicator(
            onRefresh: () async {
               final token = Provider.of<AuthProvider>(context, listen: false).token;
                if (token != null) {
                  await Provider.of<DoctorPanelProvider>(context, listen: false)
                      .fetchMyAppointments(token: token);
                }
            },
            child: ListView.builder(
              itemCount: provider.myAppointments.length,
              itemBuilder: (context, index) {
                final appointment = provider.myAppointments[index];
                return Card(
                  child: ListTile(
                    title: Text('Bệnh nhân: ${appointment.patient?.fullName ?? 'N/A'}'),
                    subtitle: Text(
                        'Thời gian: ${DateFormatter.formatDate(appointment.date)} - ${appointment.slotStart}\nTrạng thái: ${appointment.status}'),
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
