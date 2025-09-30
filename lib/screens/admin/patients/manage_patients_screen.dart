import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/admin_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/patient.dart';

class ManagePatientsScreen extends StatefulWidget {
  const ManagePatientsScreen({super.key});

  @override
  State<ManagePatientsScreen> createState() => _ManagePatientsScreenState();
}

class _ManagePatientsScreenState extends State<ManagePatientsScreen> {
  @override
  void initState() {
    super.initState();
    // Tải danh sách bệnh nhân ngay khi màn hình được tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      if (token != null) {
        Provider.of<AdminProvider>(context, listen: false).fetchAllPatients(token);
      }
    });
  }

  // Placeholder for delete action
  Future<void> _deletePatient(Patient patient) async {
    // Logic for deleting a patient will go here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chức năng xóa bệnh nhân đang được phát triển')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final token = Provider.of<AuthProvider>(context, listen: false).token;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Bệnh nhân'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (token != null) {
                Provider.of<AdminProvider>(context, listen: false).fetchAllPatients(token);
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
          if (provider.errorMessage != null && provider.allPatients.isEmpty) {
            return Center(child: Text('Lỗi: ${provider.errorMessage}'));
          }
          if (provider.allPatients.isEmpty) {
            return const Center(child: Text('Không có bệnh nhân nào trong hệ thống.'));
          }

          return ListView.builder(
            itemCount: provider.allPatients.length,
            itemBuilder: (context, index) {
              final patient = provider.allPatients[index];
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person_outline)),
                  title: Text(patient.fullName),
                  subtitle: Text(patient.phone),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: 'Sửa',
                        onPressed: () {
                          // Logic to navigate to an edit patient screen
                           ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Chức năng sửa bệnh nhân đang được phát triển')),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: Colors.red[700]),
                        tooltip: 'Xóa',
                        onPressed: () => _deletePatient(patient),
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
          // Logic to navigate to a create patient screen
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Chức năng thêm bệnh nhân đang được phát triển')),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Thêm bệnh nhân mới',
      ),
    );
  }
}
