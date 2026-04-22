import 'package:dio/dio.dart';
import 'dio_client.dart';

class CoursesAPI {

  // 🔹 GET All Courses
  static Future<List<dynamic>> getCourses() async {
    try {
      final response = await DioClient.dio.get(
        "http://81.17.102.211:5000/api/Courses",
      );

      print("COURSES RESPONSE: ${response.data}");

      return response.data;
    } catch (e) {
      print("❌ ERROR IN GET COURSES: $e");
      throw Exception("Failed to load courses");
    }
  }
}