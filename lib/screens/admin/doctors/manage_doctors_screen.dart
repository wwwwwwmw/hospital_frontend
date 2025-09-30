
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/admin_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/doctor.dart';

class ManageDoctorsScreen extends StatefulWidget {
  const ManageDoctorsScreen({super.key});

  @override
  State<ManageDoctorsScreen> createState() => _ManageDoctorsScreenState();
}

class _ManageDoctorsScreenState extends State<ManageDoctorsScreen> {
  @override
  void initState() {
    super.initState();
    // Tải danh sách bác sĩ ngay khi màn hình được tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      if (token != null) {
        Provider.of<AdminProvider>(context, listen: false).fetchAllDoctors(token);
      }
    });
  }

  // Hàm xử lý xóa bác sĩ
  Future<void> _deleteDoctor(Doctor doctor) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa bác sĩ "${doctor.fullName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && authProvider.token != null) {
      final success = await adminProvider.deleteDoctor(authProvider.token!, doctor.id);
      if (mounted && !success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${adminProvider.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final token = Provider.of<AuthProvider>(context, listen: false).token;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Bác sĩ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (token != null) {
                Provider.of<AdminProvider>(context, listen: false).fetchAllDoctors(token);
              }
            },
          ),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.errorMessage != null && provider.allDoctors.isEmpty) {
            return Center(child: Text('Lỗi: ${provider.errorMessage}'));
          }
          if (provider.allDoctors.isEmpty) {
            return const Center(child: Text('Không có bác sĩ nào trong hệ thống.'));
          }

          return ListView.builder(
            itemCount: provider.allDoctors.length,
            itemBuilder: (context, index) {
              final doctor = provider.allDoctors[index];
              return Card(
                child: ListTile(
                  title: Text(doctor.fullName),
                  subtitle: Text(doctor.email),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: doctor.isActive,
                        onChanged: (value) {
                          // TODO: Implement logic to update isActive status
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () {
                          context.go('/admin/edit-doctor/${doctor.id}');
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: Colors.red[700]),
                        onPressed: () => _deleteDoctor(doctor),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 'new' là một ID đặc biệt để màn hình edit biết đây là tạo mới
          context.go('/admin/edit-doctor/new');
        },
        child: const Icon(Icons.add),
        tooltip: 'Thêm bác sĩ mới',
      ),
    );
  }
}
