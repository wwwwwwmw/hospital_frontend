import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/admin_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/user.dart';
import '../../../models/patient.dart'; // Import Patient model for casting

class UserDetailScreen extends StatefulWidget {
  final String userId;
  const UserDetailScreen({super.key, required this.userId});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  User? _user;
  String? _selectedRole;

  @override
  void initState() {
    super.initState();
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    final token = Provider.of<AuthProvider>(context, listen: false).token;

    try {
      _user = adminProvider.allUsers.firstWhere((u) => u.id == widget.userId);
      _selectedRole = _user?.role;
      
      // Chỉ tải danh sách bệnh nhân nếu vai trò là patient_guardian
      if (token != null && _selectedRole == 'patient_guardian') {
        adminProvider.fetchPatientsForUser(token: token, userId: widget.userId);
      }
    } catch(e) {
      print('User not found in provider, should fetch');
       WidgetsBinding.instance.addPostFrameCallback((_) {
        if(mounted) Navigator.of(context).pop();
      });
    }
  }

  Future<void> _updateRole() async {
    if (_selectedRole == null || _user == null || _selectedRole == _user!.role) return;

    final token = Provider.of<AuthProvider>(context, listen: false).token;
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);

    if (token == null) return;
    
    final success = await adminProvider.updateUser(
      token: token,
      userId: _user!.id,
      userData: {'role': _selectedRole},
    );

    if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Cập nhật vai trò thành công!' : 'Lỗi: ${adminProvider.errorMessage}'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('Không tìm thấy người dùng.')));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(_user!.fullName),
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Edit Role section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Thông tin người dùng', style: Theme.of(context).textTheme.titleLarge),
                      const Divider(height: 24),
                      Text('Email: ${_user!.email}'),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedRole,
                        decoration: const InputDecoration(labelText: 'Vai trò'),
                        // SỬA Ở ĐÂY: Bổ sung vai trò 'doctor'
                        items: ['patient_guardian', 'doctor', 'staff', 'admin'].map((role) => 
                          DropdownMenuItem(value: role, child: Text(role))
                        ).toList(),
                        onChanged: (value) {
                           setState(() => _selectedRole = value);
                           // Tải lại danh sách bệnh nhân nếu vai trò mới là patient_guardian
                           if (value == 'patient_guardian') {
                             final token = Provider.of<AuthProvider>(context, listen: false).token;
                             if (token != null) {
                                provider.fetchPatientsForUser(token: token, userId: widget.userId);
                             }
                           }
                        }
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _updateRole,
                          child: const Text('Lưu thay đổi vai trò'),
                        ),
                      )
                    ],
                  ),
                ),
              ),

              // Chỉ hiển thị phần này nếu vai trò là 'patient_guardian'
              if (_selectedRole == 'patient_guardian') ...[
                const SizedBox(height: 24),
                Text('Các bệnh nhân được bảo hộ', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),

                if(provider.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if(provider.patientsForSelectedUser.isEmpty)
                  const Center(child: Text('Người dùng này chưa bảo hộ cho bệnh nhân nào.'))
                else
                  ...provider.patientsForSelectedUser.map((patient) => Card(
                    child: ListTile(
                      title: Text(patient.fullName),
                      subtitle: Text('Giới tính: ${patient.gender} - SĐT: ${patient.phone}'),
                    ),
                  )).toList(),
              ],
            ],
          );
        },
      ),
    );
  }
}

