import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/doctor_panel_provider.dart';
import '../../providers/auth_provider.dart';

// --- LỚP HELPER ĐỂ QUẢN LÝ CA LÀM VIỆC ---
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
  final String dayValue; // Giá trị để mapping (e.g., "Monday")
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

  // HÀM HELPER: Chuyển đổi giá trị ngày (String) sang số (int) mà backend yêu cầu
  // Theo chuẩn JavaScript: 0 = Chủ Nhật, 1 = Thứ Hai, ..., 6 = Thứ Bảy
  int _dayValueToWeekday(String dayValue) {
    switch (dayValue) {
      case 'Sunday': return 0;
      case 'Monday': return 1;
      case 'Tuesday': return 2;
      case 'Wednesday': return 3;
      case 'Thursday': return 4;
      case 'Friday': return 5;
      case 'Saturday': return 6;
      default: return -1; // Giá trị không hợp lệ
    }
  }

  // === HÀM QUAN TRỌNG NHẤT: ĐÃ ĐƯỢC CẬP NHẬT LOGIC HOÀN TOÀN ===
  Future<void> _submitSchedules() async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token == null) return;
    
    final provider = Provider.of<DoctorPanelProvider>(context, listen: false);

    // 1. Nhóm các ca đã chọn theo ngày (weekday) và chuyển đổi dữ liệu
    final Map<int, List<Map<String, dynamic>>> groupedSchedules = {};

    for (var daySchedule in _schedules) {
      // Lọc ra các ca được chọn cho ngày hiện tại
      final selectedShifts = daySchedule.shifts.where((s) => s.isSelected).toList();

      // Nếu có ca được chọn trong ngày này
      if (selectedShifts.isNotEmpty) {
        final weekday = _dayValueToWeekday(daySchedule.dayValue);
        if (weekday != -1) {
          // 2. Chuyển đổi danh sách ca làm việc sang định dạng mà backend yêu cầu
          groupedSchedules[weekday] = selectedShifts.map((shift) {
            return {
              'start': shift.startTime,     // Đổi tên key: 'startTime' -> 'start'
              'end': shift.endTime,         // Đổi tên key: 'endTime' -> 'end'
              'slotDurationMin': 30,        // Đổi tên key và đặt giá trị
              'capacityPerSlot': 1,         // Thêm key còn thiếu
            };
          }).toList();
        }
      }
    }

    if (groupedSchedules.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ít nhất một ca làm việc.')),
      );
      return;
    }

    // 3. Gọi hàm mới trong provider với dữ liệu đã được nhóm và định dạng lại
    final success = await provider.registerSchedulesForWeek(
      token: token, 
      groupedSchedules: groupedSchedules
    );

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
            margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            child: ExpansionTile(
              title: Text(daySchedule.dayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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