import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/admin_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/doctor.dart';
import '../../../models/department.dart';

class EditDoctorScreen extends StatefulWidget {
  final String doctorId;
  const EditDoctorScreen({super.key, required this.doctorId});

  @override
  State<EditDoctorScreen> createState() => _EditDoctorScreenState();
}

class _EditDoctorScreenState extends State<EditDoctorScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  String? _selectedDepartmentId;
  bool _isActive = true;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();

    _isEditing = widget.doctorId != 'new';

    final adminProvider = Provider.of<AdminProvider>(context, listen: false);

    if (_isEditing) {
      // Sửa lỗi firstWhere bằng cách sử dụng try-catch để xử lý trường hợp không tìm thấy
      try {
        final initialDoctorData = adminProvider.allDoctors
            .firstWhere((doc) => doc.id == widget.doctorId);
        
        // Điền dữ liệu vào form
        _fullNameController.text = initialDoctorData.fullName;
        _emailController.text = initialDoctorData.email;
        _phoneController.text = initialDoctorData.phone ?? '';
        _isActive = initialDoctorData.isActive;
        _selectedDepartmentId = initialDoctorData.department.id;
      } catch (e) {
        // Nếu không tìm thấy bác sĩ trong provider, có thể quay lại hoặc hiển thị thông báo
        print("Không tìm thấy bác sĩ với ID: ${widget.doctorId} để chỉnh sửa.");
        // Cân nhắc tự động pop() nếu cần
        // WidgetsBinding.instance.addPostFrameCallback((_) => context.pop());
      }
    }
    
    // Tải danh sách các khoa
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      if (token != null) {
         adminProvider.fetchAllDepartments(token);
      }
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    
    final doctorData = {
      'fullName': _fullNameController.text,
      'email': _emailController.text,
      'phone': _phoneController.text,
      'isActive': _isActive,
      'department': _selectedDepartmentId,
    };

    bool success = false;
    if (_isEditing) {
      success = await adminProvider.updateDoctor(
          authProvider.token!, widget.doctorId, doctorData);
    } else {
      success = await adminProvider.createDoctor(authProvider.token!, doctorData);
    }

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Cập nhật thành công!' : 'Tạo mới thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop(); // Quay lại trang quản lý
      } else {
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Chỉnh sửa Bác sĩ' : 'Thêm Bác sĩ mới'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _fullNameController,
              decoration: const InputDecoration(labelText: 'Họ và Tên'),
              validator: (value) => (value == null || value.isEmpty) ? 'Vui lòng nhập họ tên' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              validator: (value) => (value == null || !value.contains('@')) ? 'Email không hợp lệ' : null,
            ),
             const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Số điện thoại'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            
            // Dropdown để chọn Khoa
            Consumer<AdminProvider>(
              builder: (context, provider, child) {
                // Hiển thị loading nếu danh sách khoa đang rỗng
                if (provider.allDepartments.isEmpty && provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                return DropdownButtonFormField<String>(
                  value: _selectedDepartmentId,
                  decoration: const InputDecoration(labelText: 'Khoa'),
                  items: provider.allDepartments.map((Department department) {
                    return DropdownMenuItem<String>(
                      value: department.id,
                      child: Text(department.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedDepartmentId = value;
                    });
                  },
                  validator: (value) => (value == null) ? 'Vui lòng chọn khoa' : null,
                );
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Trạng thái hoạt động'),
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
            ),
            const SizedBox(height: 32),
            Consumer<AdminProvider>(
              builder: (context, provider, child) => provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(_isEditing ? 'Lưu thay đổi' : 'Tạo mới'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

