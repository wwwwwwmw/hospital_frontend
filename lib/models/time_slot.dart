// Đây là một model đơn giản, không cần json_serializable
// vì chúng ta tự tạo ra nó từ logic của backend
class TimeSlot {
  final DateTime startTime;
  final bool isBooked;

  TimeSlot({required this.startTime, required this.isBooked});
}
