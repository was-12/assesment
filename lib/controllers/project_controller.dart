import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/project_model.dart';

class ProjectController {
  Future<List<Project>> fetchProjects() async {
    try {
      print('Fetching projects...');
      // Using page_size=10 to fetch more items if available
      final response = await http.get(Uri.parse(
          'https://www.propstake.ai/api/dld?page=1&page_size=10&location_country=PK'));

      print('Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final List<dynamic> items = jsonResponse['data']['items'];
        return items.map((item) => Project.fromJson(item)).toList();
      } else {
        print('Server error: ${response.body}');
        throw Exception('Failed to load projects: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching projects: $e');
      throw Exception('Failed to fetch data. If on Web, this might be CORS. Error: $e');
    }
  }
}
