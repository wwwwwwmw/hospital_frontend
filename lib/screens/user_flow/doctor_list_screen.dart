import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/doctor_list_provider.dart';
import '../../models/department.dart';

class DoctorListScreen extends StatefulWidget {
  const DoctorListScreen({super.key});

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Gọi hàm mới để tải cả bác sĩ và khoa
      Provider.of<DoctorListProvider>(context, listen: false).fetchDataForListScreen();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách Bác sĩ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<DoctorListProvider>(context, listen: false)
                  .fetchDataForListScreen();
            },
          ),
        ],
      ),
      body: Consumer<DoctorListProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.doctors.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(child: Text('Đã xảy ra lỗi: ${provider.errorMessage}'));
          }

          return Column(
            children: [
              // --- PHẦN BỘ LỌC MỚI ---
              _buildFilterChips(provider),
              const Divider(height: 1),
              // ------------------------

              Expanded(
                child: provider.filteredDoctors.isEmpty
                    ? const Center(child: Text('Không tìm thấy bác sĩ nào.'))
                    : ListView.builder(
                        itemCount: provider.filteredDoctors.length,
                        itemBuilder: (context, index) {
                          final doctor = provider.filteredDoctors[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            child: ListTile(
                              leading: const CircleAvatar(
                                child: Icon(Icons.person_outline),
                              ),
                              title: Text(doctor.fullName),
                              subtitle: Text(doctor.department.name), // Hiển thị tên khoa
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () {
                                context.go('/doctor_details/${doctor.id}');
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Widget helper để xây dựng các chip lọc
  Widget _buildFilterChips(DoctorListProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Chip "Tất cả"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ChoiceChip(
                label: const Text('Tất cả'),
                selected: provider.selectedDepartmentId == null,
                onSelected: (selected) {
                  if (selected) {
                    provider.selectDepartment(null);
                  }
                },
              ),
            ),
            // Các chip cho từng khoa
            ...provider.departments.map((Department department) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ChoiceChip(
                  label: Text(department.name),
                  selected: provider.selectedDepartmentId == department.id,
                  onSelected: (selected) {
                    provider.selectDepartment(selected ? department.id : null);
                  },
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
