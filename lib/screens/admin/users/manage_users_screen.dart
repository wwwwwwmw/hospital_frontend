import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/admin_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/user.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      if (token != null) {
        Provider.of<AdminProvider>(context, listen: false).fetchAllUsers(token: token);
      }
    });
  }

  Future<void> _deleteUser(User user) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa người dùng "${user.fullName}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Hủy')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && authProvider.token != null) {
      final success = await adminProvider.deleteUser(token: authProvider.token!, userId: user.id);
      if (mounted && !success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${adminProvider.errorMessage ?? "Không thể xóa"}'),
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
        title: const Text('Quản lý Người dùng'),
         actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (token != null) {
                Provider.of<AdminProvider>(context, listen: false).fetchAllUsers(token: token);
              }
            },
          ),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.allUsers.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
           if (provider.errorMessage != null && provider.allUsers.isEmpty) {
            return Center(child: Text('Lỗi: ${provider.errorMessage}'));
          }
          if (provider.allUsers.isEmpty) {
            return const Center(child: Text('Không có người dùng nào.'));
          }
          return ListView.builder(
            itemCount: provider.allUsers.length,
            itemBuilder: (context, index) {
              final user = provider.allUsers[index];
              return Card(
                child: ListTile(
                  title: Text(user.fullName),
                  subtitle: Text(user.email),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_note_outlined),
                        tooltip: 'Xem chi tiết & Sửa',
                        onPressed: () => context.go('/admin/manage-users/details/${user.id}'),
                      ),
                       IconButton(
                        icon: Icon(Icons.delete_outline, color: Colors.red[700]),
                        tooltip: 'Xóa người dùng',
                        onPressed: () => _deleteUser(user),
                      ),
                    ],
                  )
                ),
              );
            },
          );
        },
      ),
    );
  }
}
