// lib/screens/doctor/doctor_list_screen.dart

import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/doctor_provider.dart';

class DoctorListScreen extends StatefulWidget {
  const DoctorListScreen({super.key});

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  // Hàm này được gọi một lần duy nhất khi widget được tạo ra
  @override
  void initState() {
    super.initState();
    // Dùng WidgetsBinding để đảm bảo việc gọi provider được thực hiện
    // sau khi cây widget đã được build xong, tránh các lỗi không mong muốn.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Gọi provider để lấy dữ liệu, listen: false vì ta chỉ cần gọi hàm,
      // không cần lắng nghe sự thay đổi ở đây.
      Provider.of<DoctorProvider>(context, listen: false).fetchDoctors();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách Bác sĩ'),
        actions: [
          // Nút refresh để gọi lại API
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<DoctorProvider>(context, listen: false).fetchDoctors();
            },
          ),
        ],
      ),
      // Consumer lắng nghe sự thay đổi từ DoctorProvider
      body: Consumer<DoctorProvider>(
        builder: (context, provider, child) {
          // Nếu đang loading, hiển thị vòng xoay
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Nếu có lỗi, hiển thị thông báo lỗi
          if (provider.errorMessage != null) {
            return Center(child: Text('Đã xảy ra lỗi: ${provider.errorMessage}'));
          }

          // Nếu danh sách rỗng, hiển thị thông báo
          if (provider.doctors.isEmpty) {
            return const Center(child: Text('Không có dữ liệu bác sĩ.'));
          }

          // Nếu có dữ liệu, hiển thị danh sách
          return ListView.builder(
            itemCount: provider.doctors.length,
            itemBuilder: (context, index) {
              final doctor = provider.doctors[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.person_outline),
                  ),
                  title: Text(doctor.fullName),
                  subtitle: Text(doctor.email),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Dùng go_router để điều hướng đến màn hình chi tiết
                    // và truyền ID của bác sĩ qua đường dẫn
                    context.go('/doctor_details/${doctor.id}');
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}