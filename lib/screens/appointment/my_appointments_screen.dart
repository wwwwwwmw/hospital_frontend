import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/date_formatter.dart';
import '../../models/appointment.dart';

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
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.token != null) {
        Provider.of<AppointmentProvider>(context, listen: false)
            // SỬA Ở ĐÂY: Dùng tham số được đặt tên
            .fetchMyAppointments(token: authProvider.token!);
      }
    });
  }

  // Hàm xử lý việc hủy lịch hẹn
  Future<void> _cancelAppointment(String appointmentId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final appointmentProvider =
        Provider.of<AppointmentProvider>(context, listen: false);

    // Hiển thị dialog xác nhận
    final bool? confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận hủy'),
        content: const Text('Bạn có chắc chắn muốn hủy lịch hẹn này?'),
        actions: [
          TextButton(
            child: const Text('Không'),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          TextButton(
            child: const Text('Hủy lịch', style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (confirm == true && authProvider.token != null) {
      final success = await appointmentProvider.cancelAppointment(
        authProvider.token!,
        appointmentId,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Hủy lịch hẹn thành công!'
                : 'Lỗi: ${appointmentProvider.fetchAppointmentsError}'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch hẹn của tôi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (authProvider.token != null) {
                Provider.of<AppointmentProvider>(context, listen: false)
                    // SỬA Ở ĐÂY: Dùng tham số được đặt tên
                    .fetchMyAppointments(token: authProvider.token!);
              }
            },
          ),
        ],
      ),
      body: Consumer<AppointmentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingAppointments) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.fetchAppointmentsError != null) {
            return Center(
                child: Text('Lỗi: ${provider.fetchAppointmentsError}'));
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
              final isCancelled = appointment.status == 'cancelled';
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                color: isCancelled ? Colors.grey[300] : null,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isCancelled ? Colors.grey : (appointment.status == 'confirmed' ? Colors.green : Colors.orange),
                    child: Icon(
                      isCancelled ? Icons.cancel_outlined : (appointment.status == 'confirmed' ? Icons.check_circle_outline : Icons.hourglass_empty),
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    'BS. ${appointment.doctor.fullName}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: isCancelled ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                          'Ngày: ${DateFormatter.formatDate(appointment.startTime)}'),
                      Text('Giờ: ${DateFormatter.formatTime(appointment.startTime)}'),
                      Text('Trạng thái: ${appointment.status}'),
                    ],
                  ),
                  trailing: isCancelled
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _cancelAppointment(appointment.id),
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

