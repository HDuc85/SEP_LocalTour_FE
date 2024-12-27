// lib/page/planned_page/planned_page_tab_bars/add_schedule_dialog.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:localtourapp/models/schedule/schedule_model.dart';

import '../../../config/appConfig.dart';
import '../../../config/secure_storage_helper.dart';
// Import other necessary packages and files, such as SecureStorageHelper and AppConfig

typedef ScheduleCallback = void Function(String scheduleName, DateTime? startDate, DateTime? endDate);

void showAddScheduleDialog(
    BuildContext context, ScheduleCallback onCreate, List<ScheduleModel> listSchedule) {
  final TextEditingController scheduleNameController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  String languageCode = 'vi';
  String? scheduleNameError;

  Future<void> fetchLanguageCode(StateSetter setState) async {
    var langCode = await SecureStorageHelper().readValue(AppConfig.language);
    setState(() {
      languageCode = langCode ?? 'vi';
    });
  }

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          fetchLanguageCode(setState);

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            contentPadding: const EdgeInsets.all(0),
            content: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.orange[100]!],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(2, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          languageCode == 'vi'
                              ? "TẠO LỊCH TRÌNH MỚI"
                              : "CREATE NEW SCHEDULE",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        languageCode == 'vi' ? "Tên lịch trình:" : "Schedule's Name:",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: scheduleNameController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: languageCode == 'vi'
                              ? 'Nhập tên lịch trình'
                              : 'Enter schedule name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.edit, color: Colors.orange),
                          errorText: scheduleNameError,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        languageCode == 'vi' ? "Ngày bắt đầu:" : "Start Date:",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: startDate ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() {
                              startDate = picked;
                              if (endDate != null && startDate!.isAfter(endDate!)) {
                                endDate = null;
                              }
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.orange, width: 1),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                startDate != null
                                    ? DateFormat('yyyy-MM-dd').format(startDate!)
                                    : (languageCode == 'vi'
                                    ? 'Chọn ngày bắt đầu'
                                    : 'Select start date'),
                                style: const TextStyle(fontSize: 14, color: Colors.black54),
                              ),
                              const Icon(Icons.calendar_today, color: Colors.orange),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        languageCode == 'vi' ? "Ngày kết thúc:" : "End Date:",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: endDate ??
                                (startDate ?? DateTime.now()).add(const Duration(days: 1)),
                            firstDate: startDate ?? DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() {
                              endDate = picked;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.orange, width: 1),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                endDate != null
                                    ? DateFormat('yyyy-MM-dd').format(endDate!)
                                    : (languageCode == 'vi'
                                    ? 'Chọn ngày kết thúc'
                                    : 'Select end date'),
                                style: const TextStyle(fontSize: 14, color: Colors.black54),
                              ),
                              const Icon(Icons.calendar_today, color: Colors.orange),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            // Validate schedule name
                            if (scheduleNameController.text.isEmpty) {
                              setState(() {
                                scheduleNameError = languageCode == 'vi'
                                    ? 'Vui lòng nhập tên lịch trình'
                                    : 'Please input schedule name';
                              });
                              return;
                            }

                            // Check for duplicate schedule name
                            bool isDuplicate = listSchedule.any((element) =>
                            element.scheduleName == scheduleNameController.text);

                            if (isDuplicate) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(languageCode == 'vi'
                                        ? 'Cảnh báo'
                                        : 'Warning'),
                                    content: Text(
                                      languageCode == 'vi'
                                          ? 'Tên lịch trình này đã tồn tại. Bạn có muốn tiếp tục không?'
                                          : 'This schedule name already exists. Do you want to continue?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text(languageCode == 'vi' ? 'Hủy' : 'Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          onCreate(
                                            scheduleNameController.text,
                                            startDate,
                                            endDate,
                                          );
                                          Navigator.of(context).pop(); // Close confirmation dialog
                                          Navigator.of(context).pop();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                languageCode == 'vi'
                                                    ? 'Lịch trình mới đã được tạo'
                                                    : 'New schedule has been created',
                                              ),
                                              duration: const Duration(seconds: 2),
                                            ),
                                          );// Close add schedule dialog
                                        },
                                        child: Text(languageCode == 'vi' ? 'Thêm' : 'Add'),
                                      ),
                                    ],
                                  );
                                },
                              );
                              return;
                            }

                            // Proceed with schedule creation
                            onCreate(
                              scheduleNameController.text,
                              startDate,
                              endDate,
                            );
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  languageCode == 'vi'
                                      ? 'Lịch trình mới đã được tạo'
                                      : 'New schedule has been created',
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );// Close the add schedule dialog
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 50, vertical: 14),
                            backgroundColor: Colors.orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            languageCode == 'vi' ? "TẠO" : "CREATE",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

