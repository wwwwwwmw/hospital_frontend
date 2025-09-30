import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/patient_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/patient.dart';
import '../../utils/date_formatter.dart';

class EditPatientProfileScreen extends StatefulWidget {
  const EditPatientProfileScreen({super.key});

  @override
  State<EditPatientProfileScreen> createState() =>
      _EditPatientProfileScreenState();
}

class _EditPatientProfileScreenState extends State<EditPatientProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  DateTime? _selectedDate;
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _phoneController = TextEditingController();

    // Lấy token và tải thông tin hồ sơ
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final patientProvider = Provider.of<PatientProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (authProvider.token != null) {
        await patientProvider.fetchMyPatientProfile(authProvider.token!);
        // Sau khi tải xong, điền thông tin vào form
        if (patientProvider.myProfile != null) {
          _populateForm(patientProvider.myProfile!);
        }
      }
    });
  }

  // Hàm để điền dữ liệu từ patient profile vào các controller
  void _populateForm(Patient profile) {
    _fullNameController.text = profile.fullName;
    _phoneController.text = profile.phone;
    setState(() {
      _selectedDate = profile.dob;
      _selectedGender = profile.gender;
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final patientProvider = Provider.of<PatientProvider>(context, listen: false);

    final Map<String, dynamic> updatedData = {
      'fullName': _fullNameController.text,
      'phone': _phoneController.text,
      'dob': _selectedDate?.toIso8601String(),
      'gender': _selectedGender,
    };

    final success = await patientProvider.updateMyPatientProfile(
        authProvider.token!, updatedData);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật thông tin thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop(); // Quay lại trang profile
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${patientProvider.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa thông tin'),
      ),
      body: Consumer<PatientProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.myProfile == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.errorMessage != null && provider.myProfile == null) {
            return Center(child: Text('Lỗi: ${provider.errorMessage}'));
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(labelText: 'Họ và Tên'),
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Vui lòng nhập họ tên' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Số điện thoại'),
                   validator: (value) =>
                      (value == null || value.isEmpty) ? 'Vui lòng nhập số điện thoại' : null,
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(_selectedDate == null
                      ? 'Chọn ngày sinh'
                      : 'Ngày sinh: ${DateFormatter.formatDate(_selectedDate!)}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _selectDate(context),
                ),
                 const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: const InputDecoration(labelText: 'Giới tính'),
                  items: const [
                    DropdownMenuItem(value: 'male', child: Text('Nam')),
                    DropdownMenuItem(value: 'female', child: Text('Nữ')),
                    DropdownMenuItem(value: 'other', child: Text('Khác')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                   validator: (value) => (value == null) ? 'Vui lòng chọn giới tính' : null,
                ),
                const SizedBox(height: 32),
                 provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Lưu thay đổi'),
                      ),
              ],
            ),
          );
        },
      ),
    );
  }
}
