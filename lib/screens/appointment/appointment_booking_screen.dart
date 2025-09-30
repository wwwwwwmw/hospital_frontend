import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/doctor_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/time_slot_grid.dart';
import '../../utils/date_formatter.dart';

class AppointmentBookingScreen extends StatefulWidget {
  final String doctorId;
  const AppointmentBookingScreen({super.key, required this.doctorId});

  @override
  State<AppointmentBookingScreen> createState() =>
      _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends State<AppointmentBookingScreen> {
  @override
  void initState() {
    super.initState();
    // Chạy code sau khi frame đầu tiên được build xong
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appointmentProvider =
          Provider.of<AppointmentProvider>(context, listen: false);
      
      // Reset trạng thái và tải dữ liệu cần thiết
      appointmentProvider.selectDate(DateTime.now()); // Luôn bắt đầu với ngày hôm nay
      Provider.of<DoctorProvider>(context, listen: false)
          .fetchDoctorById(widget.doctorId);
      appointmentProvider.fetchAvailableSlots(widget.doctorId);
    });
  }

  // Hàm hiển thị cửa sổ chọn ngày
  Future<void> _selectDate(BuildContext context) async {
    final provider = Provider.of<AppointmentProvider>(context, listen: false);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: provider.selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)), // Cho phép đặt trước 30 ngày
    );
    // Nếu người dùng chọn một ngày mới
    if (picked != null && picked != provider.selectedDate) {
      provider.selectDate(picked);
      // Tải lại các khung giờ trống cho ngày mới được chọn
      provider.fetchAvailableSlots(widget.doctorId);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lấy các provider để sử dụng
    final doctorProvider = Provider.of<DoctorProvider>(context);
    final appointmentProvider = Provider.of<AppointmentProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final doctor = doctorProvider.selectedDoctor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đặt lịch hẹn'),
      ),
      body: doctor == null
          ? const Center(child: CircularProgressIndicator()) // Hiển thị loading khi chưa có thông tin bác sĩ
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bác sĩ: ${doctor.fullName}',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 24),

                  Text('1. Chọn ngày khám',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          // SỬA Ở ĐÂY: Đổi tên hàm thành formatDate
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

                  Text('2. Chọn giờ khám',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  const TimeSlotGrid(), // Widget hiển thị các khung giờ
                ],
              ),
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          // Vô hiệu hóa nút nếu chưa chọn giờ hoặc đang tải
          onPressed: (appointmentProvider.selectedSlot == null ||
                  appointmentProvider.isBooking)
              ? null
              : () async {
                  if (authProvider.token == null) {
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.'),
                        backgroundColor: Colors.red,
                      ));
                      return;
                  }
                  final success =
                      await appointmentProvider.createAppointment(
                    token: authProvider.token!,
                    doctorId: widget.doctorId,
                  );
                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Đặt lịch thành công!'), backgroundColor: Colors.green,));
                    context.pop(); // Quay lại màn hình trước đó
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
}

