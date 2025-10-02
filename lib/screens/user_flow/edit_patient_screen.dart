import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/patient.dart';
import '../../providers/auth_provider.dart';
import '../../providers/patient_provider.dart';
import '../../utils/date_formatter.dart';

class EditPatientScreen extends StatefulWidget {
  final String patientId;
  const EditPatientScreen({super.key, required this.patientId});

  @override
  State<EditPatientScreen> createState() => _EditPatientScreenState();
}

class _EditPatientScreenState extends State<EditPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  DateTime? _selectedDate;
  String? _selectedGender;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _phoneController = TextEditingController();
    _isEditing = widget.patientId != 'new';

    if (_isEditing) {
      final patient = Provider.of<PatientProvider>(context, listen: false)
          .myPatients
          .firstWhere((p) => p.id == widget.patientId);
      _fullNameController.text = patient.fullName;
      _phoneController.text = patient.phone;
      _selectedDate = patient.dob;
      _selectedGender = patient.gender;
    }
  }
  
  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final token = Provider.of<AuthProvider>(context, listen: false).token!;
    final provider = Provider.of<PatientProvider>(context, listen: false);

    final data = {
      'fullName': _fullNameController.text,
      'phone': _phoneController.text,
      'dob': _selectedDate!.toIso8601String(),
      'gender': _selectedGender!,
    };
    
    bool success;
    if (_isEditing) {
      success = await provider.updatePatient(token: token, patientId: widget.patientId, patientData: data);
    } else {
      success = await provider.createPatient(token: token, patientData: data);
    }

    if (mounted && success) {
      context.pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${provider.errorMessage}'), backgroundColor: Colors.red),
      );
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
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Sửa thông tin' : 'Thêm Bệnh nhân')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _fullNameController,
              decoration: const InputDecoration(labelText: 'Họ và Tên'),
              validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập họ tên' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Số điện thoại liên hệ'),
              keyboardType: TextInputType.phone,
              validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập SĐT' : null,
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(_selectedDate == null ? 'Chọn ngày sinh' : 'Ngày sinh: ${DateFormatter.formatDate(_selectedDate!)}'),
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
              onChanged: (value) => setState(() => _selectedGender = value),
              validator: (v) => (v == null) ? 'Vui lòng chọn giới tính' : null,
            ),
            const SizedBox(height: 32),
            Consumer<PatientProvider>(
              builder: (context, provider, child) => provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _submitForm,
                    child: Text(_isEditing ? 'Lưu thay đổi' : 'Thêm mới'),
                  ),
            )
          ],
        ),
      ),
    );
  }
}