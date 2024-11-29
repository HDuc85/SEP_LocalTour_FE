// lib/page/setting_page.dart

import 'package:flutter/material.dart';
import 'package:localtourapp/config/appConfig.dart';
import 'package:localtourapp/config/secure_storage_helper.dart';


class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  // Define the list of supported languages
  final List<Map<String, String>> _languages = [
    {'name': 'English', 'code': 'en'},
    {'name': 'Vietnamese', 'code': 'vi'},
  ];
  String currentLanguageCode = 'en';
  Future<void> getSystemLanguage() async{
    String? languagecode = await SecureStorageHelper().readValue(AppConfig.language);
    if(languagecode != null){
      setState(() {
        currentLanguageCode = languagecode;
      });
    }
  }
  Future<void> changeSystemLanguage(String languageCode) async {
    if(languageCode != null){
      await SecureStorageHelper().saveValue(AppConfig.language, languageCode);
      getSystemLanguage();
    }
  }

  @override
  void initState() {
    super.initState();
    getSystemLanguage();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'), // Consider localizing this string
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Change Language Container
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border:
                Border.all(width: 1, color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Icon at far left
                  const Icon(
                    Icons.language, // Globe icon
                    size: 30,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 16),
                  // Column with Text and Dropdown
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Change Language', // Consider localizing
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: currentLanguageCode,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding:
                            EdgeInsets.symmetric(horizontal: 12),
                          ),
                          items: _languages.map((lang) {
                            return DropdownMenuItem<String>(
                              value: lang['code'],
                              child: Text(lang['name']!),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              changeSystemLanguage(newValue);
                            }
                          },
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please select a language'; // Consider localizing
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Add more settings containers here as needed
          ],
        ),
      ),
    );
  }
}
