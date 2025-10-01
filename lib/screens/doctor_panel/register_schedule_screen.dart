import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/doctor_panel_provider.dart';
import '../../providers/auth_provider.dart';

// --- LỚP HELPER MỚI ĐỂ QUẢN LÝ CA LÀM VIỆC ---
class WorkShift {
  final String name;
  final String startTime; // "HH:mm"
  final String endTime; // "HH:mm"
  bool isSelected;

  WorkShift({
    required this.name,
    required this.startTime,
    required this.endTime,
    this.isSelected = false,
  });
}

class DaySchedule {
  final String dayName; // Tên hiển thị (e.g., "Thứ Hai")
  final String dayValue; // Giá trị gửi đi (e.g., "Monday")
  final List<WorkShift> shifts;

  DaySchedule({
    required this.dayName,
    required this.dayValue,
    required this.shifts,
  });
}
// ----------------------------------------------

class RegisterScheduleScreen extends StatefulWidget {
  const RegisterScheduleScreen({super.key});

  @override
  State<RegisterScheduleScreen> createState() => _RegisterScheduleScreenState();
}

class _RegisterScheduleScreenState extends State<RegisterScheduleScreen> {
  late List<DaySchedule> _schedules;

  @override
  void initState() {
    super.initState();
    // Khởi tạo lịch làm việc mặc định cho 7 ngày trong tuần
    _schedules = [
      DaySchedule(dayName: 'Thứ Hai', dayValue: 'Monday', shifts: _createDefaultShifts()),
      DaySchedule(dayName: 'Thứ Ba', dayValue: 'Tuesday', shifts: _createDefaultShifts()),
      DaySchedule(dayName: 'Thứ Tư', dayValue: 'Wednesday', shifts: _createDefaultShifts()),
      DaySchedule(dayName: 'Thứ Năm', dayValue: 'Thursday', shifts: _createDefaultShifts()),
      DaySchedule(dayName: 'Thứ Sáu', dayValue: 'Friday', shifts: _createDefaultShifts()),
      DaySchedule(dayName: 'Thứ Bảy', dayValue: 'Saturday', shifts: _createDefaultShifts()),
      DaySchedule(dayName: 'Chủ Nhật', dayValue: 'Sunday', shifts: _createDefaultShifts()),
    ];
  }

  // Hàm tạo ra 4 ca làm việc mặc định
  List<WorkShift> _createDefaultShifts() {
    return [
      WorkShift(name: 'Ca 1 (Sáng)', startTime: '07:00', endTime: '11:00'),
      WorkShift(name: 'Ca 2 (Trưa)', startTime: '11:00', endTime: '13:00'),
      WorkShift(name: 'Ca 3 (Chiều)', startTime: '13:00', endTime: '17:00'),
      WorkShift(name: 'Ca 4 (Tối)', startTime: '17:00', endTime: '21:00'),
    ];
  }

  Future<void> _submitSchedules() async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token == null) return;
    
    final provider = Provider.of<DoctorPanelProvider>(context, listen: false);

    // Lọc ra tất cả các ca làm việc đã được chọn
    final List<Map<String, dynamic>> selectedSchedules = [];
    for (var daySchedule in _schedules) {
      for (var shift in daySchedule.shifts) {
        if (shift.isSelected) {
          selectedSchedules.add({
            'dayOfWeek': daySchedule.dayValue,
            'startTime': shift.startTime,
            'endTime': shift.endTime,
            'slotDuration': 30, // Giá trị mặc định, có thể thay đổi
          });
        }
      }
    }

    if (selectedSchedules.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ít nhất một ca làm việc.')),
      );
      return;
    }

    final success = await provider.registerSchedule(token: token, schedules: selectedSchedules);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng ký lịch thành công!'), backgroundColor: Colors.green),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${provider.errorMessage ?? "Thao tác thất bại"}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng ký lịch làm việc'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _schedules.length,
        itemBuilder: (context, index) {
          final daySchedule = _schedules[index];
          // Sử dụng ExpansionTile để giao diện gọn gàng hơn
          return Card(
            child: ExpansionTile(
              title: Text(daySchedule.dayName, style: const TextStyle(fontWeight: FontWeight.bold)),
              children: daySchedule.shifts.map((shift) {
                return CheckboxListTile(
                  title: Text(shift.name),
                  subtitle: Text('Thời gian: ${shift.startTime} - ${shift.endTime}'),
                  value: shift.isSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      shift.isSelected = value ?? false;
                    });
                  },
                );
              }).toList(),
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<DoctorPanelProvider>(
          builder: (context, provider, child) {
            return provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _submitSchedules,
                    child: const Text('Lưu lịch làm việc'),
                  );
          },
        ),
      ),
    );
  }
}

