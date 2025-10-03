
import 'package:flutter/material.dart';

import '../../models/appointment.dart';
import '../../utils/date_formatter.dart';

class AppointmentDetailScreen extends StatelessWidget {
  final Appointment appointment;

  const AppointmentDetailScreen({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết Lịch hẹn'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailCard(
              context,
              title: 'Thông tin Bác sĩ',
              icon: Icons.person_outline,
              children: [
                _buildDetailRow('Tên bác sĩ:', 'BS. ${appointment.doctor.fullName}'),
                _buildDetailRow('Chuyên khoa:', appointment.doctor.department.name),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailCard(
              context,
              title: 'Thông tin Bệnh nhân',
              icon: Icons.personal_injury_outlined,
              children: [
                _buildDetailRow('Tên bệnh nhân:', appointment.patient?.fullName ?? 'Không có'),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailCard(
              context,
              title: 'Thông tin Lịch hẹn',
              icon: Icons.calendar_today_outlined,
              children: [
                _buildDetailRow('Ngày hẹn:', DateFormatter.formatDate(appointment.date)),
                _buildDetailRow('Giờ hẹn:', appointment.slotStart),
                _buildDetailRow('Trạng thái:', appointment.status, highlight: true),
                if (appointment.service != null)
                  _buildDetailRow('Dịch vụ:', appointment.service!.name),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(BuildContext context, {required String title, required IconData icon, required List<Widget> children}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: highlight ? Colors.blue.shade700 : null,
                fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}