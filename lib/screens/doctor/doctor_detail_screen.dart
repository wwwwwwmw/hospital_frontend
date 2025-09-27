import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/doctor_provider.dart';

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
      Provider.of<DoctorProvider>(context, listen: false)
          .fetchDoctorById(widget.doctorId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thông tin Bác sĩ')),
      body: Consumer<DoctorProvider>(
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
                    const SizedBox(height: 16),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.email_outlined),
                      title: const Text('Email'),
                      subtitle: Text(doctor.email),
                    ),
                    ListTile(
                      leading: const Icon(Icons.phone_outlined),
                      title: const Text('Số điện thoại'),
                      subtitle: Text(doctor.phone),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.calendar_month),
                        label: const Text('Đặt lịch hẹn'),
                        onPressed: () {
                          // Chức năng đặt lịch hẹn sẽ làm ở bước tiếp theo
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