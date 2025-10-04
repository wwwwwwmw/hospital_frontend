import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAppointments();
    });
  }

  void _fetchAppointments() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.token != null) {
      Provider.of<AppointmentProvider>(context, listen: false)
          .fetchMyAppointments(token: authProvider.token!);
    }
  }

  Future<void> _cancelAppointment(String appointmentId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final appointmentProvider =
        Provider.of<AppointmentProvider>(context, listen: false);

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
        token: authProvider.token!,
        appointmentId: appointmentId,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Hủy lịch hẹn thành công!'
                : 'Lỗi: ${appointmentProvider.fetchAppointmentsError ?? "Thao tác thất bại"}'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
        // Sau khi hủy, tải lại danh sách để cập nhật trạng thái
        if(success) _fetchAppointments();
      }
    }
  }

  Future<void> _deleteAppointment(String appointmentId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final appointmentProvider =
        Provider.of<AppointmentProvider>(context, listen: false);

    final bool? confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa lịch hẹn này khỏi danh sách? Thao tác này không thể hoàn tác.'),
        actions: [
          TextButton(
            child: const Text('Không'),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          TextButton(
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (confirm == true && authProvider.token != null) {
      final success = await appointmentProvider.deleteAppointment(
        token: authProvider.token!,
        appointmentId: appointmentId,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Xóa lịch hẹn thành công!'
                : 'Lỗi: ${appointmentProvider.fetchAppointmentsError ?? "Thao tác thất bại"}'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch hẹn của tôi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchAppointments,
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
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Lỗi: ${provider.fetchAppointmentsError}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
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
              final isCancelled = appointment.status.startsWith('canceled');
              final isCompleted = appointment.status == 'completed';
              
              // Kiểm tra xem lịch hẹn đã qua chưa
              final now = DateTime.now();
              final appointmentDate = appointment.date;
              final isPastAppointment = appointmentDate.isBefore(DateTime(now.year, now.month, now.day));

              IconData statusIcon;
              Color statusColor;

              if (isCancelled) {
                statusIcon = Icons.cancel_outlined; // Icon gạch chéo
                statusColor = Colors.red; // Màu đỏ
              } else if (isCompleted) {
                statusIcon = Icons.check_circle_outline;
                statusColor = Colors.green;
              } else {
                statusIcon = Icons.medical_services_outlined; // Icon mặc định
                statusColor = Theme.of(context).primaryColor;
              }

              // Xác định nút trailing dựa trên trạng thái
              Widget? trailingWidget;
              if (isCancelled || isPastAppointment || isCompleted) {
                // Hiển thị nút xóa cho lịch đã hủy, đã qua hoặc đã hoàn thành
                trailingWidget = IconButton(
                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                  tooltip: 'Xóa lịch hẹn',
                  onPressed: () => _deleteAppointment(appointment.id),
                );
              } else {
                // Hiển thị nút hủy cho lịch còn hiệu lực
                trailingWidget = IconButton(
                  icon: const Icon(Icons.cancel_outlined, color: Colors.orange),
                  tooltip: 'Hủy lịch hẹn',
                  onPressed: () => _cancelAppointment(appointment.id),
                );
              }

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  onTap: () {
                    context.goNamed(
                      'appointmentDetail',
                      pathParameters: {'appointmentId': appointment.id},
                      extra: appointment,
                    );
                  },
                  leading: CircleAvatar(
                    backgroundColor: statusColor,
                    child: Icon(statusIcon, color: Colors.white),
                  ),
                  title: Text(
                    'BS. ${appointment.doctor.fullName}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: isCancelled ? TextDecoration.lineThrough : null,
                      color: isCancelled ? Colors.grey[600] : null,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Bệnh nhân: ${appointment.patient?.fullName ?? 'N/A'}'),
                      Text('Ngày: ${DateFormatter.formatDate(appointment.date)}'),
                      Text('Giờ: ${appointment.slotStart}'),
                    ],
                  ),
                  trailing: trailingWidget,
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