import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:localtourapp/config/appConfig.dart';
import 'package:localtourapp/data/models/post.dart';

class TourApi {
  Future<List<Post>> fetchTours() async {
    final response = await http.get(Uri.parse('${AppConfig.apiBaseUrl}/posts'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Post.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load tours');
    }
  }
}
