import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/project_model.dart';

class ProjectController {
  Future<List<Project>> fetchProjects() async {
    try {
      final response = await http.get(Uri.parse(
          'https://www.propstake.ai/api/dld?page=1&page_size=10&location_country=PK'));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['data'] != null &&
            jsonResponse['data']['items'] != null) {
          final List<dynamic> items = jsonResponse['data']['items'];
          return items.map((item) => Project.fromJson(item)).toList();
        }
        return [];
      } else {
        throw Exception('Failed to load projects: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch data: $e');
    }
  }
}
