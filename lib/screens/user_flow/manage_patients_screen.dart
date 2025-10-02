import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/patient.dart';
import '../../providers/auth_provider.dart';
import '../../providers/patient_provider.dart';

class ManagePatientsScreen extends StatefulWidget {
  const ManagePatientsScreen({super.key});

  @override
  State<ManagePatientsScreen> createState() => _ManagePatientsScreenState();
}

class _ManagePatientsScreenState extends State<ManagePatientsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      if (token != null) {
        Provider.of<PatientProvider>(context, listen: false).fetchMyPatients(token);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thông tin Bệnh nhân')),
      body: Consumer<PatientProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.myPatients.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.myPatients.isEmpty) {
            return const Center(child: Text('Chưa có hồ sơ bệnh nhân nào.'));
          }
          return ListView.builder(
            itemCount: provider.myPatients.length,
            itemBuilder: (context, index) {
              final patient = provider.myPatients[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(patient.fullName),
                  subtitle: Text('Giới tính: ${patient.gender}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => context.go('/manage-patients/edit/${patient.id}'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deletePatient(context, patient),
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
        onPressed: () => context.go('/manage-patients/edit/new'),
        child: const Icon(Icons.add),
        tooltip: 'Thêm Bệnh nhân',
      ),
    );
  }

  Future<void> _deletePatient(BuildContext context, Patient patient) async {
    final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text('Xác nhận Xóa'),
              content: Text('Bạn có chắc muốn xóa hồ sơ của "${patient.fullName}"?'),
              actions: [
                TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Hủy')),
                TextButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: const Text('Xóa', style: TextStyle(color: Colors.red))),
              ],
            ));

    if (confirm == true) {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      if (token != null) {
        await Provider.of<PatientProvider>(context, listen: false)
            .deletePatient(token: token, patientId: patient.id);
      }
    }
  }
}