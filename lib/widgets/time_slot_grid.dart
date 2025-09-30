
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/appointment_provider.dart';
import '../utils/date_formatter.dart';

class TimeSlotGrid extends StatelessWidget {
  const TimeSlotGrid({super.key});

  @override
  Widget build(BuildContext context) {
    // Lắng nghe sự thay đổi từ AppointmentProvider
    return Consumer<AppointmentProvider>(
      builder: (context, provider, child) {
        // 1. Xử lý trạng thái đang tải
        if (provider.isLoadingSlots) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        // 2. Xử lý khi có lỗi xảy ra
        if (provider.slotsError != null) {
          return Center(
            child: Text(
              'Lỗi: ${provider.slotsError}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        // 3. Xử lý khi không có khung giờ nào
        if (provider.availableSlots.isEmpty) {
          return const Center(
            child: Text('Không có lịch khám trống cho ngày này.'),
          );
        }

        // 4. Hiển thị lưới các khung giờ
        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(), // Vô hiệu hóa cuộn của GridView
          shrinkWrap: true, // Co lại để vừa với nội dung
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // Hiển thị 3 cột
            childAspectRatio: 2.5, // Tỷ lệ chiều rộng/chiều cao của mỗi ô
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: provider.availableSlots.length,
          itemBuilder: (context, index) {
            final slot = provider.availableSlots[index];
            final isSelected = provider.selectedSlot == slot.startTime;

            return ChoiceChip(
              label: Text(DateFormatter.formatTime(slot.startTime)),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  // Gọi hàm trong provider để cập nhật giờ đã chọn
                  provider.selectSlot(slot.startTime);
                }
              },
              selectedColor: Theme.of(context).primaryColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            );
          },
        );
      },
    );
  }
}

