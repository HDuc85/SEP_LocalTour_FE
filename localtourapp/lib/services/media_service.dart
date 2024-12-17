import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:http/http.dart' as http;

class MediaService {
  Future<XFile?> downloadAndConvertToXFile(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final tempDir = Directory.systemTemp;
        String extension = url.split('.').last.toLowerCase();
        if (!['jpg', 'jpeg', 'png', 'gif', 'bmp', 'mp4', 'mov', 'avi'].contains(extension)) {
          extension = 'jpg'; // fallback for images
        }
        String fileName = '${DateTime.now().millisecondsSinceEpoch}.$extension';
        final file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);
        return XFile(file.path);
      } else {
        print('Failed to download file: ${response.statusCode}');
      }
    } catch (e) {
      print('Error downloading file: $e');
    }
    return null;
  }
}