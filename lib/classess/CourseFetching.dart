import 'package:supabase_flutter/supabase_flutter.dart';

class CourseService {
  final SupabaseClient _client;

  CourseService(this._client);

  Future<List<String>> fetchCourses() async {
    try {
      // Fetch the courses from Supabase
      final response = await _client.from('CourseTable').select('Title');

      // Map the results to a list of course titles
      final courses = (response as List)
          .map<String>((course) => course['Title'].toString())
          .toList();

      return courses;
    } catch (e) {
      return []; // Return an empty list on error
    }
  }
}
