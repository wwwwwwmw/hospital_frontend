import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/appointment_provider.dart';
import '../../utils/date_formatter.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  @override
  void initState() {
    super.initState();
    // Gọi provider để lấy danh sách lịch hẹn ngay khi màn hình được tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppointmentProvider>(context, listen: false)
          .fetchMyAppointments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch hẹn của tôi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<AppointmentProvider>(context, listen: false)
                  .fetchMyAppointments();
            },
          ),
        ],
      ),
      body: Consumer<AppointmentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(child: Text('Lỗi: ${provider.errorMessage}'));
          }

          if (provider.myAppointments.isEmpty) {
            return const Center(
              child: Text('Bạn chưa có lịch hẹn nào.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: provider.myAppointments.length,
            itemBuilder: (context, index) {
              final appointment = provider.myAppointments[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(
                      appointment.status == 'confirmed'
                          ? Icons.check_circle_outline
                          : Icons.hourglass_empty,
                      color: appointment.status == 'confirmed'
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                  title: Text(
                    'Lịch khám với BS. ${appointment.doctor.fullName}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                          'Ngày: ${DateFormatter.formatDate(appointment.date)}'),
                      Text('Giờ: ${DateFormatter.formatTime(appointment.date)}'),
                      Text('Trạng thái: ${appointment.status}'),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

