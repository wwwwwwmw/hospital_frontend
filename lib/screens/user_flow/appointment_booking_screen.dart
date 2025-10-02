
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/patient.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/doctor_list_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/patient_provider.dart';
import '../../utils/date_formatter.dart';

class AppointmentBookingScreen extends StatefulWidget {
  final String doctorId;
  const AppointmentBookingScreen({super.key, required this.doctorId});

  @override
  State<AppointmentBookingScreen> createState() =>
      _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends State<AppointmentBookingScreen> {
  String? _selectedPatientId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      final appointmentProvider =
          Provider.of<AppointmentProvider>(context, listen: false);
      
      appointmentProvider.selectDate(DateTime.now());
      Provider.of<DoctorListProvider>(context, listen: false)
          .fetchDoctorById(widget.doctorId);
      appointmentProvider.fetchAvailableSlots(widget.doctorId);

      if (token != null) {
        Provider.of<PatientProvider>(context, listen: false).fetchMyPatients(token);
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final provider = Provider.of<AppointmentProvider>(context, listen: false);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: provider.selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != provider.selectedDate) {
      provider.selectDate(picked);
      provider.fetchAvailableSlots(widget.doctorId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctorProvider = Provider.of<DoctorListProvider>(context);
    final appointmentProvider = Provider.of<AppointmentProvider>(context);
    final patientProvider = Provider.of<PatientProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final doctor = doctorProvider.selectedDoctor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đặt lịch hẹn'),
      ),
      body: doctor == null || (patientProvider.isLoading && patientProvider.myPatients.isEmpty)
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bác sĩ: ${doctor.fullName}',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 24),

                  Text('1. Chọn bệnh nhân',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedPatientId,
                    hint: const Text('Chọn hồ sơ bệnh nhân'),
                    isExpanded: true,
                    items: patientProvider.myPatients.map((Patient patient) {
                      return DropdownMenuItem<String>(
                        value: patient.id,
                        child: Text(patient.fullName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedPatientId = value;
                      });
                    },
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    validator: (v) => v == null ? 'Vui lòng chọn bệnh nhân' : null,
                  ),
                  const Divider(height: 32),

                  Text('2. Chọn ngày khám',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          DateFormatter.formatDate(appointmentProvider.selectedDate),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.normal)
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _selectDate(context),
                      ),
                    ],
                  ),
                  const Divider(height: 32),

                  Text('3. Chọn ca khám',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  
                  _buildShiftList(appointmentProvider),
                ],
              ),
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: (_selectedPatientId == null || 
                      appointmentProvider.selectedShift == null || // <<< SỬA
                      appointmentProvider.isBooking)
              ? null
              : () async {
                  final success = await appointmentProvider.createAppointment(
                    token: authProvider.token!,
                    patientId: _selectedPatientId!,
                    doctorId: widget.doctorId,
                  );
                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Đặt lịch thành công! Hệ thống đã tự động chọn giờ trống sớm nhất trong ca cho bạn.'), 
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 4),
                    ));
                    context.pop(); 
                  } else if (mounted && appointmentProvider.bookingError != null) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Lỗi: ${appointmentProvider.bookingError}'),
                        backgroundColor: Colors.red,
                      ));
                  }
                },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: appointmentProvider.isBooking 
              ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white,))
              : const Text('Xác nhận đặt lịch'),
        ),
      ),
    );
  }

  /// Widget mới: Hiển thị danh sách các ca làm việc có thể chọn
  Widget _buildShiftList(AppointmentProvider provider) {
    if (provider.isLoadingSlots) {
      return const Center(child: Padding(
        padding: EdgeInsets.symmetric(vertical: 32.0),
        child: CircularProgressIndicator(),
      ));
    }
    if (provider.slotsError != null) {
      return Center(child: Text('Lỗi tải lịch khám: ${provider.slotsError}'));
    }
    if (provider.availableShifts.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.symmetric(vertical: 32.0),
        child: Text('Không có lịch khám trống cho ngày này.'),
      ));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.availableShifts.length,
      itemBuilder: (context, index) {
        final shift = provider.availableShifts[index];
        final isFull = shift.bookedCount >= shift.capacity;
        final isSelected = provider.selectedShift?.start == shift.start;

        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          child: ListTile(
            selected: isSelected,
            selectedTileColor: Theme.of(context).primaryColor.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: BorderSide(
                color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
                width: 1.5,
              ),
            ),
            title: Text(
              'Ca làm việc: ${shift.shiftName}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Còn trống: ${shift.capacity - shift.bookedCount}/${shift.capacity}',
              style: TextStyle(
                color: isFull ? Colors.red : Colors.green.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: isFull 
                ? const Chip(label: Text('Đã đầy'), backgroundColor: Colors.red, labelStyle: TextStyle(color: Colors.white)) 
                : const Icon(Icons.check_circle_outline, color: Colors.grey),
            onTap: isFull ? null : () {
              provider.selectShift(shift);
            },
          ),
        );
      },
    );
  }
}