import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/doctor.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';

// Lớp helper để quản lý trạng thái UI
class WorkShift {
  final String name;
  final String startTime;
  final String endTime;
  bool isSelected;

  WorkShift({
    required this.name,
    required this.startTime,
    required this.endTime,
    this.isSelected = false,
  });
}

class DaySchedule {
  final String dayName;
  final int weekday;
  final List<WorkShift> shifts;

  DaySchedule({required this.dayName, required this.weekday, required this.shifts});
}

class ManageSchedulesScreen extends StatefulWidget {
  const ManageSchedulesScreen({super.key});

  @override
  State<ManageSchedulesScreen> createState() => _ManageSchedulesScreenState();
}

class _ManageSchedulesScreenState extends State<ManageSchedulesScreen> {
  String? _selectedDoctorId;
  List<DaySchedule> _weeklyScheduleState = [];
  bool _isDataMapped = false;

  @override
  void initState() {
    super.initState();
    _initializeScheduleState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      if (token != null) {
        Provider.of<AdminProvider>(context, listen: false).fetchAllDoctors(token: token);
      }
    });
  }

  void _initializeScheduleState() {
    final dayNames = ['Chủ Nhật', 'Thứ Hai', 'Thứ Ba', 'Thứ Tư', 'Thứ Năm', 'Thứ Sáu', 'Thứ Bảy'];
    _weeklyScheduleState = List.generate(7, (i) {
      return DaySchedule(
        dayName: dayNames[i],
        weekday: i,
        shifts: _createDefaultShifts(),
      );
    });
    // Sắp xếp lại để Thứ Hai lên đầu
    _weeklyScheduleState.sort((a, b) => a.weekday == 0 ? 1 : (b.weekday == 0 ? -1 : a.weekday.compareTo(b.weekday)));
  }

  List<WorkShift> _createDefaultShifts() => [
    WorkShift(name: 'Ca 1 (Sáng)', startTime: '07:00', endTime: '11:00'),
    WorkShift(name: 'Ca 2 (Trưa)', startTime: '11:00', endTime: '13:00'),
    WorkShift(name: 'Ca 3 (Chiều)', startTime: '13:00', endTime: '17:00'),
    WorkShift(name: 'Ca 4 (Tối)', startTime: '17:00', endTime: '21:00'),
  ];
  
  void _onDoctorSelected(String? doctorId) {
    if (doctorId == null) return;
    setState(() {
      _selectedDoctorId = doctorId;
      _isDataMapped = false; // Reset cờ khi chọn bác sĩ mới
    });
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token != null) {
      Provider.of<AdminProvider>(context, listen: false)
          .fetchWeeklyScheduleForDoctor(token: token, doctorId: doctorId);
    }
  }

  void _mapProviderDataToState(AdminProvider provider) {
     _initializeScheduleState(); // Reset về mặc định trước khi map
     for (var schedule in provider.selectedDoctorSchedule) {
       final dayState = _weeklyScheduleState.firstWhere((d) => d.weekday == schedule.weekday);
       for (var block in schedule.blocks) {
         try {
           final shiftState = dayState.shifts.firstWhere((s) => s.startTime == block.start && s.endTime == block.end);
           shiftState.isSelected = true;
         } catch(e) {
            print('Could not find matching shift for block: ${block.start}-${block.end}');
         }
       }
     }
  }

  Future<void> _submitSchedules() async {
    if (_selectedDoctorId == null) return;

    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token == null) return;
    
    final provider = Provider.of<AdminProvider>(context, listen: false);

    final Map<int, List<Map<String, dynamic>>> groupedSchedules = {};
    for (var daySchedule in _weeklyScheduleState) {
      final selectedShifts = daySchedule.shifts.where((s) => s.isSelected).toList();
      
      groupedSchedules[daySchedule.weekday] = selectedShifts.map((shift) {
        return {
          'start': shift.startTime,
          'end': shift.endTime,
          'slotDurationMin': 30,
          'capacityPerSlot': 1,
        };
      }).toList();
    }

    final success = await provider.updateWeeklyScheduleForDoctor(
        token: token,
        doctorId: _selectedDoctorId!,
        groupedSchedules: groupedSchedules);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success ? 'Cập nhật lịch thành công!' : 'Lỗi: ${provider.errorMessage}'),
        backgroundColor: success ? Colors.green : Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý Lịch làm việc')),
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {

          // Logic để map dữ liệu từ provider sang state của UI một lần duy nhất
          if (_selectedDoctorId != null && !_isDataMapped && !provider.isLoading) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _mapProviderDataToState(provider);
                  _isDataMapped = true; // Đánh dấu đã map xong
                });
              }
            });
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: DropdownButtonFormField<String>(
                  value: _selectedDoctorId,
                  hint: const Text('Chọn một bác sĩ'),
                  isExpanded: true,
                  items: provider.allDoctors.map((Doctor doctor) {
                    return DropdownMenuItem<String>(
                      value: doctor.id,
                      child: Text(doctor.fullName),
                    );
                  }).toList(),
                  onChanged: _onDoctorSelected,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Bác sĩ',
                  ),
                ),
              ),
              if (_selectedDoctorId != null)
                Expanded(
                  child: provider.isLoading && !_isDataMapped
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          itemCount: _weeklyScheduleState.length,
                          itemBuilder: (context, index) {
                            final day = _weeklyScheduleState[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8.0),
                              child: ExpansionTile(
                                title: Text(day.dayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                initiallyExpanded: true,
                                children: day.shifts.map((shift) {
                                  return CheckboxListTile(
                                    title: Text(shift.name),
                                    subtitle: Text('${shift.startTime} - ${shift.endTime}'),
                                    value: shift.isSelected,
                                    onChanged: (bool? value) {
                                      setState(() => shift.isSelected = value ?? false);
                                    },
                                  );
                                }).toList(),
                              ),
                            );
                          },
                        ),
                )
            ],
          );
        },
      ),
      bottomNavigationBar: _selectedDoctorId == null
          ? null
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Consumer<AdminProvider>(
                 builder: (context, provider, child) {
                   return ElevatedButton(
                     style: ElevatedButton.styleFrom(
                       minimumSize: const Size(double.infinity, 48),
                     ),
                     onPressed: provider.isLoading ? null : _submitSchedules,
                     child: provider.isLoading && _isDataMapped
                         ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3,))
                         : const Text('Lưu thay đổi'),
                   );
                 }
              ),
            ),
    );
  }
}