import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:http/http.dart' as http;

class MediaService {
  Future<XFile?> downloadAndConvertToXFile(String url) async {
    try {
      // Gửi yêu cầu tải file từ URL
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // Tạo file trong thư mục tạm
        final tempDir = Directory.systemTemp;
        String extension = url.split('.').last.toLowerCase();
        if (!['jpg', 'jpeg', 'png', 'gif', 'bmp'].contains(extension)) {
          extension = 'jpg';
        }
        String fileName = '${DateTime.now().millisecondsSinceEpoch}.$extension';
        final file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);

        // Trả về XFile
        return XFile(file.path);
      } else {
        print('Failed to download file: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
    return null;
  }
}