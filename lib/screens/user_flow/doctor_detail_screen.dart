import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/doctor_list_provider.dart';

class DoctorDetailScreen extends StatefulWidget {
  final String doctorId;
  const DoctorDetailScreen({super.key, required this.doctorId});

  @override
  State<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Gọi provider để lấy dữ liệu chi tiết ngay khi màn hình được tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DoctorListProvider>(context, listen: false)
          .fetchDoctorById(widget.doctorId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thông tin Bác sĩ')),
      body: Consumer<DoctorListProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading || provider.selectedDoctor == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final doctor = provider.selectedDoctor!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      doctor.fullName,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    // Hiển thị tên Khoa
                    Text(
                      doctor.department.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.email_outlined),
                      title: const Text('Email'),
                      subtitle: Text(doctor.email ?? 'Chưa cập nhật'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.phone_outlined),
                      title: const Text('Số điện thoại'),
                      // SỬA Ở ĐÂY: Dùng toán tử '??' để cung cấp giá trị mặc định
                      subtitle: Text(doctor.phone ?? 'Chưa cập nhật'),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.calendar_month),
                        label: const Text('Đặt lịch hẹn'),
                        onPressed: () {
                          // Điều hướng đến trang đặt lịch hẹn
                          context.go('/book-appointment/${doctor.id}');
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
