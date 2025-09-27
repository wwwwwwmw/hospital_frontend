import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Call provider to change password
    final success = await authProvider.changePassword(
      oldPassword: _oldPasswordController.text,
      newPassword: _newPasswordController.text,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đổi mật khẩu thành công!'),
          backgroundColor: Colors.green,
        ),
      );
      context.pop(); // Quay lại trang trước đó
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${authProvider.errorMessage ?? "Đã có lỗi xảy ra"}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đổi mật khẩu')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _oldPasswordController,
                  decoration: const InputDecoration(labelText: 'Mật khẩu cũ'),
                  obscureText: true,
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Vui lòng nhập mật khẩu cũ' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _newPasswordController,
                  decoration: const InputDecoration(labelText: 'Mật khẩu mới'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Mật khẩu mới phải có ít nhất 6 ký tự';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(labelText: 'Xác nhận mật khẩu mới'),
                  obscureText: true,
                  validator: (value) {
                    if (value != _newPasswordController.text) {
                      return 'Mật khẩu xác nhận không khớp';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                Consumer<AuthProvider>(
                  builder: (context, auth, child) => auth.isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: const Text('Xác nhận'),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

