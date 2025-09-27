import 'package:intl/intl.dart';

class DateFormatter {
  // Định dạng ngày thành 'dd/MM/yyyy' (ví dụ: 27/09/2025)
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Định dạng giờ thành 'HH:mm' (ví dụ: 16:30)
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  // Định dạng đầy đủ ngày giờ (ví dụ: 16:30, 27/09/2025)
  static String formatDateTime(DateTime date) {
    return DateFormat('HH:mm, dd/MM/yyyy').format(date);
  }
}

