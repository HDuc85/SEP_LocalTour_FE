// lib/page/planned_page/planned_page_tab_bars/add_schedule_dialog.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:localtourapp/models/schedule/schedule_model.dart';

import '../../../config/appConfig.dart';
import '../../../config/secure_storage_helper.dart';
// Import other necessary packages and files, such as SecureStorageHelper and AppConfig

typedef ScheduleCallback = void Function(String scheduleName, DateTime? startDate, DateTime? endDate);

void showAddScheduleDialog(BuildContext context, ScheduleCallback onCreate, List<ScheduleModel> listSchedule) {
  final TextEditingController scheduleNameController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  String languageCode = 'vi'; // Default language code
  String? scheduleNameError;

  // Function to fetch language code
  Future<void> fetchLanguageCode(StateSetter setState) async {
    var languageCode = await SecureStorageHelper().readValue(AppConfig.language);
    setState(() {
      languageCode = languageCode ?? 'vi'; // Fallback to 'vi' if null
    });
  }

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: GestureDetector(
            onTap: () {},
            child: StatefulBuilder(
              builder: (context, setState) {
                // Fetch the language code when the dialog is built
                fetchLanguageCode(setState);

                return SingleChildScrollView(
                  child: AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: Center(
                      child: Text(
                        languageCode == 'vi' ? "TẠO LỊCH TRÌNH MỚI" : "CREATE NEW SCHEDULE",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            languageCode == 'vi' ? "Tên lịch trình:" : "Schedule's name:",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: scheduleNameController,
                          decoration: InputDecoration(
                            hintText: languageCode == 'vi' ? 'Nhập tên lịch trình' : 'Enter schedule name',
                            border: const OutlineInputBorder(),
                            errorText: scheduleNameError,
                          ),
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: startDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() {
                                startDate = picked;
                              });
                            }
                          },
                          child: Stack(
                            children: [
                              AbsorbPointer(
                                child: TextField(
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.calendar_today),
                                    hintText: startDate != null
                                        ? DateFormat('yyyy-MM-dd').format(startDate!)
                                        : (languageCode == 'vi' ? 'Ngày bắt đầu' : 'Start Date'),
                                    border: const OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              if (startDate != null)
                                Positioned(
                                  top: 5,
                                  right: 0,
                                  child: IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      setState(() {
                                        startDate = null;
                                      });
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: endDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() {
                                endDate = picked;
                              });
                            }
                          },
                          child: Stack(
                            children: [
                              AbsorbPointer(
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.calendar_today),
                                    hintText: endDate != null
                                        ? DateFormat('yyyy-MM-dd').format(endDate!)
                                        : (languageCode == 'vi' ? 'Ngày kết thúc' : 'End Date'),
                                    border: const OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              if (endDate != null)
                                Positioned(
                                  top: 5,
                                  right: 0,
                                  child: IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      setState(() {
                                        endDate = null;
                                      });
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            if (scheduleNameController.text.isEmpty) {
                              setState(() {
                                scheduleNameError = languageCode == 'vi'
                                    ? 'Vui lòng nhập tên lịch trình'
                                    : 'Please input schedule name';
                              });
                            } else {
                              setState(() {
                                scheduleNameError = null;
                              });

                              if(listSchedule.any((element) => element.scheduleName.contains(scheduleNameController.text),)){
                                    showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text(
                                          languageCode != 'vi'
                                              ? "Warning"
                                              : "Cảnh báo",
                                        ),
                                        content: Text(
                                          languageCode != 'vi'
                                              ? "This Schedule Name already exits, do you want to continue?"
                                              : "Tên lịch trình nãy đã tồn tại, bạn có muốn tiếp tục không?",
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context)
                                                  .pop();
                                            },
                                            child: Text(languageCode !=
                                                'vi'
                                                ? "Cancel"
                                                : "Hủy"),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              onCreate(
                                                scheduleNameController.text,
                                                startDate,
                                                endDate,
                                              );
                                              Navigator.of(context).pop();
                                              Navigator.of(context).pop();
                                              // Show success notification
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    languageCode == 'vi'
                                                        ? 'Lịch trình mới đã được tạo'
                                                        : 'New schedule has been created',
                                                  ),
                                                  duration: const Duration(seconds: 2),
                                                ),
                                              );
                                            },
                                            child: Text(
                                                languageCode !=
                                                    'vi'
                                                    ? "Add"
                                                    : "Thêm"),
                                          ),
                                        ],
                                      );
                                    });
                              }else{
                                onCreate(
                                  scheduleNameController.text,
                                  startDate,
                                  endDate,
                                );
                                Navigator.of(context).pop();
                                // Show success notification
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      languageCode == 'vi'
                                          ? 'Lịch trình mới đã được tạo'
                                          : 'New schedule has been created',
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }


                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pinkAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: const BorderSide(color: Colors.black, width: 2),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 50,
                              vertical: 10,
                            ),
                          ),
                          child: Text(
                            languageCode == 'vi' ? "Tạo" : "Create",
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
                );
              },
            ),
          ),
        ),
      );
    },
  );
}
