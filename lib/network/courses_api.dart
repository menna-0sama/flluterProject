import 'package:dio/dio.dart';
import 'package:graduation/model/course_model.dart';
import 'package:graduation/network/dio_client.dart';

class CoursesApi {

  static Future<List<CourseModel>> getCoursesByTrack(int trackId) async {
    try {
      final response = await DioClient.dio.get(
        "/api/Courses/track/$trackId",
      );

      print("COURSES STATUS: ${response.statusCode}");
      print("COURSES RESPONSE: ${response.data}");

      final data = response.data;

      if (data is List) {
        return data.map((e) => CourseModel.fromJson(e)).toList();
      }

      if (data is Map && data["data"] is List) {
        return (data["data"] as List)
            .map((e) => CourseModel.fromJson(e))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      print("COURSES ERROR STATUS: ${e.response?.statusCode}");
      print("COURSES ERROR BODY: ${e.response?.data}");
      throw Exception("Failed to load courses");
    }
  }
}